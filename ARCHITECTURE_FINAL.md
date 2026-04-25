# MARKAZI PROJECT - ARCHITECTURE FINALISÉE

## 📊 ARCHITECTURE GLOBALE (Phase 1-3)

```
┌─────────────────────────────────────────────────────────────┐
│                      UI LAYER (Écrans)                       │
│  • SplashScreen / OnboardingScreen / HomeScreen / etc.       │
│  • 8 CustomWidgets (MarkaziLogo, FeatureCard, Buttons, etc) │
└──────────────────┬──────────────────────────────────────────┘
                   │ Consumer / context.read
                   ↓
┌─────────────────────────────────────────────────────────────┐
│                    PROVIDER LAYER                            │
│  (State Management + ChangeNotifier)                         │
│  • StudentProvider(StudentRepository _repo)                  │
│  • PaymentProvider(PaymentRepository _repo)                  │
│  • AttendanceProvider(AttendanceRepository _repo)            │
│                                                               │
│  Responsabilités:                                            │
│  - Écouter les changements                                   │
│  - Notifier les UI de changer                                │
│  - NOT: Logique métier, pas accès direct aux données         │
└──────────────────┬──────────────────────────────────────────┘
                   │ appelle
                   ↓
┌─────────────────────────────────────────────────────────────┐
│                   REPOSITORY LAYER                           │
│  (Data source abstraction)                                   │
│  • StudentRepository                                         │
│  • PaymentRepository                                         │
│  • AttendanceRepository                                      │
│                                                               │
│  Responsabilités:                                            │
│  - CRUD operations                                           │
│  - Filtrage / Recherche                                      │
│  - Agrégations (statistiques)                                │
│  - Interface vers Hive                                       │
└──────────────────┬──────────────────────────────────────────┘
                   │ utilise
                   ↓
┌─────────────────────────────────────────────────────────────┐
│              PERSISTENCE LAYER (Hive)                        │
│  Box<Student>      → TypeAdapter: StudentAdapter            │
│  Box<Payment>      → TypeAdapter: PaymentAdapter            │
│  Box<Attendance>   → TypeAdapter: AttendanceAdapter         │
│                                                               │
│  3 Hive Boxes:                                               │
│  - 'students'    : 1000-5000 élèves                         │
│  - 'payments'    : X000 paiements                            │
│  - 'attendances' : X0000 présences                           │
└──────────────────┬──────────────────────────────────────────┘
                   │ persiste sur
                   ↓
┌─────────────────────────────────────────────────────────────┐
│         STORAGE (Disque / IndexedDB)                         │
│  • Android: /data/data/markazi/hive/                        │
│  • iOS: Library/Application Support/markazi/                │
│  • Web: Browser IndexedDB                                   │
│  • Desktop: AppData directory                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 FLOW D'UNE OPÉRATION

### Exemple: Ajouter un élève

```
UI (Button)
    ↓ onPressed
context.read<StudentProvider>().addStudent(...)
    ↓
StudentProvider.addStudent()
    ↓
await _repository.addStudent(student)
    ↓
StudentRepository.addStudent()
    ↓ 
await _box.put(student.id, student)
    ↓
Hive → Disque
    ↓
_repository returns OK
    ↓
Provider: _students.add(student) + notifyListeners()
    ↓
Consumer rebuilds → UI updated
```

**Total latency:** ~50-100ms (très rapide!)

---

## 📦 DÉPENDANCES

```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.0.0              # État management
  equatable: ^2.0.5             # Comparaison d'objets
  uuid: ^4.0.0                  # Génération d'IDs
  hive: ^2.2.3                  # Base de données
  hive_flutter: ^1.1.0        # Hive pour Flutter
  path_provider: ^2.1.1         # Chemins du système
  google_fonts: ^6.1.0          # Polices
  smooth_page_indicator: ^1.1.0 # Indicateur pagination
  flutter_svg: ^2.0.7           # SVG support
  lottie: ^2.7.0                # Animations

dev_dependencies:
  build_runner: ^2.4.0          # Code generation
  hive_generator: ^2.0.0        # Hive adapters
```

---

## 📂 STRUCTURE DE FICHIERS

```
lib/
├── main.dart                      # Entry point + Hive init
├── models/
│   ├── student.dart               # @HiveType(0)
│   ├── payment.dart               # @HiveType(1,2)
│   ├── attendance.dart            # @HiveType(3,4)
│   ├── student.g.dart             # AUTO-GENERATED
│   ├── payment.g.dart             # AUTO-GENERATED
│   ├── attendance.g.dart          # AUTO-GENERATED
│   └── index.dart                 # Exports
├── repositories/
│   ├── student_repository.dart
│   ├── payment_repository.dart
│   ├── attendance_repository.dart
│   └── index.dart
├── providers/
│   ├── student_provider.dart
│   ├── payment_provider.dart
│   ├── attendance_provider.dart
│   └── index.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── features_screen.dart
│   └── about_screen.dart
├── widgets/
│   └── common_widgets.dart
├── utils/
│   ├── app_colors.dart
│   └── app_strings.dart
└── services/                      # Placeholder (Phase 4)
```

---

## 🎯 RESPONSABILITÉS PAR COUCHE

### UI (Écrans & Widgets)
✅ Afficher les données
✅ Capturez les interactions utilisateur
✅ Appeler context.read<Provider>()
❌ NE PAS: Logique métier, accès base de données

### Providers
✅ Gérer l'état global
✅ Notifier les UI des changements
✅ Appeler le repository
❌ NE PAS: Accès direct à Hive, logique complexe

### Repositories
✅ CRUD complet
✅ Filtrage & recherche
✅ Statistiques simples
✅ Interaction Hive exclusive
❌ NE PAS: Logique métier compliquée

### Hive
✅ Persistance
✅ Sérialisation
✅ Indexation
❌ NE PAS: Logique applicative

### Services (Phase 4)
✅ Logique métier
✅ Validations
✅ Calculs complexes
✅ Intégration API
❌ NE PAS: Accès données directement

---

## 🔌 INJECTION DE DÉPENDANCES

En `main.dart`:

```dart
// Créer les repositories
final studentRepository = StudentRepository();
final paymentRepository = PaymentRepository();
final attendanceRepository = AttendanceRepository();

// Initialiser (ouvrir Hive boxes)
await studentRepository.init();
await paymentRepository.init();
await attendanceRepository.init();

// Injecter dans les providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => StudentProvider(studentRepository),
    ),
    // ... autres providers
  ],
  child: const MarkaziApp(),
)
```

### Avantages:
✅ Providers testables (dépendance mockable)
✅ Repositories réutilisables (autre app peut les utiliser)
✅ Initialisation centralisée
✅ Zéro coupling entre couches

---

## ✨ PATTERNS UTILISÉS

### 1. Dependency Injection
```dart
StudentProvider(this._repository) // Repository injecté
```
→ Permet les tests et la réutilisabilité

### 2. Repository Pattern
```dart
class StudentRepository {
  Future<void> addStudent(Student s) async { }
  List<Student> getAllStudents() { }
  // ...
}
```
→ Abstraction de la source de données

### 3. ChangeNotifier (Observer Pattern)
```dart
class StudentProvider extends ChangeNotifier {
  notifyListeners() // Notifie les observers
}
```
→ Réactivité automatique de l'UI

### 4. Type Adapters (Strategy Pattern)
```dart
@HiveType(typeId: 0)
class Student { }
// Adapter generator crée StudentAdapter
```
→ Sérialisation sans JSON

### 5. Separation of Concerns
```
UI ← Provider ← Repository ← Hive
```
→ Chaque couche a une responsabilité unique

---

## 🚀 MIGRATION VERS FIREBASE (Phase 4)

Aucun refactoring majeur nécessaire!

```dart
// Phase 3: Hive
class StudentRepository {
  Box<Student> _box;
  // ...
}

// Phase 4: Hive + Firestore
class StudentRepository {
  Box<Student> _box;           // Local cache
  FirebaseFirestore firestore; // Remote source
  
  Future<void> sync() {
    // Sync local ↔ remote
  }
}

// UI et providers: AUCUN CHANGEMENT!
```

Les repositories absorbent la complexité → UI reste simple

---

## 📈 PERFORMANCE

### Vitesses (Approximatives)

| Opération | Temps |
|-----------|-------|
| add() | 5-10ms |
| get(id) | 1-2ms |
| getAll() | 30-50ms (1000 records) |
| filter() | 50-100ms (1000 records) |
| update() | 5-10ms |
| delete() | 5-10ms |

### Mémoire

- Hive: Très faible overhead
- 10,000 records ≈ 1-2 MB
- Adapters: ~100KB par type

### Disque

- Hive très compact (binary)
- 10,000 records ≈ 2-5 MB
- Bien mieux que JSON/SQLite

---

## 🔐 SÉCURITÉ

### Actuellement
✅ Données valides (typeId)
✅ Pas d'injection (typed)
✅ Validations au save

### À faire (Phase 4)
☐ Chiffrement Hive (optionnel)
☐ Validation Firebase Security Rules
☐ Authentification utilisateur
☐ HTTPS pour toutes les API

---

## 🧪 TESTABILITÉ

### Tester un Provider
```dart
test('StudentProvider.addStudent', () {
  final mockRepo = MockStudentRepository();
  final provider = StudentProvider(mockRepo);
  
  provider.addStudent(...);
  
  expect(provider.totalStudents, 1);
  expect(mockRepo.addCalled, true);
});
```

### Tester un Repository
```dart
test('StudentRepository.getStudentsByMarkaz', () {
  final repo = StudentRepository(); // Ou MockedHive
  
  await repo.init();
  await repo.addStudent(...);
  
  final results = repo.getStudentsByMarkaz('m1');
  expect(results.length, 1);
});
```

---

## 📋 CHECKLIST DE VÉRIFICATION

- [x] Modèles avec @HiveType annotations
- [x] Adapters générés automatiquement
- [x] Repositories avec CRUD complet
- [x] Providers injectant repositories
- [x] main.dart initialisant Hive
- [x] MultiProvider avec dépendances
- [x] Écrans consommant providers
- [ ] Tests unitaires (Phase 4)
- [ ] Tests d'intégration (Phase 4)
- [ ] Firebase intégration (Phase 4)

---

## 🎓 CONCLUSION

Markazi Project a une architecture complète et scalable:

✅ **Clean Architecture** réalisée
✅ **Persistance locale** opérationnelle
✅ **Injection de dépendances** correcte
✅ **Séparation des responsabilités** stricte
✅ **Prêt pour Firebase** sans refactor

Prochaine phase: **Services + Firebase** 🚀

