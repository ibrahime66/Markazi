import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:markazi/datasources/api_attendance_datasource.dart';
import 'package:markazi/datasources/api_class_datasource.dart';
import 'package:markazi/datasources/api_guardian_datasource.dart';
import 'package:markazi/datasources/api_payment_datasource.dart';
import 'package:markazi/datasources/api_recitation_datasource.dart';
import 'package:markazi/datasources/api_student_datasource.dart';
import 'package:markazi/datasources/hive_attendance_datasource.dart';
import 'package:markazi/datasources/hive_class_datasource.dart';
import 'package:markazi/datasources/hive_guardian_datasource.dart';
import 'package:markazi/datasources/hive_payment_datasource.dart';
import 'package:markazi/datasources/hive_recitation_datasource.dart';
import 'package:markazi/datasources/hive_student_datasource.dart';
import 'package:markazi/models/attendance.dart';
import 'package:markazi/models/class_model.dart';
import 'package:markazi/models/guardian.dart';
import 'package:markazi/models/payment.dart';
import 'package:markazi/models/recitation.dart';
import 'package:markazi/models/student.dart';
import 'package:markazi/models/sync_queue_item.dart';
import 'package:markazi/repositories/attendance_repository.dart';
import 'package:markazi/repositories/class_repository.dart';
import 'package:markazi/repositories/guardian_repository.dart';
import 'package:markazi/repositories/payment_repository.dart';
import 'package:markazi/repositories/recitation_repository.dart';
import 'package:markazi/repositories/student_repository.dart';
import 'package:markazi/services/api_client.dart';
import 'package:markazi/services/sync_orchestrator.dart';
import 'package:markazi/services/sync_queue_service.dart';

/// doc/audit.md, points D2/F5 — mode hors ligne (CDC §20/§27), testé avec
/// une vraie base Hive (dossier temporaire) et de faux serveurs API.

DioException _offline() => DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionError,
    );

DioException _rejected(String message) => DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/'),
        statusCode: 422,
        data: {'message': message},
      ),
    );

/// Faux serveur des paiements : bascule en ligne/hors ligne, enregistre les
/// appels reçus et attribue des identifiants numériques "serveur".
class _FakePaymentApi extends Fake implements ApiPaymentDatasource {
  bool online = true;
  String? rejectWith;
  int _nextId = 100;
  final List<Payment> serverPayments = [];
  final List<DateTime?> receivedPerformedAt = [];

  void _check() {
    if (!online) throw _offline();
    if (rejectWith != null) throw _rejected(rejectWith!);
  }

  @override
  Future<Payment> addPayment(
    Payment payment,
    String markazId, {
    bool confirmDuplicate = false,
    DateTime? performedAt,
  }) async {
    _check();
    receivedPerformedAt.add(performedAt);
    final saved = payment.copyWith(id: '${_nextId++}', receiptNumber: 'MK-1-2026-000001');
    serverPayments.add(saved);
    return saved;
  }

  @override
  Future<Payment> updatePayment(Payment payment, {DateTime? performedAt}) async {
    _check();
    receivedPerformedAt.add(performedAt);
    serverPayments.removeWhere((p) => p.id == payment.id);
    serverPayments.add(payment);
    return payment;
  }

  @override
  Future<List<Payment>> getPaymentsByMarkaz(String markazId) async {
    _check();
    return List.of(serverPayments);
  }
}

class _FakeAttendanceApi extends Fake implements ApiAttendanceDatasource {}

class _FakeGuardianApi extends Fake implements ApiGuardianDatasource {}

class _FakeRecitationApi extends Fake implements ApiRecitationDatasource {}

class _FakeStudentApi extends Fake implements ApiStudentDatasource {}

class _FakeClassApi extends Fake implements ApiClassDatasource {
  bool online = true;
  /// Affectations reçues, sous la forme "élève→groupe".
  final List<String> assignments = [];

  @override
  Future<void> addStudentToClass(String classId, String studentId) async {
    if (!online) throw _offline();
    assignments.add('$studentId→$classId');
  }

  @override
  Future<void> setStudentClass(String studentId, String? classId, {DateTime? performedAt}) async {
    if (!online) throw _offline();
    assignments.add('$studentId→$classId');
  }

  @override
  Future<List<ClassModel>> getClassesByMarkaz(String markazId) async {
    if (!online) throw _offline();
    // Le serveur ne connaît pas encore l'affectation faite hors ligne.
    return [_class('c1', const []), _class('c2', const [])];
  }
}

ClassModel _class(String id, List<String> studentIds) => ClassModel(
      id: id,
      name: 'Groupe $id',
      level: 'Débutant',
      description: '',
      teacherId: '',
      teacherName: '',
      maxStudents: 30,
      studentIds: studentIds,
      markazId: 'm1',
      createdAt: DateTime(2026, 1, 1),
      isActive: true,
    );

Payment _payment(String id, {PaymentStatus status = PaymentStatus.unpaid}) => Payment(
      id: id,
      studentId: '1',
      markazId: 'm1',
      amount: 50000,
      status: status,
      date: DateTime(2026, 10, 1),
    );

late Directory _dir;
late SyncQueueService queue;
late _FakePaymentApi _paymentApi;
late _FakeClassApi _classApi;
late PaymentRepository payments;
late ClassRepository classes;
late HiveClassDataSource hiveClasses;
late SyncOrchestrator orchestrator;

void main() {
  setUpAll(() {
    Hive.registerAdapter(StudentAdapter());
    Hive.registerAdapter(PaymentAdapter());
    Hive.registerAdapter(PaymentStatusAdapter());
    Hive.registerAdapter(AttendanceAdapter());
    Hive.registerAdapter(AttendanceStatusAdapter());
    Hive.registerAdapter(ClassModelAdapter());
    Hive.registerAdapter(GuardianAdapter());
    Hive.registerAdapter(RecitationAdapter());
    Hive.registerAdapter(RecitationStatusAdapter());
    Hive.registerAdapter(SyncQueueItemAdapter());
    Hive.registerAdapter(SyncOperationAdapter());
    Hive.registerAdapter(SyncEntityTypeAdapter());
  });

  setUp(() async {
    _dir = await Directory.systemTemp.createTemp('markazi_offline_test');
    Hive.init(_dir.path);

    queue = SyncQueueService();
    await queue.init();
    _paymentApi = _FakePaymentApi();
    _classApi = _FakeClassApi();

    payments = PaymentRepository(HivePaymentDataSource(), _paymentApi, queue);
    hiveClasses = HiveClassDataSource();
    classes = ClassRepository(hiveClasses, _classApi, queue);
    final attendances =
        AttendanceRepository(HiveAttendanceDataSource(), _FakeAttendanceApi(), queue);
    final guardians =
        GuardianRepository(HiveGuardianDataSource(), _FakeGuardianApi(), queue);
    final recitations =
        RecitationRepository(HiveRecitationDataSource(), _FakeRecitationApi(), queue);
    final students = StudentRepository(HiveStudentDataSource(), _FakeStudentApi());
    for (final init in [
      payments.init,
      classes.init,
      attendances.init,
      guardians.init,
      recitations.init,
      students.init,
    ]) {
      await init();
    }

    orchestrator = SyncOrchestrator(
      queue: queue,
      paymentRepository: payments,
      attendanceRepository: attendances,
      guardianRepository: guardians,
      recitationRepository: recitations,
      classRepository: classes,
      studentRepository: students,
    );
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    await _dir.delete(recursive: true);
  });

  group('File d’attente : fusion des actions', () {
    test('création puis modification hors ligne = une seule création, datée de la dernière action', () async {
      final t1 = DateTime(2026, 10, 7, 9);
      final t2 = DateTime(2026, 10, 7, 10);
      await queue.enqueue(
          entityType: SyncEntityType.payment, operation: SyncOperation.create, entityId: 'tmp', performedAt: t1);
      await queue.enqueue(
          entityType: SyncEntityType.payment, operation: SyncOperation.update, entityId: 'tmp', performedAt: t2);

      final items = queue.getAll();
      expect(items, hasLength(1));
      expect(items.single.operation, SyncOperation.create);
      expect(items.single.actionDate, t2);
    });

    test('création puis suppression hors ligne = plus rien à envoyer', () async {
      await queue.enqueue(entityType: SyncEntityType.payment, operation: SyncOperation.create, entityId: 'tmp');
      await queue.enqueue(entityType: SyncEntityType.payment, operation: SyncOperation.delete, entityId: 'tmp');
      expect(queue.pendingCount, 0);
    });

    test('modification puis suppression = seule la suppression reste', () async {
      await queue.enqueue(entityType: SyncEntityType.guardian, operation: SyncOperation.update, entityId: '5');
      await queue.enqueue(entityType: SyncEntityType.guardian, operation: SyncOperation.delete, entityId: '5');
      expect(queue.getAll().single.operation, SyncOperation.delete);
    });

    test('une nouvelle saisie efface le refus précédent', () async {
      await queue.enqueue(entityType: SyncEntityType.guardian, operation: SyncOperation.update, entityId: '5');
      await queue.markFailed(queue.getAll().single.id, 'Nom obligatoire');
      expect(queue.failedCount, 1);
      await queue.enqueue(entityType: SyncEntityType.guardian, operation: SyncOperation.update, entityId: '5');
      expect(queue.failedCount, 0);
    });
  });

  group('Repository des paiements', () {
    test('hors ligne : la création est conservée localement et mise en file', () async {
      _paymentApi.online = false;
      final result = await payments.addPayment(_payment('tmp-1'));

      expect(result.id, 'tmp-1');
      expect(payments.getPaymentById('tmp-1'), isNotNull);
      expect(queue.hasPendingCreate(SyncEntityType.payment, 'tmp-1'), isTrue);
    });

    test('refus du serveur : erreur remontée, rien mis en file', () async {
      _paymentApi.rejectWith = 'Montant invalide';
      await expectLater(
        payments.addPayment(_payment('tmp-1')),
        throwsA(isA<ApiException>().having((e) => e.toString(), 'message', 'Montant invalide')),
      );
      expect(queue.pendingCount, 0);
      expect(payments.getPaymentById('tmp-1'), isNull);
    });

    test('refus du serveur sur une modification : version locale restaurée', () async {
      final saved = await payments.addPayment(_payment('tmp-1'));
      _paymentApi.rejectWith = 'Interdit';
      await expectLater(
        payments.updatePayment(saved.copyWith(status: PaymentStatus.paid)),
        throwsA(isA<ApiException>()),
      );
      expect(payments.getPaymentById(saved.id)!.status, PaymentStatus.unpaid);
      expect(queue.pendingCount, 0);
    });

    test('le rechargement depuis le serveur n’écrase pas une saisie en attente', () async {
      _paymentApi.online = false;
      await payments.addPayment(_payment('tmp-1'));
      _paymentApi.online = true;
      await payments.syncFromMarkaz('m1');
      expect(payments.getPaymentById('tmp-1'), isNotNull);
    });
  });

  group('Orchestrateur', () {
    test('rejeu : identifiant temporaire remplacé par celui du serveur, date réelle envoyée', () async {
      _paymentApi.online = false;
      await payments.addPayment(_payment('tmp-1'));
      final performedAt = queue.getAll().single.actionDate;

      _paymentApi.online = true;
      final report = await orchestrator.replayPending();

      expect(report.synced, 1);
      expect(queue.pendingCount, 0);
      expect(payments.getPaymentById('tmp-1'), isNull);
      expect(payments.getPaymentById('100')?.receiptNumber, 'MK-1-2026-000001');
      expect(_paymentApi.receivedPerformedAt.single, performedAt);
    });

    test('toujours hors ligne : rejeu interrompu, actions conservées dans l’ordre', () async {
      _paymentApi.online = false;
      await payments.addPayment(_payment('tmp-1'));
      await payments.addPayment(_payment('tmp-2'));

      final report = await orchestrator.replayPending();
      expect(report.offline, isTrue);
      expect(queue.getAll().map((i) => i.entityId), ['tmp-1', 'tmp-2']);
    });

    test('refus du serveur au rejeu : action gardée avec son message, la suite continue', () async {
      _paymentApi.online = false;
      await payments.addPayment(_payment('tmp-1'));
      await queue.enqueue(
          entityType: SyncEntityType.studentClass,
          operation: SyncOperation.update,
          entityId: '7',
          payload: 'c1');

      _paymentApi.online = true;
      _paymentApi.rejectWith = 'Doublon';
      final report = await orchestrator.replayPending();

      expect(report.failed, 1);
      expect(report.synced, 1);
      expect(queue.getAll().single.lastError, 'Doublon');
      expect(_classApi.assignments.single, '7→c1');
    });

    test('correctif F5 : une modification hors ligne survit à la synchronisation complète', () async {
      final saved = await payments.addPayment(_payment('tmp-1'));
      _paymentApi.online = false;
      await payments.updatePayment(saved.copyWith(status: PaymentStatus.paid));

      _paymentApi.online = true;
      await orchestrator.syncAll('m1');

      // Envoyée au serveur AVANT le rechargement : la version locale gagne.
      expect(_paymentApi.serverPayments.single.status, PaymentStatus.paid);
      expect(payments.getPaymentById(saved.id)!.status, PaymentStatus.paid);
      expect(queue.pendingCount, 0);
    });

    test('abandon d’une création : retirée de la file et de l’appareil', () async {
      _paymentApi.online = false;
      await payments.addPayment(_payment('tmp-1'));
      await orchestrator.discard(queue.getAll().single);
      expect(queue.pendingCount, 0);
      expect(payments.getPaymentById('tmp-1'), isNull);
    });
  });

  group('Groupes', () {
    test('affectation hors ligne : mise en file avec le groupe cible et préservée au rechargement', () async {
      await hiveClasses.addClass(_class('c1', const []));
      await hiveClasses.addClass(_class('c2', const ['7']));
      _classApi.online = false;

      await classes.addStudentToClass('c1', '7');
      expect(queue.getAll().single.payload, 'c1');
      // Un élève n'appartient qu'à un groupe : retiré de l'ancien.
      expect(classes.getClassById('c2')!.studentIds, isEmpty);

      _classApi.online = true;
      await classes.syncFromMarkaz('m1');
      expect(classes.getClassById('c1')!.studentIds, ['7']);

      await orchestrator.replayPending();
      expect(_classApi.assignments.single, '7→c1');
      expect(queue.pendingCount, 0);
    });
  });
}
