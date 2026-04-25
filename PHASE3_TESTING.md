# 🧪 PHASE 3 - TEST DE PERSISTANCE

## Tester que les données persistent après fermeture de l'app

### Test 1: Ajouter un élève et vérifier la persistance

**Étape 1:** Ajouter du code dans HomeScreen ou FeaturesScreen:

```dart
import 'package:provider/provider.dart';

ElevatedButton(
  onPressed: () {
    context.read<StudentProvider>().addStudent(
      name: 'Test Persistence',
      parentPhone: '+212612345678',
      markazId: 'markaz_test'
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Student added & saved!'))
    );
  },
  child: const Text('Add Test Student'),
)
```

**Étape 2:** Afficher le nombre d'élèves:

```dart
Consumer<StudentProvider>(
  builder: (context, provider, _) {
    return Text(
      'Total: ${provider.totalStudents} élèves',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  },
)
```

**Étape 3:** Test de persistance:
1. Lancer l'app `flutter run -d edge`
2. Cliquer "Add Test Student"
3. Vérifier: "Total: 1 élèves"
4. Fermer complètement l'app (Quit)
5. Relancer: `flutter run -d edge`
6. ✅ VÉRIFIER: Toujours "Total: 1 élèves" ← **LES DONNÉES PERSISTENT**

---

### Test 2: Ajouter plusieurs élèves

```dart
// Ajouter 3 élèves rapidement
ElevatedButton(
  onPressed: () async {
    final provider = context.read<StudentProvider>();
    
    for (int i = 1; i <= 3; i++) {
      await provider.addStudent(
        name: 'élève $i',
        parentPhone: '123456$i',
        markazId: 'markaz_001'
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ 3 élèves ajoutés!'))
    );
  },
  child: const Text('Add 3 Students'),
)
```

Test:
1. Ajouter 3 élèves → "Total: 3 élèves"
2. Fermer l'app
3. Relancer
4. ✅ VÉRIFIER: "Total: 3 élèves"

---

### Test 3: Paiements persistants

```dart
ElevatedButton(
  onPressed: () {
    final studentId = 'test_student_001';
    
    context.read<PaymentProvider>().addPayment(
      studentId: studentId,
      markazId: 'markaz_001',
      amount: 500.0,
      status: PaymentStatus.unpaid
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Payment added!'))
    );
  },
  child: const Text('Add Payment'),
)
```

Observer:
```dart
Consumer<PaymentProvider>(
  builder: (context, provider, _) {
    return Text(
      'Paiements: ${provider.payments.length}',
      style: const TextStyle(fontSize: 18),
    );
  },
)
```

Test:
1. Ajouter un paiement
2. Fermer l'app
3. Relancer
4. ✅ Le paiement est toujours là

---

### Test 4: Marquer une présence

```dart
ElevatedButton(
  onPressed: () {
    context.read<AttendanceProvider>().markPresent(
      'test_student_001',
      'markaz_001',
      'Sourate Al-Fatiha'
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Présent!'))
    );
  },
  child: const Text('Mark Present'),
)
```

Observer:
```dart
Consumer<AttendanceProvider>(
  builder: (context, provider, _) {
    final count = provider.attendances.length;
    return Text('Présences: $count');
  },
)
```

Test:
1. Marquer présent
2. Fermer l'app
3. Relancer
4. ✅ La presence est toujours enregistrée

---

## 📊 Statistiques persistantes

Tester que les statistiques sont correctes après reload:

```dart
// Ajouter 10 présences (7 present, 3 absent)
for (int i = 0; i < 7; i++) {
  await provider.markPresent('student_001', 'markaz_001', 'Lesson');
}

for (int i = 0; i < 3; i++) {
  await provider.markAbsent('student_001', 'markaz_001');
}

// Calculer le taux
final rate = provider.getAttendanceRateForStudent('student_001');
// rate = 70.0% (7/10)
```

Test persistance du taux:
1. Calculer: 70.0%
2. Fermer l'app
3. Relancer
4. ✅ Le taux est toujours 70.0% (car les données persistent)

---

## 🔍 VÉRIFIER LA SAUVEGARDE SUR DISQUE

**Hive sauvegarde sur:**

- **Web (Edge):** IndexedDB du navigateur
  - Développeur Tools → Application → Storage → Indexed DB
  - Vous devriez voir: `students`, `payments`, `attendances`

- **Mobile (Android):** `/data/data/com.example.markazi/hive/`
  - Accédé via: `adb shell`
  - Fichiers: `students.hive`, `payments.hive`, `attendances.hive`

- **Desktop (Windows):** 
  - `C:\Users\{USER}\AppData\Local\markazi\hive\`

---

## ✅ CHECKLIST DE TEST

- [ ] Ajouter élève → Persiste après fermeture
- [ ] Ajouter paiement → Persiste après fermeture  
- [ ] Marquer présence → Persiste après fermeture
- [ ] Statistiques correctes après reload
- [ ] Multiple adds (5+ élèves) → Tous persistent
- [ ] Total count correct après reload
- [ ] Filtrer par markazId → Retourne les bons
- [ ] Supprimer un élève → Suppression persistante
- [ ] Vider tout (clearAll) → Tous les records effacés

---

## 🐛 DEBUGGING

Si les données ne persistent pas:

1. **Vérifier Hive logs:**
   ```
   flutter run -d edge --debug 2>&1 | grep -i hive
   ```
   Vous devriez voir: `Got object store box in database student

s`

2. **Vérifier Box names:**
   ```dart
   final studentBox = Hive.box('students');
   print('Box length: ${studentBox.length}'); // Devrait être > 0
   ```

3. **Vérifier adapters:**
   ```dart
   print(Hive.registeredAdapters); // Vous devriez voir 5 adapters
   ```

4. **Forcer le close/open:**
   ```dart
   await Hive.close();
   await StudentRepository().init(); // Réouvre
   ```

---

## 📝 RÉSULTATS ATTENDUS

Après la Phase 3:

✅ Les données persistent automatiquement
✅ Aucun code supplémentaire pour la sauvegarde
✅ Les repositories gèrent tout
✅ Les providers restent simples
✅ Les UI deviennent intelligentes

C'est exactement le pattern Clean Architecture!

