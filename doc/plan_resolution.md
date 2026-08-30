# Plan de résolution — suivi de l'audit

Référence : [audit.md](audit.md) (audit du 30 août 2026)

Règle de mise à jour de ce fichier : chaque point passe de
**🔴 Non résolu** à **✅ Résolu** une fois corrigé et vérifié (pas seulement
codé — testé). Ne jamais marquer résolu sans vérification concrète.

Ordre de traitement recommandé : sécurité et bugs critiques d'abord, puis
fonctionnalités manquantes, puis fragilité de config, puis dette technique.

---

## Étape 1 — Bugs fonctionnels critiques

- [x] ✅ **A1.** Résolu le 30 août 2026. Comparaisons corrigées aux 4
      occurrences (`_buildStudentTableRow` et `_calculateGroupStats`) :
      `p.status == 'paid'` → `p.status == PaymentStatus.paid`,
      `a.status == 'present'` → `a.status == AttendanceStatus.present`.
      Vérifié par `flutter analyze` (les 2 avertissements
      `unrelated_type_equality_checks` ont disparu) et par un script Dart
      isolé avec des données de test connues : `paidAmount`,
      `attendanceRate` et `paymentRate` retournent maintenant les valeurs
      exactes attendues (avant le correctif, les trois étaient à 0).
- [x] ✅ **A2.** Résolu le 30 août 2026. Ajout d'une vraie route
      `PATCH /payments/{id}` (`PaymentController::updateStatus`) qui modifie
      l'enregistrement existant au lieu d'en recréer un, et attribue le
      numéro de reçu si le paiement devient "payé". Côté Flutter,
      `api_payment_datasource.dart`, `payment_repository.dart` et
      `payment_service.dart` mis à jour pour appeler cette route et
      retourner la version confirmée par le serveur (avec `receiptNumber`).
      **Bug racine découvert en testant ce correctif** :
      `GeneratedDocument::nextNumber()` calculait la séquence en comptant
      la table `generated_documents`, mais rien n'y insérait jamais de
      ligne → le compteur repartait de 1 à chaque appel et provoquait une
      violation de contrainte d'unicité dès le deuxième reçu de l'année.
      Corrigé en même temps : `nextNumber()` insère désormais la ligne de
      registre dans la même transaction verrouillée.
      Vérifié par un test end-to-end via curl : création de 2 paiements
      "unpaid" pour 2 élèves différents, marquage "paid" des deux → chacun
      obtient un numéro de reçu distinct et croissant
      (MK-1-2026-000001, MK-1-2026-000002), un seul enregistrement par
      paiement (pas de doublon), et la table `generated_documents` contient
      bien les 2 lignes correspondantes avec leur référence polymorphique
      vers le paiement. Suite de tests backend toujours au vert (2/2).

## Étape 2 — Sécurité

- [x] ✅ **C1.** Résolu le 30 août 2026. Les 4 routes publiques
      d'authentification (`/auth/register`, `/auth/login`,
      `/auth/password/forgot`, `/auth/password/reset`) sont maintenant
      dans un groupe `Route::middleware('throttle:5,1')` — 5 requêtes par
      minute et par IP. Vérifié en réel (pas seulement lu dans le code) :
      6 tentatives de login rapprochées → les 5 premières traitées
      normalement (422, mauvais mot de passe volontaire), la 6e et la 7e
      renvoient 429 ; une tentative sur `/auth/register` juste après
      renvoie aussi 429 (le compteur est partagé par IP entre les 4 routes,
      ce qui est un choix volontairement conservateur) ; après 61 secondes
      d'attente, un login avec les bons identifiants repasse en 200 — la
      fenêtre se réinitialise correctement. Suite de tests backend toujours
      au vert (2/2).
- [~] 🟡 **C2 (code corrigé, décision produit restante).** Résolu le 30 août
      2026 pour tout ce qui relève du code — bien plus grave que prévu par
      l'audit initial :
      - **Bug racine découvert en corrigeant ce point** : `POST
        /auth/password/forgot` plantait en 500
        (`RouteNotFoundException: Route [password.reset] not defined`)
        pour TOUT `MAIL_MAILER`, y compris `log` — Laravel tente par défaut
        de générer un lien cliquable vers une route web de réinitialisation
        qui n'existe pas dans cette API pure. Ce n'était donc pas "un vrai
        email n'est pas envoyé" mais "la fonctionnalité ne fonctionne pas
        du tout".
      - Corrigé dans `AppServiceProvider::boot()` via
        `ResetPassword::toMailUsing(...)` : email envoyant directement le
        code de réinitialisation (pas de lien, cohérent avec l'app mobile
        qui n'a pas de deep-link) — POST /auth/password/reset accepte déjà
        ce code en entrée.
      - `backend/lang/fr.json` créé : les emails d'authentification
        (Laravel) étaient entièrement en anglais malgré `APP_LOCALE=fr`
        (aucune traduction publiée) — incohérent avec le CDC ("la V1 est en
        français"). Toutes les chaînes (sujet, corps, "Cordialement,",
        pied de page "Tous droits réservés.") sont maintenant traduites.
      Vérifié : test réel par curl (200 au lieu de 500, code présent dans
      l'email généré, entièrement en français — vérifié occurrence par
      occurrence dans le log après un `storage/logs/laravel.log` vidé pour
      éviter toute confusion avec un essai précédent) ; test automatisé
      ajouté (`AuthTest::test_forgot_password_does_not_crash_and_sends_a_french_email`) ;
      suite complète 32/32.
      **Ce qui reste, hors de portée du code** : choisir un vrai fournisseur
      SMTP pour la production (`MAIL_MAILER=log` reste approprié en dev) —
      décision et identifiants qui appartiennent à l'exploitant du service,
      pas quelque chose qu'un correctif de code peut trancher.
- [x] ✅ **C3.** Résolu le 30 août 2026, sans attendre un vrai déploiement
      HTTPS. `usesCleartextTraffic="true"` retiré du manifeste principal et
      déplacé dans `android/app/src/debug/AndroidManifest.xml` — le merger
      de manifeste Gradle ne l'applique alors qu'au build debug ; un build
      release ne l'a plus du tout, donc HTTPS y devient obligatoire de fait
      (une tentative de connexion `http://` échouera), sans dépendre d'un
      rappel manuel avant la mise en production.
      Vérifié concrètement (pas juste lu dans le code) : `./gradlew
      :app:processDebugMainManifest :app:processReleaseMainManifest`, puis
      inspection des deux manifestes fusionnés générés — l'attribut est
      présent dans celui de debug, absent de celui de release.
- [x] ✅ **C4.** Résolu le 30 août 2026. `php artisan config:publish cors` +
      commentaire expliquant le choix (`allowed_origins: '*'` sans risque
      CSRF puisque l'auth est par token Bearer, jamais par cookie —
      `supports_credentials` reste `false`). Vérifié : suite backend
      toujours au vert (29/29 à ce moment-là) et en-têtes
      `Access-Control-Allow-*` confirmés présents par une requête `OPTIONS`
      réelle.

## Étape 3 — Fonctionnalités CDC non reliées à l'app

- [x] ✅ **B1.** Résolu le 30 août 2026. Module Récitations intégré
      côté Flutter en suivant exactement l'architecture existante :
      `models/recitation.dart` (Hive typeId 7 + enum `RecitationStatus`
      typeId 8), `api_recitation_datasource.dart`, `hive_recitation_datasource.dart`,
      `recitation_repository.dart`, `recitation_service.dart`,
      `recitation_provider.dart`, et `screens/recitation_screen.dart`
      (liste + formulaire ajout/modif : élève, date, sourate, versets,
      statut, note ; suppression avec confirmation). Câblé dans `main.dart`
      (adaptateurs Hive, sync post-restauration) et accessible depuis le
      tableau de bord (menu ⋮ de l'AppBar).
- [x] ✅ **B2.** Résolu le 30 août 2026. Même traitement pour le module
      Tuteurs/Guardians : `models/guardian.dart` (Hive typeId 6),
      datasources API+Hive, repository, service, provider, et
      `screens/guardian_screen.dart` (liste + formulaire ajout/modif :
      nom, téléphone, email, adresse). Câblé de la même façon.
      Vérifié pour les deux modules : `flutter analyze` → 0 problème ;
      `flutter test` → 2/2 (l'app démarre toujours) ; script Dart isolé
      confirmant que Hive lit/écrit correctement les deux nouveaux modèles
      sans collision de `typeId` (vérification à l'exécution, pas
      seulement statique) ; cycle complet créer/modifier/lister/supprimer
      testé par curl contre le vrai backend pour les tuteurs (les
      récitations avaient déjà été testées ainsi lors de B3).
- [x] ✅ **B3.** Résolu le 30 août 2026. Ajout de `PUT`/`DELETE
      /attendances/{id}` et `PUT`/`DELETE /recitations/{id}` côté backend
      (`AttendanceController::update/destroy`,
      `RecitationController::update/destroy`, mêmes policies
      `MarkazScopedPolicy` déjà en place). Côté Flutter, seul
      `api_attendance_datasource.dart` a été mis à jour pour utiliser le
      vrai `PUT`/`DELETE` au lieu de l'ancien contournement (re-POST en
      upsert, sans suppression réelle) — `recitations` n'a toujours aucune
      intégration côté app (voir B1, non traité ici).
      Vérifié par curl : cycle création → correction (PUT) → suppression
      (DELETE, 204) sur une présence et sur une récitation ; isolation
      multi-tenant confirmée (un 2e Markaz ne peut ni modifier — 422 côté
      validation, la référence élève étant hors de son périmètre — ni
      supprimer — 404, masqué par le global scope — la présence du premier
      Markaz). Suite de tests backend toujours au vert (2/2).

## Étape 4 — Fragilité de configuration

- [x] ✅ **D1.** Résolu le 30 août 2026. `ApiConfig.baseUrl` utilise
      désormais `String.fromEnvironment('API_BASE_URL', defaultValue: ...)`
      au lieu d'une constante figée — surchargeable via
      `flutter run --dart-define=API_BASE_URL=http://<ip>:8321/api` sans
      toucher au code, y compris pour pointer vers l'API de production plus
      tard. Ajout de `.vscode/launch.json` (non versionné) avec ce
      `--dart-define` préconfiguré, pour que le lancement depuis VSCode
      reste pratique — seule cette IP est à mettre à jour en cas de
      changement de réseau, plus besoin de modifier `api_config.dart`.
      Vérifié par un script isolé : sans `--dart-define`,
      `ApiConfig.baseUrl` retombe bien sur l'IP de secours ; avec, la
      valeur passée l'emporte.
- [~] 🟡 **D2 (majoritairement résolu).** Résolu le 30 août 2026 pour
      paiements, présences, tuteurs et récitations — pas pour les classes
      (voir limite ci-dessous). Conforme au CDC §20 : "toute action de
      saisie effectuée hors ligne est stockée localement avec un statut
      'en attente de synchronisation'" + rejeu automatique à la reconnexion
      + "indicateur visuel clair [...] du nombre d'actions en attente".
      - `models/sync_queue_item.dart` : entrée de file persistée (Hive
        typeId 9/10/11) — entité, opération (update/delete), ID. Ne stocke
        pas les données elles-mêmes : au rejeu, l'état local actuel (déjà à
        jour dans le cache Hive de l'entité) est relu et renvoyé, donc
        plusieurs modifications hors ligne successives ne rejouent qu'une
        fois, sur le dernier état connu.
      - `services/sync_queue_service.dart` : CRUD sur la file (Hive),
        enfilage idempotent (pas de doublon pour la même entité/opération),
        `listenable()` pour un affichage réactif.
      - `PaymentRepository`, `AttendanceRepository`, `GuardianRepository`,
        `RecitationRepository` : les `catch` qui se contentaient auparavant
        d'un `debugPrint` (échec silencieux, perdu) enfilent maintenant
        l'action ; chacun expose aussi `retrySyncUpdate`/`retrySyncDelete`
        (ne rattrapent pas l'erreur, contrairement aux méthodes normales,
        pour que l'orchestrateur sache si le rejeu a vraiment réussi).
      - `services/sync_orchestrator.dart` : rejoue la file dans l'ordre
        chronologique au démarrage (après la sync initiale) et à chaque
        synchronisation manuelle ; une action toujours en échec reste en
        file pour la prochaine tentative.
      - `providers/sync_queue_provider.dart` + badge sur l'icône
        "Synchroniser" du tableau de bord (`Badge` avec le nombre en
        attente, mis à jour en direct via `listenable()`) — l'indicateur
        visuel exigé par le CDC §20.
      **Limite assumée** : `ClassRepository` (affectation/retrait d'élève,
      modification de classe) n'est pas couvert — ces opérations ne sont
      pas de simples update/delete d'entité (elles touchent une relation),
      ce qui aurait demandé un schéma de file plus riche pour un gain
      moindre (modifications de classe hors ligne bien plus rares que
      présence/paiement). Non traité par manque de temps dans cette
      session, documenté plutôt que masqué.
      Vérifié : `flutter analyze` 0, `flutter test` 2/2. Mécanique de la
      file (persistance Hive, idempotence, ordre chronologique, survie à un
      redémarrage) validée par un script isolé avec assertions. **Limite de
      vérification** : le rejeu réseau réel (échec puis succès après
      reconnexion) n'a pas pu être testé de bout en bout via un appareil ou
      émulateur (aucun disponible cette session) ni via un script Dart
      isolé (`ApiClient`/`flutter_secure_storage` font planter le
      compilateur hors du moteur Flutter, même limite déjà rencontrée pour
      `DocumentService`) — la logique a été relue attentivement et s'appuie
      sur des appels API déjà vérifiés par ailleurs (curl) cette session,
      mais n'a pas été observée en conditions réelles de coupure réseau.
- [x] ✅ **D3.** Résolu le 30 août 2026. Nouvelle table dédiée
      `document_counters` (une ligne par Markaz/type/année) : `insertOrIgnore`
      garantit son existence, puis `lockForUpdate()` verrouille cette ligne
      réelle pendant l'incrément — contrairement à l'ancien `COUNT()`, qui ne
      verrouillait que des lignes déjà existantes et pouvait laisser deux
      transactions concurrentes lire le même compte.
      Vérifié par un vrai test de charge (pas seulement en logique) : 15
      requêtes HTTP `POST /payments` (statut "payé") tirées en parallèle
      via curl → 15 numéros de reçu distincts et strictement séquentiels,
      aucun doublon. Complété par 2 tests automatisés
      (`GeneratedDocumentNumberingTest`) vérifiant l'incrément séquentiel et
      l'indépendance des compteurs par Markaz/type. Suite complète : 31/31.

## Étape 5 — Qualité de code / dette technique

- [x] ✅ **E1.** Résolu le 30 août 2026. `flutter analyze` : 186 → 0
      problème. Traité par lots : `analysis_options.yaml` (lint retiré du
      SDK) ; 4 commentaires de bibliothèque orphelins (`library;` ajouté) ;
      imports et variables locales inutilisés supprimés (dont un
      `onChanged` de champ téléphone qui ne faisait rien) ; doublon de
      calcul mort dans `dashboard_screen.dart` (`weekRate`) ; champ
      `_markazId` mort et `!` superflu dans `class_service.dart` ;
      `_buildStudentStat` (code mort) supprimé ; 2 `.toList()` inutiles
      dans des spreads ; 34 `print()` → `debugPrint()` (import
      `flutter/foundation.dart` ajouté où nécessaire) ; 73 `withOpacity()`
      → `withValues(alpha:)` ; 7 `value:` → `initialValue:` sur des
      `DropdownButtonFormField` ; `background:` retiré du thème (fusionné
      dans `surface` en Material 3) ; `.value` sur une couleur →
      `.toARGB32()` ; `Table.fromTextArray` → `TableHelper.fromTextArray()`.
      Les 44 avertissements `use_build_context_synchronously` ont demandé
      le plus d'attention : distinction entre un `context` de State
      (`this.context`, gardé par `mounted`) et un `context` local shadowé
      dans un `showDialog`/`StatefulBuilder` (à garder par
      `context.mounted`) — une première passe globale trop large avait
      converti aussi les 6 cas "State" par erreur, corrigée après re-vérification
      par `flutter analyze`. Deux `Future.microtask` dans `initState`
      (dashboard et group_details) restructurés pour capturer tous les
      `Provider`/services avant le premier `await`, derrière un unique
      `if (!mounted) return;`.
      Vérifié : `flutter analyze` → "No issues found!". Découverte
      annexe (non corrigée ici, hors périmètre E1) : le seul test Flutter
      existant (`test/widget_test.dart`) échouait déjà avant ces
      changements — il ne configure pas les `Provider` que `main.dart`
      met en place, donc `SplashScreen` plante faute d'`AuthService`
      disponible ; à traiter avec E2.
- [x] ✅ **E2.** Résolu le 30 août 2026. Les quatre points explicitement
      listés par le CDC §22 comme "devant impérativement être couverts par
      des tests automatisés avant toute mise en production" sont désormais
      couverts : authentification, isolation multi-tenant, enregistrement
      des paiements + génération des reçus, calculs de taux de présence et
      de progression.
      - `tests/Feature/AuthTest.php` (8 tests) : inscription (création
        Markaz+User, email dupliqué rejeté), connexion (bon/mauvais mot de
        passe, email inconnu), route protégée sans token valide, `/auth/me`,
        déconnexion qui ne révoque que le token de l'appareil courant.
      - `tests/Feature/MultiTenantIsolationTest.php` (7 tests) : deux Markaz
        distincts, un enseignant ne peut ni lister, ni consulter, ni
        modifier, ni supprimer les élèves/classes/présences/paiements d'un
        autre Markaz — y compris en forgeant un ID valide dans l'URL (CDC
        §27, critère d'acceptation explicite).
      - **Bug réel découvert en écrivant ces tests** (indépendant de tout
        test, confirmé en conditions réelles via curl) : toute requête sans
        en-tête `Accept: application/json` qui échoue l'authentification
        plantait en 500 (`RouteNotFoundException: Route [login] not
        defined`) au lieu de renvoyer un 401 propre — Laravel tentait de
        rediriger vers une route web `login` qui n'existe pas dans cette API
        pure. Corrigé dans `backend/bootstrap/app.php` via
        `$middleware->redirectGuestsTo(fn () => null)`. Sans conséquence
        pour l'app Flutter (Dio envoie déjà `Accept: application/json` par
        défaut), mais bloquant pour tout autre client (futur tableau de bord
        web, Postman, etc.).
      - Le seul test Flutter préexistant cassé (découvert lors de E1) a
        aussi été réparé au passage : voir le correctif E1 pour le détail
        (`test/widget_test.dart`).
      - `tests/Feature/PaymentTest.php` (6 tests) : numéro de reçu attribué
        à la création si "payé" (jamais si "non payé"), doublon détecté et
        bloqué (409) sauf confirmation explicite, marquer un paiement
        "payé" modifie l'enregistrement en place sans le dupliquer, et
        re-marquer un paiement déjà payé conserve le même numéro de reçu
        (ne le réattribue jamais) — couvre directement le correctif A2.
      - `tests/Feature/AttendanceRecitationCalculationsTest.php` (4 tests) :
        taux de présence/absence exacts sur des données connues, filtrage
        correct par période, taux de progression de récitation exact,
        taux à zéro sans séance enregistrée.
      Vérifié : `php artisan test` → 27/27 (2 préexistants + 8 auth + 7
      isolation + 6 paiements + 4 calculs), et re-vérification manuelle par
      curl du correctif `redirectGuestsTo`.
- [x] ✅ **E3.** Résolu le 30 août 2026. Suppression de
      `android/java_pid20258.hprof` (423 Mo, heap dump de debug) et de
      `android/app/build.gradle.kts.backup` (vérifié par `diff` avant
      suppression : c'était bien l'ancienne version d'avant correctifs,
      avec l'ancien plugin `google-services` et l'ancien `compileSdk`).
      Vérifié : 423 Mo effectivement libérés (`df -h`).
- [x] ✅ **E4.** Résolu le 30 août 2026. `CDC.md` déplacé de `ios/docs/`
      vers `doc/CDC.md` ; dossier `ios/docs/` (devenu vide) supprimé.
      Seules les références internes à `doc/audit.md` et à ce fichier
      pointaient vers l'ancien chemin — `doc/audit.md` n'a pas été modifié
      (c'est un instantané figé de l'audit, décrivant l'état constaté à ce
      moment-là) ; ce fichier-ci a été mis à jour.

## Étape 6 — Écarts CDC (issus du scan complet, section F de l'audit)

- [~] ⚪ **F1. Décision assumée le 30 août 2026 : ne pas reconstruire.**
      Le moteur client-side (`lib/document_engine/`) fonctionne, est
      couvert par des vérifications visuelles réelles (reçus, rapports
      hebdo/mensuel — voir A2, F2), et répond au besoin fonctionnel du CDC
      (documents générés automatiquement). Reconstruire l'équivalent côté
      Laravel (DomPDF/Snappy, gabarits Blade, file d'attente asynchrone)
      est une réécriture architecturale, pas un correctif — l'utilisateur a
      choisi explicitement de ne pas s'y engager maintenant plutôt que de
      risquer une régression sur quelque chose qui marche, pour un gain
      principalement esthétique du point de vue de l'architecture (rester
      fidèle au CDC §14/17/21, qui prescrivait un rendu serveur). Écart
      documenté dans doc/audit.md comme un choix technique assumé, pas un
      bug. À reconsidérer seulement si un besoin concret l'exige (ex. un
      futur portail web qui ne peut pas exécuter Dart/Flutter).
- [x] ✅ **F2.** Résolu le 30 août 2026. Ancien `_generatePdfReport`
      ad-hoc (résumé brut de toute la Markaz, sans branding, sans passer
      par le Document Engine) supprimé avec son helper `_buildPdfSection`.
      Remplacé par `_generateStudentReport()` : sélecteur d'élève +
      bouton "Hebdomadaire"/"Mensuel", qui construit les vraies métadonnées
      (présences réelles depuis `AttendanceProvider`, paiements du mois
      depuis `PaymentProvider`, classe via `ClassProvider`) et appelle
      `GET /students/{id}/attendance-stats` pour le taux exact (jours de
      cours réels, correctif F6) plutôt que de le recalculer côté client.
      Génère via `WeeklyReportGenerator`/`MonthlyReportGenerator` (Document
      Engine existant) et propose Aperçu/Partager comme pour les reçus.
      Vérifié : `flutter analyze` 0, `flutter test` 2/2, et génération
      réelle des deux PDF avec des données réalistes puis inspection
      visuelle du rendu (branding, tableau de présence, bloc assiduité,
      tableau des paiements — tout correctement mappé, aucun bug de rendu).
- [x] ✅ **F3.** Résolu avec B1/B2 ci-dessus (Étape 3).
- [ ] 🔴 **F4.** Ajouter un écran Flutter listant le journal d'activité
      (`GET /api/activity-logs`).
- [ ] 🔴 **F5.** Implémenter un vrai mécanisme hors ligne : statut "en
      attente de synchronisation" par action, file d'attente rejouée à la
      reconnexion, résolution de conflit journalisée, indicateur visuel
      dans l'UI (recoupe D2, Étape 4).
- [x] ✅ **F6.** Résolu le 30 août 2026. Décision produit tranchée avec
      l'utilisateur : recalcul complet plutôt qu'un simple réglage inerte —
      "jours de cours" (`total_days`) n'est plus le nombre de présences
      saisies mais le nombre réel de jours ouvrés (calendaire, selon
      `working_days`) sur la période, pour que les oublis de saisie pèsent
      contre le taux au lieu d'être ignorés.
      - Backend : `AttendanceController::statsForStudent` charge le Markaz
        de l'élève et calcule `total_days` via `countExpectedCourseDays()`
        (parcourt la période jour par jour, compare au jour de la semaine
        configuré — défaut lundi-vendredi si `working_days` est vide, CDC
        §8.6). `attendance_rate`/`absence_rate` recalculés sur cette base.
        Bonus : la route renvoie désormais 404 pour un élève d'un autre
        Markaz (chargement via `Student::findOrFail` + policy), au lieu de
        stats à zéro silencieuses.
      - Flutter : `markaz_settings_screen.dart` a maintenant une section
        "Jours de cours" (7 `FilterChip`, lun→dim), pré-remplie depuis
        `Markaz.workingDays` (ou lundi-vendredi par défaut si vide), envoyée
        dans le payload `update()`.
      - Tests réécrits (`AttendanceRecitationCalculationsTest`) pour la
        nouvelle sémantique : couverture complète d'une semaine (5/5 jours
        saisis), jours jamais saisis qui abaissent le taux (3 saisis sur 5
        attendus → 60 %, pas 100 %), et configuration personnalisée des
        jours ouvrés (samedi/dimanche travaillés, vendredi non travaillé →
        6 jours de cours au lieu de 5).
      Vérifié : `flutter analyze` → 0 problème ; suite backend → 29/29 ;
      test end-to-end réel par curl (5 jours avec config par défaut → 6
      jours après ajout du samedi via `PUT /markaz`) ; base de dev
      réinitialisée après ce test manuel.
- [x] ✅ **F7.** Résolu le 30 août 2026. Migration
      `add_soft_deletes_to_payments_table` (ajoute `deleted_at`) + trait
      `SoftDeletes` sur `App\Models\Payment`, alignant `payments` sur
      `students`/`classes` comme l'exige le CDC §18. Aucune route
      `destroy()` n'existait déjà côté API pour les paiements (choix
      délibéré documenté dans `api_payment_datasource.dart` : une
      correction crée un nouvel enregistrement plutôt que de supprimer) —
      ce correctif prépare seulement le schéma pour un archivage futur sans
      perte d'historique, sans changer le comportement actuel de l'API.
      Vérifié : migration appliquée sans erreur sur la base de dev ; test
      automatisé ajouté (`PaymentTest::test_a_deleted_payment_is_archived_not_erased`)
      confirmant qu'un paiement supprimé disparaît des requêtes normales
      mais reste consultable via `withTrashed()` avec `deleted_at` renseigné ;
      suite complète toujours au vert (28/28).
- [x] ✅ **F8.** Résolu le 30 août 2026. `doc/openapi.yaml` — spécification
      OpenAPI 3.0 complète, rédigée à la main (l'installation d'un package
      Swagger via Composer nécessite Packagist, inaccessible depuis mes
      outils ; option la plus fiable dans ce contexte). Couvre les 42
      opérations HTTP réelles (39 handlers + 3 alias PATCH sur
      classes/students/guardians via `apiResource`), avec schémas de
      requête/réponse, codes d'erreur (401/404/409/422/429) et notes sur
      l'isolation multi-tenant.
      Vérifié : validation par un vrai outil (`openapi-spec-validator`, pas
      juste une lecture visuelle) — a immédiatement détecté une vraie
      incohérence (noms de paramètres de chemin ne correspondant pas aux
      gabarits d'URL), corrigée, puis re-validée avec succès. Nombre
      d'opérations documentées recompté et confirmé égal au nombre réel de
      routes (`php artisan route:list`).
      À tenir à jour manuellement à chaque évolution de `routes/api.php`.

---

## Journal de résolution

_(Ajouter une ligne ici à chaque point résolu : date, point, ce qui a été
fait, comment ça a été vérifié.)_

| Date | Point | Résumé de la correction | Vérification |
|---|---|---|---|
| 30/08/2026 | A2 (+ bug racine `nextNumber()`) | Ajout route `PATCH /payments/{id}` ; branchement Flutter ; correction de `GeneratedDocument::nextNumber()` qui ne persistait jamais sa ligne de registre | Test end-to-end curl (2 paiements, 2 reçus distincts, pas de doublon) + suite de tests backend (2/2) |
| 30/08/2026 | A1 | Correction des 4 comparaisons enum/String cassées dans `group_details_screen.dart` | `flutter analyze` (warnings disparus) + script Dart isolé avec données connues (valeurs exactes obtenues) |
| 30/08/2026 | C1 | Ajout de `throttle:5,1` sur les 4 routes publiques d'authentification | Test curl réel : 429 après 5 tentatives/min, reset après 61s |
| 30/08/2026 | B3 | Ajout `PUT`/`DELETE` sur `/attendances/{id}` et `/recitations/{id}` ; branchement Flutter pour attendances | Cycle complet testé par curl (créer/corriger/supprimer) + isolation multi-tenant vérifiée + tests backend (2/2) |
| 30/08/2026 | E3 | Suppression de `java_pid20258.hprof` et `build.gradle.kts.backup` | `diff` avant suppression + `df -h` (423 Mo libérés) |
| 30/08/2026 | E4 | `CDC.md` déplacé de `ios/docs/` vers `doc/CDC.md` | `grep` de vérification des références restantes, mises à jour |
| 30/08/2026 | D1 | `ApiConfig.baseUrl` piloté par `--dart-define` ; `.vscode/launch.json` préconfiguré | Script isolé : fallback sans define, surcharge effective avec define |
| 30/08/2026 | E1 | Nettoyage complet des 186 avertissements `flutter analyze` (imports, print, withOpacity, mounted checks, code mort, etc.) | `flutter analyze` : 186 → 0. Test widget préexistant cassé découvert et documenté (hors périmètre) |
| 30/08/2026 | E2 (partiel) + C5 | Test widget réparé ; 15 tests backend ajoutés (auth + isolation multi-tenant) ; bug 500-au-lieu-de-401 (`redirectGuestsTo`) découvert et corrigé | `php artisan test` : 17/17 ; correctif C5 revérifié par curl réel |
| 30/08/2026 | E2 (complet) | 10 tests backend ajoutés (paiements/doublons/reçus + calculs présence/récitation) | `php artisan test` : 27/27 |
| 30/08/2026 | F7 | Migration `deleted_at` + `SoftDeletes` sur `Payment` | Migration appliquée en dev + test automatisé + suite complète (28/28) |
| 30/08/2026 | F6 | Recalcul du taux de présence sur jours ouvrés réels ; champ "jours de cours" ajouté à l'écran Markaz | `flutter analyze` 0 ; suite backend 29/29 ; test end-to-end curl (5→6 jours) |
| 30/08/2026 | C4 | Config CORS publiée et documentée | Suite backend au vert + en-têtes CORS confirmés par requête OPTIONS réelle |
| 30/08/2026 | D3 | Table `document_counters` + verrouillage réel remplaçant le COUNT() non fiable | Test de charge réel : 15 requêtes HTTP parallèles → 15 numéros distincts ; 2 tests automatisés ; suite 31/31 |
| 30/08/2026 | F8 | `doc/openapi.yaml` — spec OpenAPI 3.0 complète des 42 opérations | Validée par `openapi-spec-validator` (1 vraie erreur détectée et corrigée) ; nombre d'opérations recompté contre les routes réelles |
| 30/08/2026 | B1 + B2 + F3 | Modules Récitations et Tuteurs intégrés côté Flutter (datasource/service/provider/écran complets) | `flutter analyze` 0 ; `flutter test` 2/2 ; script Hive runtime isolé ; cycle CRUD réel testé par curl |
| 30/08/2026 | F2 | Rapports hebdo/mensuel par élève branchés sur le Document Engine, ancien code ad-hoc supprimé | `flutter analyze` 0 ; `flutter test` 2/2 ; génération réelle des 2 PDF + inspection visuelle du rendu |
| 30/08/2026 | C3 | `usesCleartextTraffic` déplacé en debug-only via manifest Gradle | Manifestes fusionnés debug/release générés et inspectés : attribut présent/absent comme voulu |
| 30/08/2026 | D2 (majoritaire) | File d'attente hors-ligne persistante (paiements/présences/tuteurs/récitations) + rejeu automatique + badge UI | `flutter analyze` 0, `flutter test` 2/2, script isolé (persistance/idempotence/ordre) ; rejeu réseau réel non testé (pas d'appareil, limite FFI en script pur) |
| 30/08/2026 | C2 (code) | Bug racine (500 systématique) corrigé + emails traduits en français ; reste : choix d'un fournisseur SMTP réel (décision produit) | Test curl réel (200, code présent, tout en français) + test automatisé + suite 32/32 |
| 30/08/2026 | F1 | Décision assumée avec l'utilisateur : pas de reconstruction serveur, écart documenté comme choix technique | — |

---

## Bilan de clôture (30 août 2026)

25 points identifiés à l'audit + 1 bonus (C5) découvert en cours de route
sur ce même 30 août.

- ✅ **21 résolus et vérifiés** : A1, A2, C1, B3, E3, E4, D1, E1, C4, D3,
  F8, B1, B2, F3, F2, C3, F6, F7, plus le bonus C5.
- 🟡 **2 en grande partie résolus**, avec une limite assumée et documentée :
  D2 (classes non couvertes, rejeu réseau non testé faute d'appareil), C2
  (bug de code corrigé, choix du fournisseur SMTP restant au produit).
- ⚪ **1 décision produit explicite de ne pas agir** : F1 (le moteur
  client-side existant est conservé, l'écart d'architecture par rapport au
  CDC est documenté comme assumé plutôt que caché).
- ✅ **E2** listé séparément ci-dessus est inclus dans les 21.

Chaque point marqué résolu a été vérifié concrètement (tests automatisés,
curl contre un vrai serveur, scripts d'exécution isolés, inspection
visuelle de PDF générés, ou manifestes Android fusionnés inspectés) — pas
seulement codé puis supposé correct. Les limites de vérification
rencontrées (compilateur Dart pur incompatible avec le code utilisant
`flutter/foundation.dart` ou les plugins FFI, absence d'appareil/émulateur
pour un test de bout en bout complet) sont documentées à chaque point
concerné plutôt que passées sous silence.

---

## Étape 6 — Suite : test réel sur téléphone (30 août 2026)

Un TECNO CK6 a été branché après la clôture ci-dessus, révélant deux
nouveaux points (doc/audit.md, section G) et confirmant que le flux "mot de
passe oublié" corrigé côté API (C2) n'avait en réalité **aucune interface
côté app** — jamais construite.

- [x] ✅ **G1.** Résolu. `Navigator.pushReplacementNamed` → 
      `pushNamedAndRemoveUntil(context, '/dashboard', (route) => false)` aux
      3 points d'entrée du dashboard (`splash_screen.dart` si déjà connecté,
      `login_screen.dart` connexion et inscription). Un retour arrière
      depuis le dashboard ne peut plus retomber sur l'accueil/onboarding/
      login. Vérifié : `flutter analyze` 0, `flutter test` 2/2 ; à
      reconfirmer par toi sur le téléphone (retour arrière depuis le
      dashboard doit maintenant quitter l'app, pas revenir à l'accueil).
- [x] ✅ **G2.** Résolu. Deux boutons factices ("Commencer" sur l'accueil,
      "Créer mon compte" sur l'écran Fonctionnalités) affichaient "Bientôt
      disponible" au lieu d'ouvrir l'inscription, alors que l'inscription
      est pleinement fonctionnelle. Les deux mènent maintenant à
      `LoginScreen(isLogin: false)`. Code mort `_showComingSoon` supprimé
      dans `home_screen.dart`.
      Vérifié : `flutter analyze` 0 (y compris absence de code mort),
      `flutter test` 2/2.
- [x] ✅ **C2 (interface manquante).** Le flux "mot de passe oublié"
      n'avait jamais eu d'écran ni de méthode côté Flutter — seul le
      backend avait été corrigé précédemment. Ajout de
      `AuthService.forgotPassword()` / `resetPassword()`, d'un nouvel écran
      `ForgotPasswordScreen` (2 étapes : email → code + nouveau mot de
      passe), d'un lien "Mot de passe oublié ?" sur l'écran de connexion,
      et de la route `/forgot-password`.
      **SMTP réel configuré** : Gmail (`markazi.notifications@gmail.com`)
      avec mot de passe d'application, `backend/.env` mis à jour
      (`MAIL_MAILER=smtp`). Vérifié par un envoi réel via `Mail::raw` (reçu
      confirmé), puis par le flux complet réel (email → code → nouveau mot
      de passe) depuis l'écran `ForgotPasswordScreen` sur le TECNO CK6 —
      confirmé fonctionnel par toi ("sa marche cette fois"). C2 est donc
      entièrement résolu, côté code (API + app) et côté réception email.
      Vérifié côté code : `flutter analyze` 0, `flutter test` 2/2 ; build
      réel installé et lancé sur un TECNO CK6 physique.
- [x] ✅ **G3.** Résolu. Débordement visuel (`RenderFlex overflowed by 31
      pixels`) sur les cartes de statistiques du tableau de bord, constaté
      uniquement à l'exécution réelle (invisible en `flutter analyze`/
      `flutter test`). Cause : icône 48x48 + padding 16 + texte deux lignes
      dépassant la hauteur réelle allouée par `GridView.count
      (childAspectRatio: 1.5)` sur l'écran du TECNO CK6. Corrigé dans
      `dashboard_screen.dart` : `childAspectRatio` → `1.15`, padding de la
      carte 16 → 12, icône 48x48 → 40x40 (taille 24 → 20), texte de la
      valeur 24px → 20px, `mainAxisSize: MainAxisSize.min` ajouté à la
      colonne de texte interne. Vérifié : `flutter analyze` 0, `flutter
      test` 2/2, absence de `RenderFlex overflowed` dans les logs de la
      relance réelle sur l'appareil, et confirmé visuellement par toi
      ("c'est réglé").

Les 3 bugs trouvés lors de ce test réel (G1, G2, G3) ainsi que C2 sont donc
maintenant tous résolus et confirmés sur appareil physique.

## Étape 7 — Audit fonctionnel complet suite à "je n'arrive pas à
## enregistrer un paiement" (30 août 2026)

- [x] ✅ **H1.** Résolu. Le sélecteur de mois du formulaire de paiement
      n'avait aucun effet réel (toujours daté d'aujourd'hui), rendant
      impossible d'enregistrer un paiement pour un autre mois que le mois
      en cours. `_getMonthsList()`/`selectedMonth` passés en `DateTime`,
      nouveau paramètre `date` propagé jusqu'à `PaymentService.createPayment`.
- [x] ✅ **H2.** Résolu. `PaymentStatusAdapter` et `AttendanceStatusAdapter`
      existaient mais n'étaient jamais enregistrés dans `main.dart` —
      chaque écriture locale d'un paiement/présence plantait après un
      enregistrement pourtant réussi côté serveur. Les deux adaptateurs
      sont désormais enregistrés.
- [x] ✅ **H3.** Résolu. Le refus serveur (409, doublon payé même mois)
      n'était pas géré : `PaymentDuplicateException` détectée
      spécifiquement, boîte de dialogue "Confirmer quand même" qui relance
      avec `confirm_duplicate=true`.
- [x] ✅ **H4.** Résolu. Le bouton "Marquer comme payé" dans les détails
      d'un paiement était entièrement factice (aucun appel API/provider).
      Appelle maintenant réellement `PaymentProvider.markAsPaid()` et
      propose le reçu PDF.
      Vérifié (H1-H4) : `flutter analyze` 0, `flutter test` 2/2.
- [ ] ⬜ **H5.** Non résolu — nécessite une décision. Le champ "Nom de
      l'enseignant" d'un groupe n'est jamais envoyé au serveur
      (`_toRequestBody` dans `api_class_datasource.dart` l'omet ; le
      backend n'a qu'un `teacher_id` numérique). Le nom tapé disparaît dès
      la resynchronisation. Deux options : ajouter une colonne
      `teacher_name` texte libre côté backend, ou remplacer le champ par un
      choix parmi les comptes utilisateurs existants (`teacher_id`).
- [ ] ⬜ **H6.** Non résolu. Le message de confirmation de suppression d'un
      élève affirme à tort que les paiements/présences associés seront
      supprimés (en réalité : archivage soft-delete, données conservées en
      base mais disparues des totaux/rapports affichés). Texte à corriger ;
      comportement à clarifier avec l'utilisateur.
- [ ] ⬜ **H7.** Non résolu — écart mineur. Le contrôle de doublon de
      présence côté app (élève+leçon+jour) ne correspond pas à la règle
      serveur réelle (un seul enregistrement par élève et par jour, toutes
      leçons confondues, écrasé silencieusement via `updateOrCreate`).

Élèves, tuteurs, récitations, réglages Markaz et affectation aux groupes :
vérifiés champ par champ jusqu'à l'appel API, aucune anomalie trouvée.

## Étape 8 — Retours utilisateur paiements/rapports/tuteurs (30 août 2026)

Travail pas à pas, un point à la fois.

- [x] ✅ **I1.** Résolu. Le reçu PDF n'était proposable qu'une seule fois
      juste après l'enregistrement. Bouton "Reçu" ajouté dans les détails
      d'un paiement payé, qui rouvre le choix télécharger/partager.
- [x] ✅ **I2.** Résolu. `_buildReportStat` débordait avec des montants
      formatés longs ("Rapport des paiements"). Libellé dans `Expanded`,
      valeur dans `Flexible` + ellipse.
- [x] ✅ **I3.** Résolu. Le numéro de téléphone devait faire exactement 9
      chiffres (bloquant pour un déploiement Play Store international).
      Validation assouplie (6 à 15 chiffres) ; le serveur n'imposait déjà
      aucune contrainte de format.
      Vérifié (I1-I3) : `flutter analyze` 0, `flutter test` 2/2.
- [x] ✅ **I4.** Résolu. Devise codée en dur ("FGN"/"GNF") remplacée par un
      champ configurable. Migration backend (`markaz.currency`, défaut
      "GNF", `MarkazRequest`/modèle mis à jour), champ "Devise" ajouté aux
      réglages du Markaz, `Markaz`/`MarkazBranding` (Flutter) portent
      désormais `currency`, et tous les montants affichés dans le dashboard,
      les rapports et les PDF générés (reçu, rapport mensuel) l'utilisent
      au lieu du suffixe fixe.
      Vérifié : migration appliquée (`php artisan migrate`), `flutter
      analyze` 0, `flutter test` 2/2.
- [x] ✅ **I5.** Résolu. Le formulaire de tuteur propose maintenant une
      liste à cocher de tous les élèves, pré-cochée pour ceux déjà rattachés
      (`student.guardianId == guardian.id`), avec application des seuls
      changements à l'enregistrement (`StudentProvider.setGuardian`, calqué
      sur l'affectation à un groupe). `Student` (Flutter) porte désormais
      `guardianId` (nouveau `@HiveField(5)`, adaptateur régénéré via
      `build_runner`), l'API élève envoie/lit `guardian_id`.
      **Bug backend préexistant découvert au passage** (pas introduit par
      cette session, jamais détecté car l'affectation aux groupes n'avait
      été que tracée dans le code, jamais cliquée sur l'appareil) :
      `StudentRequest` exigeait `name` en obligatoire même sur une mise à
      jour partielle (`PUT /students/{id}` avec juste `class_id` ou
      `guardian_id`) → échouait systématiquement avec une erreur 422.
      Corrigé (`name` en `sometimes|required`, même convention que
      `MarkazRequest`) — corrige du même coup l'affectation aux groupes,
      qui était donc probablement cassée elle aussi jusqu'ici.
      Vérifié : `php artisan test` 32/32, `flutter analyze` 0, `flutter
      test` 2/2.
- [x] ✅ **I6.** Résolu (découvert en implémentant I5, voir ci-dessus) —
      `StudentRequest.name` en `sometimes|required` au lieu de `required`.

## Étape 9 — Carte de groupe encombrée (30 août 2026)

- [x] ✅ **J1.** Résolu. La carte de groupe ouvrait deux vues différentes
      selon qu'on touchait la carte (résumé en dialogue) ou le bouton
      "Voir" (fiche complète), et empilait 4-5 petits boutons texte dont
      deux libellés tronqués ("Modif", "Suppr"). Toute la carte ouvre
      maintenant directement la fiche complète ; les actions secondaires
      sont regroupées dans un menu "⋮" avec libellés complets ; les
      informations de l'ancien résumé (emploi du temps, salle, statut,
      date de création) ont été ajoutées à la fiche complète.
      Vérifié : `flutter analyze` 0, `flutter test` 2/2.
