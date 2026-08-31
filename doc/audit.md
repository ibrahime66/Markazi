# Audit du projet Markazi

Date de l'audit : 30 août 2026
Périmètre : application Flutter (`lib/`) + backend Laravel (`backend/`)

Méthode : analyse statique (`flutter analyze` sans troncature), lecture du code
source (routes API, controllers, repositories, datasources), exécution des
tests backend, vérification de la config (.env, CORS, Sanctum, Git).

Ce document liste les problèmes constatés, classés par gravité. Le suivi de
résolution se fait dans [plan_resolution.md](plan_resolution.md) — ne pas
modifier ce fichier-ci une fois l'audit posé, sauf nouvel audit.

---

## A. Bugs fonctionnels critiques

### A1. Statistiques de groupe toujours à zéro (comparaison enum/String cassée)
**Fichier :** `lib/screens/group_details_screen.dart:350,353,543,546`

Le code compare un enum à une chaîne : `p.status == 'paid'` alors que
`p.status` est de type `PaymentStatus` (idem `a.status == 'present'` avec
`AttendanceStatus`). En Dart cette comparaison est **toujours fausse**.
Conséquence : dans l'écran de détail d'un groupe, le montant payé, le taux de
présence et le taux de paiement affichés sont **systématiquement à 0 %**,
quelles que soient les vraies données.

### A2. Marquer un paiement "payé" ne fonctionne pas correctement côté serveur
**Fichiers :** `lib/services/payment_service.dart` (markAsPaid/markAsUnpaid),
`lib/repositories/payment_repository.dart:37-45`,
`lib/datasources/api_payment_datasource.dart:20-25`,
`backend/routes/api.php:53-55`

L'API n'expose que `GET/POST /payments` (pas de `PUT/PATCH`). Le datasource
Flutter contourne ça en ré-appelant `POST /payments` pour "mettre à jour" un
paiement. Résultat :
- Le `PaymentController` a une détection de doublon (409 sauf
  `confirm_duplicate: true`) que cet appel ne fournit pas → la requête est
  très probablement rejetée, et l'erreur est avalée silencieusement
  (`try/catch` + `print`) dans `payment_repository.dart:42-44`.
- Même en cas de succès, ça crée un **second enregistrement** côté serveur
  (nouvel ID) au lieu de modifier l'existant → double comptage du montant
  dans les statistiques, et le numéro de reçu réel généré côté serveur n'est
  jamais rattaché à l'enregistrement local d'origine.
- Conséquence concrète : le bouton "Marquer comme payé" ne fait persister le
  changement qu'en local (Hive), et le reçu PDF (fonctionnalité construite
  précédemment) ne peut pas afficher de vrai numéro de reçu dans ce flux.

---

## B. Fonctionnalités du cahier des charges non reliées à l'application

### B1. Module "Récitations" invisible côté app
Backend complet (migration, modèle, policy, controller, routes `GET/POST
/recitations`) mais **aucune trace côté Flutter** : pas de datasource, pas de
service, pas de provider, pas d'écran. La fonctionnalité existe en base mais
n'est utilisable par personne.

### B2. Module "Tuteurs / Guardians" invisible côté app
Même constat : CRUD complet côté backend (`/guardians`), zéro écran/provider
côté Flutter.

### B3. Routes de modification/suppression manquantes
`attendances` et `recitations` n'exposent que `index` + `store` (pas de
`update`/`destroy`). Impossible de corriger une présence saisie par erreur —
et la contrainte unique `student_id + date` empêche même de la recréer.

---

## C. Sécurité

### C1. Aucune limitation de débit (rate limiting) sur l'authentification
`routes/api.php` n'applique de middleware `throttle` sur aucune route
(`/auth/login`, `/auth/register`, `/auth/password/forgot`,
`/auth/password/reset`). Ces routes sont exposées à des attaques par
force brute / énumération de comptes.

### C2. "Mot de passe oublié" non opérationnel en pratique
`backend/.env` : `MAIL_MAILER=log`. L'email de réinitialisation n'est jamais
réellement envoyé, seulement écrit dans un fichier de log serveur. Un
enseignant bloqué ne peut pas récupérer son compte via ce canal.

_Mise à jour du 30 août 2026, en corrigeant ce point :_ le problème était en
réalité plus grave que "pas de vrai email envoyé". La route plantait
**systématiquement en 500** (`RouteNotFoundException`), quel que soit le
`MAIL_MAILER` configuré : Laravel tente par défaut de générer un lien
cliquable vers une route web nommée `password.reset`, qui n'existe pas dans
cette API pure (pas de page web de réinitialisation, uniquement l'app
mobile). L'email généré était aussi entièrement en anglais malgré
`APP_LOCALE=fr` (aucune traduction française n'était publiée). **Corrigé** —
voir plan_resolution.md, point C2. Le seul point qui reste hors de portée
du code est le choix d'un vrai fournisseur SMTP en production (identifiants
que seul l'exploitant du service peut fournir).

### C3. Trafic HTTP en clair autorisé sur Android (connu, temporaire)
`android:usesCleartextTraffic="true"` dans `AndroidManifest.xml`, ajouté pour
permettre l'accès à l'API en `http://` en développement. **À retirer avant
toute mise en production** (le CDC section 19 impose HTTPS).

### C5. Requête non authentifiée sans en-tête `Accept` → crash 500 au lieu de 401
_Ajouté le 30 août 2026, découvert en écrivant les tests automatisés du
point E2 — pas dans le périmètre du scan initial._

Toute requête qui échoue l'authentification (`auth:sanctum`) et qui
n'envoie pas explicitement `Accept: application/json` provoque une
`RouteNotFoundException` non gérée (HTTP 500) au lieu d'un 401 JSON propre :
Laravel tente par défaut de rediriger vers une route web nommée `login`,
qui n'existe pas dans cette API pure. Confirmé en conditions réelles via
curl (sans ce header) — sans conséquence pour l'app Flutter actuelle (Dio
envoie `Accept: application/json` par défaut), mais bloquant pour tout
futur client qui ne le ferait pas (tableau de bord web, Postman, script
tiers). **Corrigé** — voir plan_resolution.md, point E2.

### C4. Pas de configuration CORS explicite
`backend/config/cors.php` n'existe pas. Sans conséquence tant que seule l'app
mobile (token Bearer) consomme l'API, mais bloquera un futur tableau de bord
web — une variable `FRONTEND_URL=http://localhost:3000` existe déjà dans la
config, ce qui suggère que c'était prévu.

---

## D. Fragilité de configuration

### D1. Adresse IP codée en dur pour l'API
`lib/services/api_config.dart` : `baseUrl = 'http://192.168.1.185:8321/api'`.
Cette IP change à chaque fois que le réseau Wi-Fi change (déjà arrivé une
fois pendant le développement) et ne fonctionne ni hors du réseau local, ni
en production. Le fichier documente déjà la solution recommandée
(`--dart-define`) mais elle n'est pas appliquée.

### D2. Pas de file d'attente hors-ligne
Les écritures faites sans réseau (`updatePayment`, `updateAttendance`, etc.)
échouent silencieusement (`print()` uniquement) et ne sont jamais rejouées
automatiquement au retour du réseau → perte de données possible en cas de
coupure.

### D3. Génération de numéro de reçu non protégée contre la concurrence
`backend/app/Models/GeneratedDocument.php::nextNumber()` calcule le numéro
suivant via un `COUNT` verrouillé (`lockForUpdate`), mais ce verrou porte sur
les lignes existantes, pas sur une future insertion. Sous forte concurrence,
deux numéros identiques pourraient être calculés avant qu'un `INSERT`
échoue sur la contrainte d'unicité. Impact faible avec un seul enseignant à
la fois, mais à surveiller si l'usage se multiplie.

---

## E. Qualité de code / dette technique

### E1. 186 avertissements `flutter analyze` (0 erreur bloquante)
Répartition principale :
- `withOpacity` déprécié (~40 occurrences) → remplacer par `.withValues()`.
- `print()` en production (~20 occurrences dans repositories/services) →
  remplacer par un vrai logger.
- Imports et variables locales inutilisés (`main.dart`, `dashboard_screen.dart`,
  `onboarding_screen.dart`, `class_service.dart`).
- `BuildContext` utilisé après un `await` sans vérification `mounted` à de
  nombreux endroits de `dashboard_screen.dart` (risque d'erreur si
  l'utilisateur quitte l'écran pendant un appel réseau).
- Une méthode morte : `_buildStudentStat` dans `group_details_screen.dart`
  (jamais appelée).

### E2. Aucun test automatisé côté backend
Seuls les tests par défaut de Laravel (`ExampleTest`) sont présents.
Aucun test pour l'authentification, l'isolation multi-tenant (`markaz_id`),
ni la détection de doublons de paiement — ces points n'ont été vérifiés que
manuellement (curl) pendant le développement.

### E3. Fichiers résiduels indésirables dans le dépôt
- `android/java_pid20258.hprof` — 423 Mo, heap dump de debug oublié.
- `android/app/build.gradle.kts.backup` — fichier de sauvegarde manuel.

Ces fichiers ne devraient pas rester dans le répertoire du projet (risque
d'être committés par erreur, gaspillage d'espace disque).

### E4. Emplacement incohérent du cahier des charges
`ios/docs/CDC.md` n'a rien de spécifique à iOS. Le document de référence du
projet devrait être à la racine (ex. `doc/CDC.md`), pas sous un dossier de
plateforme.

---

## F. Écarts vis-à-vis du CDC (scan complet du document)

Ce qui suit vient d'un passage systématique du cahier des charges
(`ios/docs/CDC.md`) section par section, indépendamment des points A-E
ci-dessus (B1-B3 restent valables et sont repris ici).

### F1. Document Engine : architecture serveur du CDC non respectée
Le CDC (§14, §17, §21, §25) prescrit un moteur de documents **côté backend**
(Laravel + DomPDF/Snappy), exposé via `POST /api/documents/receipts`,
`/reports/weekly`, `/reports/monthly`, en tâche asynchrone (queue). Aucun de
ces éléments n'existe côté backend : pas de DomPDF/Snappy dans
`composer.json`, aucune route `/documents`. Le moteur réellement construit
génère les PDF **entièrement sur l'appareil Flutter** (package `pdf`), ce
qui contredit le principe du CDC §13 ("aucune logique métier n'est déléguée
au client").

### F2. Rapports hebdomadaire/mensuel non accessibles depuis l'app
CDC §8.8, cas d'utilisation #9/#10. `WeeklyReportGenerator` et
`MonthlyReportGenerator` existent dans `lib/document_engine/` mais ne sont
appelés par **aucun bouton** de l'interface. Le tableau de bord utilise
encore un ancien code ad-hoc (`_generatePdfReport`,
`dashboard_screen.dart:3061`), indépendant du Document Engine et sans
branding du Markaz. En pratique, aucun rapport hebdo/mensuel par élève
n'est générable aujourd'hui.

### F3. Récitations et Parents/Tuteurs invisibles côté app
Repris de B1/B2 : backend complet pour les deux modules, aucun écran/
provider Flutter.

### F4. Journal d'activité non consultable dans l'app
CDC §8.9. Les actions sont journalisées côté serveur (`activity_logs` +
route `GET /api/activity-logs`), mais aucun écran Flutter n'affiche cet
historique au maître.

### F5. Mode hors ligne réel non implémenté
CDC §20 en entier. Le cahier des charges exige : statut "en attente de
synchronisation" par action, rejeu automatique à la reconnexion,
résolution de conflit journalisée, indicateur visuel de synchronisation.
Ce qui existe : un cache Hive simple rechargé au démarrage ; toute écriture
hors ligne échoue silencieusement (`print()` uniquement), sans file
d'attente ni rejeu. Le cas d'utilisation #12 n'est pas couvert (recoupe D2).

### F6. Jours de cours configurables non exploités
CDC §8.6. La colonne `working_days` existe en base (`markaz.working_days`)
et l'API l'accepte, mais aucun champ dans `markaz_settings_screen.dart` ne
permet de la régler, et `AttendanceController` ne s'en sert pas dans le
calcul du taux de présence.

### F7. Soft delete incomplet sur `payments`
CDC §18 : "soft delete (deleted_at) sur students, classes et payments".
Implémenté seulement sur `students` et `classes` — absent sur `payments`,
alors que la traçabilité financière est une exigence explicite (§8.7, §19).

### F8. Documentation API absente
CDC §17 : "Documentation API générée (OpenAPI/Swagger) tenue à jour".
Aucune trace de documentation Swagger/OpenAPI générée.

### F9. Écarts mineurs, non bloquants au stade actuel
- State management : Provider utilisé au lieu de Riverpod/Bloc recommandés
  (CDC §15) — fonctionnel, choix technique différent.
- Pas de cache Redis (CDC §16/§25) — sans impact au volume actuel.
- Flutter Web non testé/adapté, alors que le CDC prévoit un client unique
  Android/iOS/Web (§13).
- Déploiement, sauvegardes, monitoring (CDC §23/§24) : non démarré, normal
  tant que le projet reste en développement local.

---

## G. Bugs trouvés en testant sur un vrai téléphone (30 août 2026)

_Ajoutés après coup, à l'occasion du premier test complet sur appareil réel
(TECNO CK6) depuis la migration Firebase → Laravel._

### G1. Retour arrière après connexion : la pile de navigation n'est jamais vidée
Le parcours normal empile splash → accueil (page marketing) → connexion, puis
`Navigator.pushReplacementNamed(context, '/dashboard')` ne remplace que
l'écran de connexion : la pile reste `[accueil, dashboard]`. Un utilisateur
connecté qui appuie sur le bouton retour physique du téléphone atterrit donc
sur la page marketing publique au lieu de quitter l'app — comportement
perçu comme non professionnel. **Corrigé** : `pushNamedAndRemoveUntil`
remplace `pushReplacementNamed` aux 3 points d'entrée du dashboard (splash
si déjà connecté, connexion, inscription), qui vide toute la pile.

### G2. Boutons d'appel à l'action factices sur les pages marketing
Deux boutons affichaient "Bientôt disponible ! 🕌" au lieu de fonctionner :
le bouton **"Commencer"** (section CTA de la page d'accueil) et **"Créer mon
compte"** (bas de la page "Fonctionnalités") — alors que l'inscription est
une fonctionnalité pleinement implémentée et fonctionnelle. Code mort
manifestement laissé d'une itération antérieure de l'app. **Corrigé** : les
deux mènent maintenant à l'écran d'inscription.

### G3. Débordement visuel sur les cartes de statistiques du tableau de bord
Constaté uniquement à l'exécution réelle sur le TECNO CK6 (invisible en
`flutter analyze`/`flutter test`, qui ne rendent pas la mise en page) :
`RenderFlex overflowed by 31 pixels on the bottom` dans
`dashboard_screen.dart`, sur la grille de cartes de statistiques
(`GridView.count` avec `childAspectRatio: 1.5`). L'icône (48x48) + le
padding (16) + le texte sur deux lignes dépassaient la hauteur allouée par
la contrainte réelle du téléphone (`h=72.7`). **Corrigé** : ratio ramené à
`1.15`, padding réduit à 12, icône réduite à 40x40 (taille d'icône 20),
texte de la valeur réduit à 20px, et `mainAxisSize: MainAxisSize.min`
ajouté à la colonne de texte interne. Redéployé et confirmé par
l'utilisateur sur l'appareil réel ("c'est réglé").

## H. Audit fonctionnel complet suite au signalement "je n'arrive pas à
## enregistrer un paiement" (30 août 2026)

Demande explicite : tester systématiquement toutes les fonctionnalités
(élèves, paiements, présences, groupes, tuteurs, récitations, réglages
Markaz, rapports) pour trouver tout ce qui ne marche pas.

### H1. [CRITIQUE, corrigé] Le sélecteur de mois du paiement n'avait aucun
effet
Le formulaire "Enregistrer un paiement" propose de choisir un mois (les 12
derniers), mais la valeur choisie n'était jamais utilisée : le paiement
était systématiquement créé avec `DateTime.now()`. Concrètement : une fois
un paiement "payé" enregistré pour le mois en cours, impossible d'en
enregistrer un pour un autre mois (juin, septembre...) tant qu'on est dans
le mois en cours, car le serveur reçoit toujours le mois du jour et
détecte un "doublon" avec le paiement déjà payé. **Corrigé** : le mois
choisi est maintenant transformé en vraie date et transmise jusqu'au
serveur (`_getMonthsList()`/`selectedMonth` en `DateTime`, nouveau
paramètre `date` sur `PaymentProvider.addPayment` / `PaymentService.createPayment`).

### H2. [CRITIQUE, corrigé] Adaptateurs Hive manquants pour les statuts
`PaymentStatusAdapter` et `AttendanceStatusAdapter` existaient dans le code
généré mais n'étaient jamais enregistrés dans `main.dart` (seuls
`PaymentAdapter`/`AttendanceAdapter` l'étaient). Résultat : toute écriture
locale d'un paiement ou d'une présence plantait avec `HiveError: Cannot
write, unknown type`, alors même que l'enregistrement avait réussi côté
serveur — l'utilisateur voyait une erreur pour une action qui avait en
réalité fonctionné côté serveur. **Corrigé** : les deux adaptateurs sont
maintenant enregistrés.

### H3. [CRITIQUE, corrigé] Aucune gestion du refus de doublon serveur
Le serveur refuse (409) un deuxième paiement "payé" pour le même élève le
même mois, mais l'app ne savait pas interpréter cette réponse : erreur
brute affichée, aucun moyen de continuer. **Corrigé** : nouvelle exception
`PaymentDuplicateException` détectée spécifiquement, avec une vraie boîte
de dialogue de confirmation ("Confirmer quand même") qui relance
l'enregistrement avec `confirm_duplicate=true`.

### H4. [CRITIQUE, corrigé] Bouton "Marquer comme payé" entièrement factice
Dans les détails d'un paiement non payé, le bouton "Marquer comme payé"
affichait un message de succès vert et fermait la boîte de dialogue —
**sans appeler ni l'API ni le provider**. Le paiement restait "en attente"
partout dans l'app malgré le message de confirmation. C'est exactement le
genre de bug qui donne l'impression que "rien ne marche" alors que
l'interface ment sur ce qui s'est réellement passé. **Corrigé** : appelle
maintenant réellement `PaymentProvider.markAsPaid()`, gère l'erreur, et
propose le reçu PDF une fois le paiement confirmé payé (comme pour un
paiement créé directement en "payé").

### H5. [Non corrigé — nécessite un changement backend] "Nom de l'enseignant"
d'un groupe jamais sauvegardé
Le formulaire d'ajout/modification d'un groupe collecte un champ texte
libre "Nom de l'enseignant" — validé, transmis jusqu'au service — mais
jamais envoyé au serveur : `_toRequestBody()` dans
`api_class_datasource.dart` ne l'inclut pas. En base, `classes` n'a qu'un
`teacher_id` (référence vers un compte utilisateur existant), pas de champ
texte libre. Conséquence : le nom tapé disparaît dès que l'app resynchronise
depuis le serveur (immédiatement après la création, puisque
`ClassRepository.addClass` réécrit le cache local avec la réponse du
serveur qui ne contient jamais ce nom). **Décision à prendre** : soit
ajouter une colonne `teacher_name` texte libre côté backend (correspond à
l'usage réel de l'UI actuelle), soit remplacer le champ texte par un choix
parmi les comptes utilisateurs existants du Markaz et envoyer `teacher_id`.

### H6. [Non corrigé — texte trompeur] Message de suppression d'élève inexact
La confirmation de suppression d'un élève affirme : "Cette action est
irréversible et supprimera également toutes les données associées
(paiements, présences)". C'est faux sur les deux points : côté serveur,
`StudentController::destroy()` fait un archivage (soft delete), pas une
suppression irréversible ; et les paiements/présences liés à cet élève
restent intacts en base (contrainte `cascadeOnDelete` inopérante sur un
soft delete). Ils disparaissent simplement des totaux et rapports affichés
dans l'app (filtrés parce que l'élève n'est plus dans la liste active), ce
qui peut fausser un historique financier si on veut l'auditer plus tard.
À corriger a minima dans le texte affiché ; à clarifier avec l'utilisateur
si la disparition des totaux historiques est le comportement voulu.

### H7. [Non corrigé — écart mineur] Détection de doublon de présence
incohérente avec le serveur
Le contrôle côté app avant d'enregistrer une présence compare
(élève + leçon + jour), mais le serveur n'autorise qu'un seul enregistrement
de présence par élève et par jour, toutes leçons confondues, et écrase
silencieusement l'ancien enregistrement (`updateOrCreate`) si la leçon
saisie diffère de la première. Un maître qui enregistre deux leçons
différentes le même jour pour le même élève remplace sans le savoir sa
première saisie, sans aucun avertissement.

### Notes (manques, pas des bugs)
- Le formulaire de groupe n'a pas de champs "Horaire"/"Salle" alors que le
  modèle et le serveur les supportent déjà.
- Aucun moyen de corriger une présence déjà enregistrée depuis l'écran de
  détails, alors que la route serveur existe (`PUT /attendances/{id}`,
  point B3).

Élèves, tuteurs, récitations, réglages Markaz et affectation aux groupes
ont été vérifiés (champ par champ, jusqu'à l'appel API) sans anomalie.

## I. Retours utilisateur après test des paiements/rapports/tuteurs
## (30 août 2026)

Signalés d'un coup, à traiter un par un ("travail pas à pas").

### I1. [Corrigé] Impossible de récupérer le reçu après coup
Le reçu PDF n'était proposé qu'une seule fois, juste après l'enregistrement
d'un paiement marqué payé. Si on fermait cette fenêtre sans télécharger ni
partager, aucun moyen d'y revenir depuis l'onglet Paiements — l'utilisateur
jugeait ça "pas pro", à raison. **Corrigé** : un bouton "Reçu" apparaît
maintenant dans les détails de tout paiement payé, qui rouvre le choix
téléchargement/partage (`_offerPaymentReceipt`).

### I2. [Corrigé] Débordement dans "Rapport des paiements"
`_buildReportStat` (utilisé aussi par les rapports de présence) affichait
le libellé et la valeur dans un `Row` sans aucune contrainte de largeur.
Ça passait avec de petits nombres ("Présents: 12") mais débordait avec des
montants formatés ("Total en attente : 1234567.00 FGN"), plus longs.
**Corrigé** : libellé dans un `Expanded`, valeur dans un `Flexible` avec
ellipse.

### I3. [Corrigé] Validation téléphone bloquante pour un déploiement
## international
Le numéro de téléphone (élève/parent) devait obligatoirement faire
exactement 9 chiffres (format guinéen) — bloquant pour du Play Store, qui
touchera des utilisateurs d'autres pays. La contrainte existait à deux
endroits : dans le dialogue Flutter (`_isValidGuineanPhone`) et, plus
profondément, dans `StudentService._isValidPhoneNumber` (`^\d{9}$`) — un
correctif qui n'aurait touché que l'écran aurait laissé le second passage
bloquer silencieusement. **Corrigé aux deux niveaux** : la validation
accepte maintenant toute longueur plausible (6 à 15 chiffres) ; le
formatage visuel "622 18 09 33" ne s'applique qu'aux numéros à 9 chiffres,
les autres s'affichent tels quels. Le serveur n'imposait déjà aucune
contrainte de format (juste `max:30` caractères).

### I4. [Corrigé] Devise codée en dur ("FGN")
Le montant d'un paiement était affiché partout avec le suffixe fixe "FGN",
alors que l'app va être utilisée par des Markaz dans différents pays (donc
différentes monnaies). **Corrigé** : nouvelle colonne `markaz.currency`
(migration + `MarkazRequest`/modèle), champ "Devise" dans les réglages du
Markaz, et tous les montants affichés (dashboard, rapports, reçus et
rapports PDF) utilisent désormais cette valeur au lieu du suffixe codé en
dur.

### I5. [Corrigé] Tuteur/parent non relié à un ou plusieurs élèves
Le formulaire de tuteur (`GuardianScreen`) ne permettait pas de choisir à
quel(s) élève(s) il correspond, alors que le serveur a bien un champ
`students.guardian_id` prévu pour ça (nullable, un élève par tuteur — donc
un tuteur peut avoir plusieurs élèves). **Corrigé** : le formulaire propose
une liste à cocher de tous les élèves, pré-cochée pour ceux déjà
rattachés, et n'applique que les changements réels à l'enregistrement.
`Student` (Flutter) porte désormais `guardianId`.

### I6. [Corrigé — découvert en implémentant I5] Mise à jour partielle d'un
## élève bloquée côté serveur
En implémentant I5, découverte d'un bug backend préexistant (non introduit
par cette session) : `StudentRequest` exigeait `name` en obligatoire même
sur une mise à jour partielle. Concrètement, `PUT /students/{id}` avec
seulement `class_id` (affectation à un groupe) ou `guardian_id`
(rattachement à un tuteur) échouait systématiquement avec une erreur 422
"name obligatoire". L'affectation aux groupes n'avait jamais été
click-testée sur l'appareil (seulement tracée dans le code lors de
l'audit H) — elle était donc probablement cassée depuis le début sans que
personne ne s'en aperçoive. **Corrigé** : `name` passé en
`sometimes|required` (même convention que `MarkazRequest`, qui gère déjà
correctement ce cas).

## J. Carte de groupe encombrée et redondante (30 août 2026)

### J1. [Corrigé] Carte de groupe "vilaine"
La carte d'un groupe (onglet Groupes) cumulait deux défauts d'ergonomie :
1. Toucher la carte ouvrait un simple résumé en boîte de dialogue
   (`_showClassDetails`), alors que le bouton "Voir" à côté ouvrait la
   fiche complète du groupe (`GroupDetailsScreen`) — deux vues différentes
   pour la même chose, source de confusion.
2. Le bas de la carte empilait 4 à 5 petits boutons texte
   ("Voir" / "Retirer" / "Ajouter" / "Modif" / "Suppr") dans un `Wrap`, avec
   deux libellés tronqués ("Modif", "Suppr") — encombré et peu soigné.

**Corrigé** : toute la carte ouvre directement la fiche complète du
groupe ; les actions secondaires (ajouter/retirer un élève, modifier,
supprimer) sont regroupées dans un menu compact (icône "⋮" dans l'en-tête
de la carte) avec des libellés complets. Les informations que seul
l'ancien résumé affichait (emploi du temps, salle, statut, date de
création) ont été ajoutées à la fiche complète du groupe pour ne rien
perdre au passage.

---

## K. Retours utilisateur — perte de données, jour de paiement, langues (30 août 2026)

### K1. [Corrigé — bug critique de perte de données] Élèves d'un groupe qui "disparaissent"
Signalé : après chaque redéploiement de l'app (le développeur relance
`flutter run` pour pousser des correctifs), les groupes réapparaissent
avec 0 élève — obligeant à réaffecter tout le monde. Cause racine : côté
API, l'appartenance à un groupe n'est PAS stockée sur le groupe mais sur
`students.class_id` (`ApiClassDatasource` reconstitue `studentIds` en
croisant `/classes` et `/students` à chaque chargement — voir commentaire
en tête de ce fichier). `ClassRepository.addStudentToClass` écrivait
d'abord dans le cache local (Hive), *puis* tentait `PUT /students/{id}`
avec `{class_id}` — mais si cet appel échouait, l'erreur était **avalée**
(`catch` + `debugPrint`, sans la relancer). Résultat : l'app affichait
"élève ajouté" avec succès alors que le serveur n'avait jamais enregistré
l'affectation. Au prochain redéploiement, `syncFromMarkaz` vide le cache
et le recharge depuis le serveur (seule source de vérité) → 0 élève.
Concrètement, cet appel échouait *systématiquement* avant le correctif
I6 (§ ci-dessus), qui exigeait `name` sur toute mise à jour de `Student` y
compris une simple affectation à un groupe — donc **toutes** les
affectations de groupe faites avant I6 étaient perdues sans le moindre
avertissement. **Corrigé** :
- `ClassRepository.addStudentToClass`/`removeStudentFromClass` relancent
  maintenant l'erreur serveur (après avoir annulé la modification locale
  optimiste), au lieu de la journaliser silencieusement dans la console.
  L'utilisateur voit désormais un message d'erreur explicite si
  l'affectation n'a réellement pas pu être enregistrée côté serveur.
- Vérifié en conditions réelles (curl + jeton API) : `PUT /students/{id}`
  avec seulement `class_id` répond bien `200` maintenant que I6 est
  appliqué — les nouvelles affectations survivront donc aux prochains
  redéploiements/redémarrages.

### K2. [Corrigé] Message technique affiché lors d'un paiement en double
Le dialogue "Paiement déjà enregistré" affichait mot pour mot le message
brut renvoyé par l'API : *"...Renvoyez la requête avec
confirm_duplicate=true pour confirmer."* — une instruction technique pour
développeur, pas un texte destiné à un utilisateur final, incompatible
avec une publication sur le Play Store. **Corrigé** côté serveur
(`PaymentController::store`) : message reformulé en
*"Voulez-vous quand même enregistrer ce nouveau paiement ?"*, sans aucune
référence à un nom de paramètre d'API.

### K3. [Corrigé] Limite perçue de 20 élèves par groupe
Le champ "Nombre maximum d'élèves" n'avait en réalité aucun plafond dur à
20 côté app (juste une valeur par défaut pré-remplie, modifiable) ; le
serveur limitait à 200. Comme rien n'indiquait que ce nombre pouvait être
augmenté, la valeur par défaut a été prise pour un maximum. **Corrigé** :
plafond serveur relevé à 500, valeur par défaut passée à 30, et un texte
d'aide explicite ("modifiable, jusqu'à 500 — vous pouvez augmenter ce
nombre à tout moment") ajouté sur le champ, en création comme en
modification de groupe.

### K4. [Corrigé — gap découvert après coup] Nom du Markaz en arabe/chinois/espagnol/etc.
Aucune restriction de caractères dans l'app : le champ "Nom du Markaz" est
un `TextField` standard (validation serveur : `string, max:255`, sans
motif de caractères) et la police de l'app (`GoogleFonts.cairo`) gère
nativement l'arabe — un nom en arabe, espagnol ou toute langue latine
s'affiche donc déjà correctement **dans l'app**.
**Gap découvert en observant les logs du téléphone** (avertissement
`dart_pdf` : *"Helvetica has no Unicode support"*) : les documents PDF
générés (reçus, rapports) utilisaient la police PDF standard "Helvetica",
qui n'a aucun glyphe arabe — un nom de Markaz en arabe se serait affiché
en cases vides sur les reçus/rapports, alors qu'il s'affiche très bien
dans l'app elle-même. **Corrigé** : les trois générateurs PDF utilisent
maintenant une police Noto Sans (latin, meilleure couverture des accents
que Helvetica) avec Noto Sans Arabic en police de repli automatique
(`PdfHelpers.buildTheme()`, polices embarquées dans `assets/fonts/`,
~730 Ko au total).
**Limite assumée** : le chinois (Noto Sans SC) n'est pas inclus — le
fichier de police pèse ~10 Mo contre ~190 Ko pour l'arabe, disproportionné
pour un Markaz d'enseignement coranique. Un nom en chinois s'affiche bien
dans l'app mais pas encore sur les PDF générés ; à ajouter séparément si
un besoin réel se présente.

### K5. [Corrigé] Écran "Mon Markaz" peu soigné
Tous les champs (identité, coordonnées, devise, jours de cours) étaient
empilés à plat dans un simple défilement, sans regroupement visuel.
**Corrigé** : régénéré en sections avec cartes distinctes ("Identité",
"Coordonnées", "Finance", "Jours de cours"), chacune avec icône et
sous-titre explicatif, précédées d'un bandeau d'en-tête reprenant le nom
du Markaz.

### K6. [Corrigé] Jour exact du paiement absent des reçus
Le reçu PDF affichait toujours le 1er jour du mois concerné
(`payment.date`, qui sert uniquement à identifier "le mois d'août" par
exemple), jamais le jour réel où l'élève a payé — le champ `paid_at`
existait déjà côté serveur/BDD mais n'était ni exposé dans le formulaire
Flutter, ni renseigné à la création, ni lu par le générateur de reçu.
**Corrigé** : ajout d'un sélecteur "Jour du paiement" (par défaut
aujourd'hui) dans le formulaire d'enregistrement, nouveau champ `paidAt`
sur le modèle `Payment` (Hive + JSON), transmis à l'API (`paid_at`) et
utilisé par le reçu PDF à la place du 1er du mois. Le serveur retombe sur
"maintenant" si `paid_at` n'est pas fourni mais que le paiement est créé
déjà marqué payé (même logique que `markAsPaid`, qui le faisait déjà).

### K7. [Corrigé — mode sombre] Mode sombre/clair
Le thème (`main.dart`) et la plupart des écrans utilisaient des couleurs
fixes (`Colors.white` en dur pour les cartes/champs — au moins
29 occurrences rien que sur `dashboard_screen.dart`,
`group_details_screen.dart`, `guardian_screen.dart` et
`common_widgets.dart`) plutôt que des couleurs dépendant du thème,
empêchant tout mode sombre propre.

**Corrigé**, avec une approche pensée pour ne pas nécessiter de réécrire
chaque écran :
- Nouveau `ThemeProvider` (persisté dans une box Hive `settings`
  indépendante des données métier) exposant `ThemeMode` (Système / Clair /
  Sombre), avec un sélecteur dans "Mon Markaz" → section "Apparence"
  (`SegmentedButton`).
- `AppColors.background/surface/textDark/textMedium/textLight` sont
  passés de `const` à des *getters* qui lisent le mode courant
  (`AppColors.applyBrightness`, appelé par `ThemeProvider` avant chaque
  `notifyListeners()`). Comme la quasi-totalité de l'app utilise déjà ces
  constantes nommées (plutôt que des couleurs littérales éparpillées),
  cette seule bascule suffit à faire suivre le thème à tous les écrans qui
  s'appuient dessus, **sans modifier chaque écran un par un**.
- Chaque écran/​widget partagé encore concerné ajoute
  `context.watch<ThemeProvider>()` en tête de son `build()` — c'est ce qui
  déclenche la reconstruction (donc la relecture des couleurs) au moment
  du bascule : `MarkaziAppBar`, `FeatureCard`, `AdvantageBadge`,
  `SectionTitle` (`common_widgets.dart`), `DashboardScreen`,
  `GroupDetailsScreen`, `GuardianScreen`, `MarkazSettingsScreen`,
  `RecitationScreen`.
- Les `Colors.white` restants utilisés comme fond de carte/conteneur (pas
  comme texte/icône blanc sur fond de couleur fixe, laissés tels quels)
  ont été remplacés par `AppColors.surface` dans ces mêmes fichiers.
- `MaterialApp` fournit désormais un vrai `theme`/`darkTheme`/`themeMode`
  (palette sombre dédiée, `ColorScheme.fromSeed(brightness: ...)`) — les
  widgets Material natifs (`Drawer`, boîtes de dialogue, cases à cocher,
  etc.) suivent donc automatiquement le mode choisi sans code
  supplémentaire. Couleur des icônes de la barre système (heure/batterie)
  également adaptée par thème (`AppBarTheme.systemOverlayStyle`), sinon
  invisible sur fond sombre.
- **Écrans volontairement non concernés** : `SplashScreen`,
  `OnboardingScreen`, `LoginScreen`, `HomeScreen`, `FeaturesScreen`,
  `AboutScreen` — écrans de marque avant/à la connexion, à fond dégradé
  vert fixe assumé, comme dans la plupart des apps (le mode clair/sombre
  n'a de sens qu'une fois dans l'app).
Vérifié : `flutter analyze` 0, `flutter test` 2/2 (le test existant
construisait `MarkaziApp` sans `ThemeProvider` en ancêtre → adapté pour en
fournir un, sinon `ProviderNotFoundException`).

**Retour utilisateur après premier test** : le réglage était uniquement
dans "Mon Markaz" → trop enfoui pour un usage courant ("c'est à
l'utilisateur de cliquer pour l'activer dans l'application"). **Corrigé** :
ajout d'un bouton à bascule ("Mode sombre") directement dans le tiroir de
navigation, accessible en un clic depuis n'importe quel écran du tableau
de bord, sans passer par les réglages. Le réglage fin (Système/Clair/
Sombre) reste disponible dans "Mon Markaz" pour qui le cherche.

### K8. [Corrigé — infrastructure + première couverture] Changement de langue de l'app
Traduire l'app entière (plusieurs centaines de chaînes en français en dur,
réparties sur une douzaine d'écrans) est un chantier de fond ; cette passe
pose l'infrastructure complète et l'applique à la partie la plus visible
de l'app (celle utilisée en permanence, contrairement aux écrans de
marque avant connexion).

**Mis en place** :
- Infrastructure standard Flutter (`flutter_localizations` + `intl`,
  fichiers `.arb`, génération via `flutter gen-l10n` → `AppLocalizations`)
  plutôt qu'un système maison, pour rester dans les clous de l'écosystème
  (mise à jour des traductions, pluriels, etc. si besoin plus tard).
- Trois langues : **français** (référence), **anglais**, **arabe** (RTL
  géré nativement par Flutter dès qu'une locale arabe est active — aucun
  code supplémentaire nécessaire ; la police `GoogleFonts.cairo` la
  supporte déjà, voir K4).
- `LocaleProvider` (persisté, même mécanisme que `ThemeProvider` — box
  Hive `settings`) avec sélecteur dans "Mon Markaz" → section "Langue" :
  Système / Français / English / العربية.
- **Couverture de cette première tranche** : tiroir de navigation (tous
  les libellés + le bouton "Mode sombre"), titres d'onglets du tableau de
  bord, écran "Mon Markaz" en entier (sections, champs, boutons), titres
  des écrans Tuteurs/Parents et Récitations.
- **Non couvert** (reste en français en dur) : le contenu détaillé des
  écrans eux-mêmes (formulaires, dialogues, listes, messages d'erreur) —
  Élèves, Groupes, Paiements, Présences, Rapports, Tuteurs, Récitations,
  et les écrans de marque avant connexion (Accueil, Onboarding, Connexion,
  Fonctionnalités, À propos), volontairement laissés de côté comme pour
  K7. C'est la majorité du volume de texte de l'app — à couvrir
  progressivement, écran par écran, en réutilisant les clés déjà créées
  dans `lib/l10n/app_{fr,en,ar}.arb` et en ajoutant les nouvelles au fur
  et à mesure.
Vérifié : `flutter analyze` 0, `flutter test` 2/2 (adapté pour fournir
`LocaleProvider` en ancêtre de test, même besoin que pour `ThemeProvider`
en K7).

## L. Impossible de corriger une présence déjà enregistrée (30 août 2026)

### L1. [Corrigé] Aucun moyen de modifier une présence
Une fois une présence marquée (présent/absent/retard), il n'y avait aucun
moyen de la corriger depuis l'app — la boîte de dialogue "Détails de la
présence" n'était qu'une vue en lecture seule (bouton "Fermer" uniquement).
Fait notable : la route serveur `PUT /attendances/{id}` existait déjà et
fonctionnait (ajoutée lors d'un correctif antérieur, point B3), ainsi que
`AttendanceRepository.updateAttendance` — seules les couches
service/provider/UI manquaient pour relier le tout, ce qui a permis un
correctif rapide plutôt qu'une construction depuis zéro.

**Corrigé** : bouton "Modifier" ajouté à la boîte de dialogue de détails,
ouvrant un formulaire pré-rempli (statut + leçon) qui appelle la chaîne
complète `AttendanceProvider.updateAttendance` → `AttendanceService` →
`AttendanceRepository` → `PUT /attendances/{id}`.

**Limite assumée** : la date n'est volontairement pas modifiable depuis ce
formulaire. La table `attendances` a une contrainte unique
`(student_id, date)` côté serveur — changer la date vers un jour où
l'élève a déjà un enregistrement ferait échouer la requête (erreur 500 non
gérée). Corriger le statut/la leçon couvre le besoin réel exprimé
("modifier une présence" = corriger une erreur de saisie) sans ce risque.
Si le besoin de changer la date se confirme, il faudra d'abord traiter H7
(déjà ouvert, même zone de fragilité : le comportement de la contrainte
unique par jour n'est pas géré côté UI).
Vérifié : bout en bout via `curl` (créer → corriger via PUT → supprimer,
200/204 sur les trois appels), `flutter analyze` 0, `flutter test` 2/2.

---

## Résumé chiffré

| Catégorie | Nombre de points |
|---|---|
| Bugs fonctionnels critiques | 2 |
| Fonctionnalités CDC non reliées à l'app | 3 |
| Sécurité | 4 |
| Fragilité de configuration | 3 |
| Qualité de code / dette technique | 4 |
| Écarts CDC (scan complet, section F) | 9 |
| Bugs trouvés en test réel sur téléphone | 3 |
| Audit fonctionnel complet (section H) | 7 |
| Retours utilisateur paiements/rapports/tuteurs (section I) | 6 |
| Expérience utilisateur carte de groupe (section J) | 1 |
| Perte de données groupes, paiement, apparence, langues (section K) | 8 corrigés |
| Correction d'une présence (section L) | 1 corrigé |
| **Total** | **51** |

Le plan de résolution détaillé, avec l'ordre de traitement recommandé et le
suivi "résolu / non résolu", est dans
[plan_resolution.md](plan_resolution.md).
