# 🏗️ Architecture Markazi - Phase 2

## 📋 Structure Mise en Place

```
lib/
├── main.dart (avec MultiProvider)
├── screens/ (UI - non modifiée)
├── widgets/ (Composants - non modifiée)
├── utils/ (Constantes - non modifiée)
├── models/
│   ├── student.dart (Modèle élève)
│   ├── payment.dart (Modèle paiement)
│   ├── attendance.dart (Modèle présence)
│   └── index.dart (Export)
├── providers/
│   ├── student_provider.dart (Gestion élèves)
│   ├── payment_provider.dart (Gestion paiements)
│   ├── attendance_provider.dart (Gestion présences)
│   └── index.dart (Export)
├── services/ (Placeholder - vide)
└── repositories/ (Placeholder - vide)
```

---

## 🎯 Modèles de Données

### Student
```dart
Student(
  id: String,           // UUID généré
  name: String,         // Nom de l'élève
  parentPhone: String,  // Téléphone parent
  markazId: String,     // ID de la Markaz
  createdAt: DateTime   // Date de création
)
```

### Payment
```dart
Payment(
  id: String,           // UUID généré
  studentId: String,    // Référence à Student
  markazId: String,     // ID de la Markaz
  amount: double,       // Montant
  status: PaymentStatus, // paid | unpaid
  date: DateTime        // Date du paiement
)
```

### Attendance
```dart
Attendance(
  id: String,           // UUID généré
  studentId: String,    // Référence à Student
  markazId: String,     // ID de la Markaz
  date: DateTime,       // Date de présence
  status: AttendanceStatus, // present | absent
  lesson: String        // Leçon (Sourate, Versets)
)
```

---

## 📊 Providers (Gestion d'État)

### StudentProvider
```dart
// Ajouter
provider.addStudent(name: '...', parentPhone: '...', markazId: '...');

// Récupérer
final students = provider.students;
final student = provider.getStudentById('...');
final markaz_students = provider.getStudentsByMarkaz('...');

// Modifier
provider.updateStudent(updatedStudent);

// Supprimer
provider.removeStudent(studentId);
```

### PaymentProvider
```dart
// Ajouter
provider.addPayment(
  studentId: '...',
  markazId: '...',
  amount: 50.0,
  status: PaymentStatus.unpaid
);

// Récupérer
final payments = provider.payments;
final student_payments = provider.getPaymentsByStudent('...');
final total = provider.getTotalPaymentForStudent('...');
final pending = provider.getPendingPaymentsCount('...');

// Mettre à jour
provider.markAsPaid(paymentId);
```

### AttendanceProvider
```dart
// Ajouter
provider.markPresent(studentId, markazId, 'Sourate Al-Fatiha');
provider.markAbsent(studentId, markazId);

// Récupérer
final attendances = provider.attendances;
final student_att = provider.getAttendancesByStudent('...');
final today_att = provider.getTodayAttendanceByMarkaz('...');
final rate = provider.getAttendanceRateForStudent('...');
```

---

## 🔌 Utilisation dans les Écrans

### Exemple dans HomeScreen ou FeaturesScreen

```dart
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';

// Dans le build():
Consumer<StudentProvider>(
  builder: (context, provider, _) {
    final students = provider.students;
    
    return Column(
      children: [
        Text('Total élèves: ${provider.totalStudents}'),
        ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return ListTile(
              title: Text(student.name),
              subtitle: Text(student.parentPhone),
            );
          },
        ),
      ],
    );
  },
)

// Ajouter un élève (event handler):
ElevatedButton(
  onPressed: () {
    context.read<StudentProvider>().addStudent(
      name: 'Ahmed',
      parentPhone: '123456',
      markazId: 'markaz1'
    );
  },
  child: const Text('Ajouter'),
)
```

---

## 🔮 Architecture Future

### Phase 3 - Services
- student_service.dart → Logique métier
- payment_service.dart → Calculs et validations
- attendance_service.dart → Analyse
- report_service.dart → Génératio rapports

### Phase 4 - Repositories
- student_repository.dart → Firestore + Hive
- payment_repository.dart → Firestore + Hive
- attendance_repository.dart → Firestore + Hive

### Phase 5 - Firebase
- Authentication
- Firestore synchronisation
- Offline-first strategy

---

## 🧪 Tests

Tests unitaires à ajouter:
```dart
test('StudentProvider - addStudent', () {
  final provider = StudentProvider();
  provider.addStudent(name: 'Test', parentPhone: '123', markazId: 'm1');
  expect(provider.totalStudents, 1);
});

test('PaymentProvider - markAsPaid', () {
  final provider = PaymentProvider();
  // ...
});
```

---

## ✅ Checklist d'Intégration

- [ ] Installer: `flutter pub get`
- [ ] Vérifier: Pas de compilation errors
- [ ] Tester: Ajouter/lire des élèves dans console
- [ ] Vérifier: Les écrans existants fonctionnent toujours
- [ ] Intégrer: Connecter HomeScreen ou FeaturesScreen avec les providers
- [ ] Documenter: Ajouter encore des exemples d'usage

---

## 📞 Support

Pour connecter les providers aux écrans:
1. Utilisez `context.read<ProviderType>()` dans les event handlers
2. Utilisez `Consumer<ProviderType>()` pour les widgets qui écoutent les changements
3. Les données en mémoire persistent tant que l'app est ouverte

