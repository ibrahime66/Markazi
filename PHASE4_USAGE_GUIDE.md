# PHASE 4 - GUIDE D'UTILISATION DES SERVICES

## 📖 VUE D'ENSEMBLE

Après Phase 4, voici comment utiliser les Services dans les écrans.

---

## 🎯 EXEMPLE 1: Ajouter un élève dans HomeScreen

### AVANT (Phase 3 - Repository direct)
```dart
// ❌ Ne plus utiliser ça!
Future<void> addStudent() async {
  const uuid = Uuid();
  final student = Student(
    id: uuid.v4(),
    name: _nameController.text,
    parentPhone: _phoneController.text,
    markazId: 'markaz_001',
    createdAt: DateTime.now(),
  );
  await context.read<StudentProvider>()._repository.addStudent(student);
}
```

### APRÈS (Phase 4 - Services + Validation)
```dart
// ✅ Utiliser maintenant!
Future<void> addStudent() async {
  try {
    await context.read<StudentProvider>().addStudent(
      name: _nameController.text,
      parentPhone: _phoneController.text,
      // markazId: optionnel (utilise l'utilisateur actuel)
    );
    
    // ✅ Succès - Afficher message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Élève ajouté avec succès')),
    );
  } catch (e) {
    // ❌ Erreur - Afficher message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur: $e')),
    );
  }
}
```

**Améliorations:**
- ✅ Validations automatiques (numéro téléphone, nom, etc.)
- ✅ Gestion erreur explicite
- ✅ Multi-markaz automatique
- ✅ Pas besoin d'importer Uuid

---

## 🎯 EXEMPLE 2: Afficher les statistiques d'élèves

```dart
class StudentStatsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        final stats = provider.statistics;
        
        return Column(
          children: [
            // Total d'élèves
            Text('Total: ${stats['totalCount']}'),
            
            // Élèves par mois
            ...stats['byMonth'].entries.map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }).toList(),
            
            // Ajouts récents
            ...stats['latestAdditions'].take(5).map((student) {
              return Text(student.name);
            }).toList(),
          ],
        );
      },
    );
  }
}
```

---

## 💰 EXEMPLE 3: Gérer les paiements

### Ajouter un paiement
```dart
Future<void> recordPayment(String studentId) async {
  try {
    await context.read<PaymentProvider>().addPayment(
      studentId: studentId,
      amount: 500.0,
      status: PaymentStatus.paid,
    );
    
    showSuccessMessage('Paiement enregistré');
  } catch (e) {
    showErrorMessage(e.toString());
  }
}
```

### Marquer comme payé
```dart
Future<void> markAsPaid(String paymentId) async {
  try {
    await context.read<PaymentProvider>().markAsPaid(paymentId);
    showSuccessMessage('Marqué comme payé');
  } catch (e) {
    showErrorMessage(e.toString());
  }
}
```

### Générer un reçu
```dart
Future<void> printReceipt(String paymentId) async {
  try {
    final receipt = await context.read<PaymentProvider>().generateReceipt(paymentId);
    
    // Phase 5: Intégrer package:printing pour vrai PDF
    debugPrint('Reçu: ${receipt['receiptNumber']}');
    debugPrint('Montant: ${receipt['amount']} ${receipt['currency']}');
    debugPrint('Statut: ${receipt['status']}');
    
  } catch (e) {
    showErrorMessage(e.toString());
  }
}
```

### Voir les statistiques de paiement
```dart
class PaymentSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProvider>(
      builder: (context, provider, _) {
        final stats = provider.statistics;
        
        return Card(
          child: Column(
            children: [
              Text('Paiements totaux: ${stats['totalPayments']}'),
              Text('Montant payé: ${stats['totalPaidAmount']} MAD'),
              Text('En attente: ${stats['totalUnpaidAmount']} MAD'),
              Text('Pourcentage payé: ${stats['paidPercentage']}%'),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 📊 EXEMPLE 4: Gestion des présences

### Marquer présent/absent/tardif
```dart
Future<void> recordPresence(String studentId, String lesson) async {
  try {
    // Présent
    await context.read<AttendanceProvider>().markPresent(
      studentId: studentId,
      markazId: 'markaz_001',
      lesson: lesson,
    );
    
    // Absent (alternative)
    // await context.read<AttendanceProvider>().markAbsent(...)
    
    // Tardif (alternative)
    // await context.read<AttendanceProvider>().markLate(...)
    
    showSuccessMessage('Présence enregistrée');
  } catch (e) {
    showErrorMessage(e.toString());
  }
}
```

### Afficher le taux de présence
```dart
class AttendanceRate extends StatelessWidget {
  final String studentId;
  
  @override
  Widget build(BuildContext context) {
    final provider = context.read<AttendanceProvider>();
    
    // Taux hebdomadaire
    final weekly = provider.getWeeklyAttendanceRate(studentId);
    final monthly = provider.getMonthlyAttendanceRate(studentId);
    
    return Column(
      children: [
        // Semaine actuelle
        Text('Taux ces 7 derniers jours: ${weekly['attendanceRate']}'),
        Text('Statut: ${weekly['status']}'), // EXCELLENT, BON, etc.
        Text('Présences: ${weekly['presentCount']}'),
        Text('Absences: ${weekly['absentCount']}'),
        Text('Tardives: ${weekly['lateCount']}'),
        
        SizedBox(height: 16),
        
        // Mois actuel
        Text('Taux ce mois-ci: ${monthly['attendanceRate']}'),
        Text('Recommandation: ${monthly['recommendedAction']}'),
      ],
    );
  }
}
```

### Générer un rapport
```dart
Future<void> generateReports() async {
  try {
    final weeklyReport = await context.read<AttendanceProvider>().generateWeeklyReport();
    final monthlyReport = await context.read<AttendanceProvider>().generateMonthlyReport(
      month: 10,
      year: 2026,
    );
    
    // Phase 5: Intégrer PDF library
    debugPrint('Rapport semaine: ${weeklyReport['reportType']}');
    debugPrint('Rapport mois: ${monthlyReport['reportType']}');
    
  } catch (e) {
    showErrorMessage(e.toString());
  }
}
```

---

## 🔐 EXEMPLE 5: Authentification (Multi-Markaz)

### Login
```dart
Future<void> login(String email, String password) async {
  try {
    final user = await context.read<AuthService>().login(
      email: email,
      password: password,
      markazId: _markazSelector, // Selectionné par l'utilisateur
    );
    
    // ✅ Succès - Charger les données
    await context.read<StudentProvider>().loadStudents();
    await context.read<PaymentProvider>().loadPayments();
    await context.read<AttendanceProvider>().loadAttendances();
    
    // Naviguer vers Home
    Navigator.of(context).pushReplacementNamed('/home');
    
  } catch (e) {
    showErrorMessage(e.toString());
  }
}
```

### Vérifier l'utilisateur actuel
```dart
class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    
    if (user == null) {
      return const Text('Non authentifié');
    }
    
    return Column(
      children: [
        Text('Utilisateur: ${user.name}'),
        Text('Email: ${user.email}'),
        Text('Rôle: ${user.role}'),
        Text('Markaz: ${user.markazId}'),
        
        ElevatedButton(
          onPressed: () async {
            await authService.logout();
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
```

---

## ⚠️ EXEMPLE 6: Gestion des erreurs

```dart
Future<void> addStudentWithErrorHandling() async {
  try {
    final provider = context.read<StudentProvider>();
    
    await provider.addStudent(
      name: _nameController.text,
      parentPhone: _phoneController.text,
    );
    
    // Succès - Clear error
    provider.clearError();
    showSuccessMessage('Étudiant ajouté');
    
  } catch (e) {
    // Erreur - Afficher explicitament
    showErrorDialog(
      title: 'Erreur',
      message: e.toString(),
    );
  }
}

// Afficher la dernière erreur du provider
class ErrorDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        if (provider.errorMessage == null) {
          return const SizedBox.shrink();
        }
        
        return Container(
          color: Colors.red.shade100,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error),
              const SizedBox(width: 8),
              Expanded(child: Text(provider.errorMessage!)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => provider.clearError(),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

---

## 🧪 EXEMPLE 7: PATTERN COMPLET - Écran d'ajouter élève

```dart
class AddStudentScreen extends StatefulWidget {
  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    setState(() => _isLoading = true);
    
    try {
      await context.read<StudentProvider>().addStudent(
        name: _nameController.text,
        parentPhone: _phoneController.text,
      );
      
      // Reset et succès
      _nameController.clear();
      _phoneController.clear();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Élève ajouté avec succès')),
      );
      
      // Recharger la liste
      await context.read<StudentProvider>().loadStudents();
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter Élève')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Téléphone Parent'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _addStudent,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎨 EXEMPLE 8: LISTE avec filtrage

```dart
class StudentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Élèves')),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          // Afficher erreur si existe
          if (provider.errorMessage != null) {
            return Center(
              child: Text('Erreur: ${provider.errorMessage}'),
            );
          }
          
          // Contenu
          return ListView.builder(
            itemCount: provider.students.length,
            itemBuilder: (context, index) {
              final student = provider.students[index];
              
              return ListTile(
                title: Text(student.name),
                subtitle: Text(student.parentPhone),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Éditer'),
                      onTap: () => _editStudent(context, student),
                    ),
                    PopupMenuItem(
                      child: const Text('Supprimer'),
                      onTap: () => _deleteStudent(context, student.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/add-student'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteStudent(BuildContext context, String studentId) async {
    try {
      await context.read<StudentProvider>().removeStudent(studentId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Élève supprimé')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _editStudent(BuildContext context, Student student) {
    // TODO: Implémenter edit dialog
    throw UnimplementedError();
  }
}
```

---

## 📋 CHECKLIST D'UTILISATION

Avant d'utiliser un service:

- [ ] Importer: `import 'package:markazi/services/index.dart';`
- [ ] Accéder au provider: `context.read<StudentProvider>()`
- [ ] Utiliser méthode service: `await provider.addStudent(...)`
- [ ] Gérer erreurs: try/catch
- [ ] Afficher feedback: SnackBar ou Dialog
- [ ] Recharger données si nécessaire: `provider.loadStudents()`
- [ ] Clear erreurs: `provider.clearError()`

---

## 🚀 BONNES PRATIQUES

| ✅ FAIRE | ❌ NE PAS FAIRE |
|---------|-----------------|
| Utiliser `context.read<Provider>().addStudent()` | Appeler directement `_repository.addStudent()` |
| Gérer les exceptions | Ignorer les erreurs |
| Afficher feedback utilisateur | Silent failures |
| Valider avant soumettre | Soumettre n'importe quoi |
| Load data au startup | Ne rien charger |
| Set isLoading state | UI sans feedback |
| Clear errors dans UI | Afficher erreurs anciennes |

---

## 📞 SUPPORT

Pour des questions sur l'utilisation des services:
1. Vérifier les exemples ci-dessus
2. Lire la documentation du service (commentaires dans le code)
3. Consulter PHASE4_COMPLETE.md pour architecture
4. Vérifier attendanceservice.dart pour patterns complexes

