// Fichier d'exemple montrant l'utilisation des providers
//
// Ce fichier n'est PAS utilisé automatiquement.
// Copiez les exemples dans vos écrans pour utiliser les providers.

// ignore: unused_import
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:provider/provider.dart';
// ignore: unused_import
import 'lib/models/student.dart';
// ignore: unused_import
import 'lib/models/payment.dart';
// ignore: unused_import
import 'lib/models/attendance.dart';
// ignore: unused_import
import 'lib/providers/student_provider.dart';
// ignore: unused_import
import 'lib/providers/payment_provider.dart';
// ignore: unused_import
import 'lib/providers/attendance_provider.dart';

/// ========================
/// EXEMPLE 1: Ajouter un élève
/// ========================
class AddStudentExample extends StatelessWidget {
  const AddStudentExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Récupérer le provider et ajouter un élève
        context.read<StudentProvider>().addStudent(
              name: 'Ahmed Ali',
              parentPhone: '+212612345678',
              markazId: 'markaz_001',
            );

        // Afficher un confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Élève ajouté!')),
        );
      },
      child: const Text('Ajouter un élève'),
    );
  }
}

/// ========================
/// EXEMPLE 2: Afficher la liste
/// ========================
class ListStudentsExample extends StatelessWidget {
  const ListStudentsExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer écoute les changements du provider
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        final students = studentProvider.students;

        if (students.isEmpty) {
          return const Center(
            child: Text('Aucun élève enregistré'),
          );
        }

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(student.name[0]),
              ),
              title: Text(student.name),
              subtitle: Text(student.parentPhone),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  studentProvider.removeStudent(student.id);
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// ========================
/// EXEMPLE 3: Ajouter un paiement
/// ========================
class AddPaymentExample extends StatelessWidget {
  const AddPaymentExample({Key? key, required this.studentId})
      : super(key: key);

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<PaymentProvider>().addPayment(
              studentId: studentId,
              markazId: 'markaz_001',
              amount: 500.0,
              status: PaymentStatus.unpaid,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Paiement enregistré!')),
        );
      },
      child: const Text('Ajouter paiement (500 DH)'),
    );
  }
}

/// ========================
/// EXEMPLE 4: Présences
/// ========================
class AttendanceExample extends StatelessWidget {
  const AttendanceExample({Key? key, required this.studentId})
      : super(key: key);

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            context.read<AttendanceProvider>().markPresent(
                  studentId,
                  'markaz_001',
                  'Sourate Al-Fatiha',
                );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Présent!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Présent'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AttendanceProvider>().markAbsent(
                  studentId,
                  'markaz_001',
                );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ Absent')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Absent'),
        ),
      ],
    );
  }
}

/// ========================
/// EXEMPLE 5: Statistiques
/// ========================
class StatisticsExample extends StatelessWidget {
  const StatisticsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<StudentProvider, PaymentProvider, AttendanceProvider>(
      builder: (context, students, payments, attendance, _) {
        return Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${students.totalStudents}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Élèves'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${payments.payments.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Paiements'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '${attendance.attendances.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Présences'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// ========================
/// EXEMPLE COMPLET: Section intégrable
/// ========================
class CompleteStudentManagementExample extends StatefulWidget {
  const CompleteStudentManagementExample({super.key});

  @override
  State<CompleteStudentManagementExample> createState() =>
      _CompleteStudentManagementExampleState();
}

class _CompleteStudentManagementExampleState
    extends State<CompleteStudentManagementExample> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Formulaire d'ajout
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'élève',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone parent',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty) {
                      context.read<StudentProvider>().addStudent(
                            name: nameController.text,
                            parentPhone: phoneController.text,
                            markazId: 'markaz_001',
                          );
                      nameController.clear();
                      phoneController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Élève ajouté!')),
                      );
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Liste des élèves
        Expanded(
          child: Consumer<StudentProvider>(
            builder: (context, provider, _) {
              if (provider.students.isEmpty) {
                return const Center(
                  child: Text('Aucun élève'),
                );
              }
              return ListView.builder(
                itemCount: provider.students.length,
                itemBuilder: (context, index) {
                  final student = provider.students[index];
                  return ListTile(
                    title: Text(student.name),
                    subtitle: Text(student.parentPhone),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        provider.removeStudent(student.id);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
