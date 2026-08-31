
CAHIER DES CHARGES
MARKAZI
Plateforme SaaS multi-tenant de gestion numérique des Markaz (écoles coraniques)
Version 1.0
Document de spécifications fonctionnelles et techniques
Août 2026

Sommaire



1. Résumé exécutif
Markazi est une plateforme SaaS multi-tenant destinée à la gestion numérique des Markaz (écoles coraniques) en Guinée et, à terme, dans l'ensemble de la région. Elle centralise en une seule application la gestion des élèves, des classes, des présences, des récitations coraniques, des paiements et des rapports pédagogiques, sur Android, iOS et Web à partir d'une base de code Flutter unique.
Le produit répond à un besoin concret : les maîtres de Markaz gèrent aujourd'hui leurs élèves, leurs présences et leurs paiements sur papier ou via des outils génériques (cahiers, WhatsApp, Excel non structuré), ce qui entraîne des pertes d'information, une absence de traçabilité et une image peu professionnelle vis-à-vis des parents. Markazi propose une alternative numérique simple, moderne et centralisée, tout en respectant une contrainte forte : aucun système de paiement en ligne n'est intégré, les paiements restant physiques et étant simplement enregistrés dans l'application.
La version 1 (V1) se concentre sur un rôle unique, le Maître, rattaché à un seul Markaz, mais l'architecture est conçue dès le départ pour supporter plusieurs Markaz indépendants sur la même plateforme (multi-tenant), avec une isolation stricte des données côté serveur, et pour accueillir sans refonte des rôles additionnels (Admin Markaz, Super Admin, Parent) lors de versions ultérieures.
Ce document constitue la spécification de référence du projet : il couvre le contexte, les objectifs, le périmètre fonctionnel, l'architecture technique (Flutter, API REST, MySQL), la sécurité, le mode hors ligne, le moteur de génération de documents PDF, la stratégie de tests, le plan de déploiement et la feuille de route de développement en dix phases. Il est destiné à servir de base directe à la conception et à l'implémentation par une équipe de développement.
2. Contexte
Les Markaz jouent un rôle central dans l'éducation coranique en Guinée : ils accueillent des enfants et des adultes pour l'apprentissage et la mémorisation du Coran, en complément de la scolarité classique. Ce sont généralement de petites structures gérées par un maître unique, avec des moyens limités et peu ou pas d'outils numériques.
La gestion administrative de ces structures repose aujourd'hui sur des supports papier (registres de présence, cahiers de récitation, carnets de paiement) ou sur des solutions bureautiques génériques non adaptées au vocabulaire et aux processus spécifiques d'un Markaz (sourates, versets, récitation, progression de mémorisation). Cette situation génère plusieurs difficultés récurrentes : suivi de présence peu fiable, absence d'historique consultable de la progression de chaque élève, paiements mal tracés, reçus faits à la main ou inexistants, et impossibilité de produire rapidement un rapport présentable aux parents.
Markazi s'inscrit dans cette réalité de terrain : c'est un outil pensé spécifiquement pour un Markaz, et non une adaptation générique d'un logiciel scolaire classique. Chaque fonctionnalité — suivi des sourates étudiées, statut de récitation, reçu de paiement avec cachet, rapport hebdomadaire de mémorisation — répond à un besoin métier réel du maître coranique.
3. Problématique
Comment offrir à un maître de Markaz, disposant de moyens techniques limités et sans compétences informatiques particulières, un outil simple lui permettant de gérer numériquement ses élèves, leurs présences, leur progression de récitation et leurs paiements, tout en générant automatiquement des documents professionnels (reçus, rapports), sans dépendre d'un système de paiement en ligne, et en garantissant que la solution puisse évoluer vers une plateforme supportant plusieurs centaines de Markaz indépendants sans compromettre la confidentialité des données de chacun ?
Cette problématique se décline en plusieurs sous-questions techniques traitées dans ce document : quelle architecture multi-tenant garantit une isolation totale des données au niveau base de données, API et authentification ? Quel moteur de documents permet de générer de façon fiable et extensible des reçus et rapports à l'image du Markaz ? Comment assurer la continuité de service en l'absence de connexion Internet, fréquente dans certaines zones ?
4. Vision du produit
Devenir la plateforme de référence pour la gestion numérique des Markaz en Afrique de l'Ouest francophone, en combinant simplicité d'usage, respect des pratiques et du vocabulaire de l'enseignement coranique, et une architecture technique robuste capable de servir aussi bien un Markaz unique qu'un réseau de centaines de Markaz.
À terme, Markazi doit permettre à un maître d'administrer entièrement son Markaz depuis son téléphone, à un parent de suivre la progression de son enfant, et à des structures fédératrices (associations, ligues de Markaz) de disposer d'une vue consolidée — sans jamais compromettre l'autonomie et la confidentialité de chaque Markaz.
5. Objectifs
Objectifs métier
    • Digitaliser la gestion administrative et pédagogique d'un Markaz de bout en bout.
    • Fiabiliser le suivi des présences, des récitations et des paiements.
    • Professionnaliser la communication avec les parents via des documents générés automatiquement (reçus, rapports).
    • Réduire le temps consacré par le maître aux tâches administratives répétitives.
Objectifs techniques
    • Fournir une base de code Flutter unique pour Android, iOS et Web.
    • Garantir une isolation stricte des données entre Markaz dans une architecture multi-tenant.
    • Concevoir une API REST documentée, sécurisée et évolutive, adossée à MySQL.
    • Permettre un usage mobile en mode hors ligne avec synchronisation fiable.
    • Construire un moteur de documents modulaire, réutilisable pour tous les types de documents futurs.
6. Public cible
Utilisateurs directs (V1)
    • Maîtres de Markaz : responsables uniques d'un Markaz, utilisateurs principaux de l'application, généralement sur smartphone Android.
Utilisateurs indirects
    • Parents d'élèves : destinataires des reçus et rapports partagés par le maître (V1, sans compte applicatif).
    • Élèves : bénéficiaires du suivi pédagogique, sans accès direct à l'application en V1.
Utilisateurs futurs (évolutions)
    • Administrateurs de Markaz et Super Administrateurs de la plateforme.
    • Parents disposant d'un compte et d'un accès en lecture au suivi de leur enfant.
7. Périmètre
7.1 Inclus dans la V1
    • Authentification et gestion de compte du Maître.
    • Gestion du Markaz (fiche, logo, coordonnées).
    • Gestion des élèves, des classes et des parents (données descriptives).
    • Suivi des cours, des récitations et des présences/absences.
    • Enregistrement manuel des paiements et génération automatique de reçus PDF.
    • Rapports hebdomadaires et mensuels exportables en PDF.
    • Tableau de bord, recherche, filtres, historique des actions.
    • Mode hors ligne partiel sur mobile avec synchronisation.
    • Architecture multi-tenant prête à l'usage, même si la V1 est opérée avec un rôle unique par Markaz.
7.2 Exclu de la V1 (évolutions futures — voir section 29)
    • Application dédiée aux parents.
    • Rôles Admin Markaz, Super Admin, plusieurs enseignants par Markaz.
    • Paiement en ligne, quel qu'il soit.
    • Notifications push (Firebase exclu — voir section 24).
    • Multilinguisme (arabe, anglais) — la V1 est en français.
8. Fonctionnalités
8.1 Authentification et compte
    • Inscription, connexion, déconnexion, mot de passe oublié, réinitialisation, changement de mot de passe.
    • Gestion et expiration des sessions, protection des routes, messages d'erreur explicites.
8.2 Markaz
    • Fiche Markaz : nom, logo, adresse, ville, pays, téléphone, email, slogan, informations complémentaires.
    • Réutilisation automatique de ces informations dans tous les documents générés.
8.3 Élèves
    • Ajout, modification, consultation, recherche, filtrage, archivage et suppression contrôlée d'un élève.
    • Fiche élève centralisant identité, classe, présence, récitations, progression, paiements, rapports et historique.
8.4 Classes
    • Création, modification, consultation d'une classe et affectation/retrait d'élèves. Une classe appartient à un seul Markaz.
8.5 Suivi des cours et des récitations
    • Enregistrement quotidien de la matière étudiée (sourate, versets) par élève, avec historique complet.
    • Statut de récitation par séance : récité, non récité, récité partiellement, avec calcul automatique de la progression.
8.6 Présences et absences
    • Marquage quotidien : présent, absent, retard, absence justifiée.
    • Jours de cours configurables par Markaz (samedi/dimanche non travaillés par défaut).
    • Calcul automatique du nombre de jours de cours, présences, absences, taux de présence et d'absence.
8.7 Paiements et reçus
    • Enregistrement manuel d'un paiement (élève, montant, mois, date, statut, mode, observation), avec détection des doublons évidents.
    • Génération automatique d'un reçu PDF complet, prévisualisable, téléchargeable, imprimable et partageable.
8.8 Rapports
    • Rapport hebdomadaire par élève : présence, récitations, progression, observations, export PDF.
    • Rapport mensuel par élève : statistiques complètes, graphiques, export PDF.
8.9 Tableau de bord, recherche et historique
    • Indicateurs clés (élèves, présences du jour, paiements du mois, taux de présence, alertes).
    • Recherche et filtres transverses ; journal d'activité horodaté par utilisateur et par entité.
9. Rôles utilisateurs
La V1 n'active qu'un seul rôle, mais le modèle de rôles est conçu pour accueillir les rôles futurs sans changement structurel, via un système de permissions par rôle et par Markaz.
Rôle	Statut	Portée	Description
Teacher / Maître	Actif en V1	1 Markaz	Gère entièrement son Markaz : élèves, classes, présences, récitations, paiements, documents.
Admin Markaz	Futur	1 Markaz	Supervise plusieurs maîtres au sein d'un même Markaz.
Super Admin	Futur	Plateforme	Administre l'ensemble des Markaz de la plateforme (support, facturation SaaS, monitoring).
Parent	Futur	Ses enfants	Consultation en lecture seule du suivi de ses enfants.
10. Cas d'utilisation
#	Cas d'utilisation	Acteur
1	Se connecter à l'application	Maître
2	Ajouter un élève	Maître
3	Enregistrer les informations d'un parent	Maître
4	Marquer la présence d'un élève	Maître
5	Enregistrer une récitation	Maître
6	Enregistrer un paiement	Maître
7	Générer un reçu PDF	Système
8	Partager un reçu	Maître
9	Consulter la progression hebdomadaire d'un élève	Maître
10	Générer le rapport mensuel	Maître / Système
11	Configurer les informations du Markaz	Maître
12	Utiliser l'application hors ligne puis se resynchroniser	Maître
11. Parcours utilisateurs
11.1 Parcours d'onboarding
Le maître télécharge l'application, crée son compte, renseigne les informations de son Markaz (nom, logo, coordonnées), puis est dirigé vers un tableau de bord vide avec des actions suggérées : créer une première classe, ajouter un premier élève.
11.2 Parcours quotidien type
Le maître ouvre l'application, consulte le tableau de bord du jour, marque les présences de sa ou ses classes, enregistre les récitations effectuées, puis, si un parent est venu payer en espèces, enregistre le paiement et partage immédiatement le reçu généré via WhatsApp ou tout autre canal disponible sur l'appareil.
11.3 Parcours de reporting
En fin de semaine ou de mois, le maître génère le rapport correspondant pour un élève ou l'ensemble d'une classe, le prévisualise, puis le partage aux parents ou l'imprime pour archivage physique.
12. UX / UI
La direction visuelle doit être sobre, professionnelle et réaliste, à l'opposé des rendus typiques d'interfaces générées automatiquement. Elle s'inspire de produits professionnels reconnus : Google Classroom, Google Workspace, Notion, Microsoft 365, Stripe Dashboard.
À éviter systématiquement
    • Dégradés excessifs, illustrations 3D, personnages artificiels.
    • Couleurs criardes, cartes surchargées, ombres excessives.
    • Interfaces qui ressemblent à des maquettes Dribbble artificielles plutôt qu'à un vrai produit.
Principes retenus
    • Palette sobre à dominante neutre, avec une couleur d'accent unique pour les actions principales.
    • Typographie claire, hiérarchie visuelle nette, densité d'information maîtrisée.
    • Composants réutilisables (design system léger) : boutons, champs, cartes de statistiques, tableaux, badges de statut.
    • Cohérence stricte des parcours entre mobile, tablette et web.
13. Architecture technique
Markazi repose sur une architecture classique en trois couches : un client Flutter unique (Android, iOS, Web), une API REST assurant toute la logique métier et la sécurité, et une base de données MySQL. Aucune logique métier ni règle d'autorisation sensible n'est déléguée au client : celui-ci consomme l'API et affiche les données, mais toutes les vérifications d'accès sont effectuées côté serveur.
    • Client Flutter (Android / iOS / Web) — présentation, saisie, mode hors ligne local.
    • API REST (backend) — logique métier, authentification, autorisation, isolation multi-tenant, génération de documents.
    • Base de données MySQL — stockage relationnel unique, partitionné logiquement par Markaz.
    • Stockage de fichiers (logos, documents générés) — système de fichiers ou stockage objet compatible S3, hors Firebase.
14. Architecture backend
Le backend recommandé est Laravel (PHP), conformément à la préférence exprimée dans le cahier des charges, pour les raisons suivantes : écosystème mature pour construire rapidement une API REST sécurisée (Sanctum pour l'authentification par token), ORM Eloquent adapté à un schéma relationnel MySQL avec relations multiples (élève, classe, paiement, récitation), système de policies natif particulièrement adapté à l'isolation multi-tenant, générateurs de PDF éprouvés (DomPDF, Snappy), et large disponibilité de développeurs PHP/Laravel en Afrique francophone, ce qui facilite la maintenance à long terme du projet.
Alternative envisagée : Node.js (NestJS) offrirait un typage fort natif en TypeScript et un partage de types avec un éventuel frontend web séparé, mais demande une mise en place plus lourde de l'équivalent des policies Laravel pour le multi-tenant, et l'écosystème PDF y est moins mature. Laravel reste donc recommandé pour Markazi.
    • Structure en couches : Controllers → Form Requests (validation) → Services → Repositories → Models Eloquent.
    • Authentification par token via Laravel Sanctum, un token par appareil.
    • Policies Laravel pour appliquer systématiquement la règle « un utilisateur n'agit que sur les données de son Markaz ».
    • Jobs en file d'attente (queue) pour la génération de documents PDF et les traitements différables.
15. Architecture Flutter
    • Architecture en couches : Presentation (widgets, pages) → State management → Domain (use cases, entités) → Data (repositories, sources locale/API).
    • Gestion d'état recommandée : Riverpod ou Bloc, pour une séparation claire de la logique métier et un code testable.
    • Une seule base de code pour Android, iOS et Web ; adaptation de la mise en page via des builders responsives selon la largeur d'écran (mobile / tablette / desktop web).
    • Base de données locale (mode hors ligne) : Drift (SQLite) ou Hive selon le type de données à mettre en cache.
    • Client HTTP centralisé (Dio) avec intercepteurs pour l'authentification, la gestion des erreurs et le rafraîchissement de session.
16. Architecture multi-tenant
Le multi-tenant est la contrainte structurante du projet : bien que la V1 n'active qu'un seul rôle, chaque Markaz doit être totalement isolé dès la conception initiale.
Stratégie retenue : base de données partagée, isolation logique par markaz_id
Une base MySQL unique est utilisée pour tous les Markaz (« shared database, shared schema »), ce qui simplifie l'exploitation à l'échelle de quelques centaines de Markaz. Chaque table métier (students, classes, payments, attendances, recitations, reports, generated_documents, activity_logs) porte une colonne markaz_id en clé étrangère obligatoire, indexée.
    • Backend : un middleware/policy central résout le markaz_id de l'utilisateur authentifié à chaque requête et l'injecte automatiquement dans toute lecture ou écriture ; aucune requête ne doit pouvoir omettre ce filtre.
    • API : aucun identifiant de Markaz n'est accepté depuis le client pour déterminer la portée des données ; il est toujours dérivé du token authentifié côté serveur.
    • Base MySQL : contrainte NOT NULL sur markaz_id, index composé (markaz_id, id) sur les tables volumineuses, clés étrangères avec ON DELETE RESTRICT pour éviter les suppressions accidentelles inter-tenant.
    • Authentification : le token émis à la connexion encode l'identifiant du Markaz de l'utilisateur ; toute tentative d'accès à un Markaz différent est rejetée avant même d'atteindre la logique métier.
    • Autorisation : policies Laravel systématiques sur chaque modèle (« un maître ne peut voir/modifier que les ressources de son propre Markaz »), testées automatiquement (voir section 22).
    • Requêtes : usage de global scopes Eloquent appliquant automatiquement le filtre markaz_id à toute requête, pour éviter les oublis manuels.
    • Cache éventuel : les clés de cache (Redis) sont systématiquement préfixées par markaz_id pour empêcher toute fuite de données en cache entre Markaz.
Cette stratégie permet une isolation stricte tout en gardant une infrastructure simple à opérer ; une évolution vers une base par tenant (schéma dédié) reste possible si un Markaz futur exige une isolation physique renforcée (cas contractuel spécifique), sans remise en cause du modèle applicatif.
17. API REST
L'API suit les conventions REST : ressources nommées au pluriel, verbes HTTP standards, réponses JSON structurées, pagination systématique sur les listes, codes HTTP cohérents. Toutes les routes (hors authentification) exigent un token valide et sont soumises au filtre multi-tenant décrit en section 16.
Ressource	Méthodes	Exemple d'endpoint	Description
Auth	POST	/api/auth/login, /register, /logout, /password/forgot	Cycle de vie du compte et de la session.
Markaz	GET, PUT	/api/markaz	Consultation et mise à jour de la fiche du Markaz courant.
Classes	GET, POST, PUT, DELETE	/api/classes, /api/classes/{id}	Gestion des classes.
Élèves	GET, POST, PUT, DELETE	/api/students, /api/students/{id}	Gestion des élèves, avec recherche et filtres en query params.
Présences	GET, POST	/api/attendances	Enregistrement et consultation des présences par date/classe.
Récitations	GET, POST	/api/recitations	Suivi des séances de récitation par élève.
Paiements	GET, POST	/api/payments	Enregistrement des paiements et historique.
Documents	POST, GET	/api/documents/receipts, /reports/weekly, /reports/monthly	Génération et récupération des documents PDF.
Journal	GET	/api/activity-logs	Consultation de l'historique d'activité.
Conventions générales
    • Pagination par curseur ou par page (page, per_page) sur toutes les listes, avec métadonnées (total, page courante).
    • Filtres et recherche via query params normalisés (search, class_id, status, date_from, date_to).
    • Codes HTTP standards : 200/201 succès, 400 requête invalide, 401 non authentifié, 403 non autorisé (hors périmètre du Markaz), 404 non trouvé, 422 validation, 429 rate limit, 500 erreur serveur.
    • Validation systématique côté serveur (Form Requests Laravel) avant tout traitement, avec messages d'erreur exploitables par le client.
    • Rate limiting par utilisateur/IP sur les routes sensibles (authentification, génération de documents).
    • Documentation API générée (OpenAPI/Swagger) tenue à jour à chaque évolution de contrat.
18. Base de données MySQL
Le schéma relationnel ci-dessous constitue le socle minimal ; chaque table métier porte une colonne markaz_id (sauf la table markaz elle-même et la table users si un utilisateur peut à terme être rattaché à plusieurs Markaz).
Table	Rôle	Relations principales
markaz	Fiche de chaque Markaz (tenant)	1—N vers toutes les tables métier
users	Comptes (maîtres, futurs rôles)	N—1 markaz
classes	Classes du Markaz	N—1 markaz
students	Élèves	N—1 markaz, N—1 classes, N—1 parents
parents	Parents/tuteurs	N—1 markaz, 1—N students
attendances	Présences journalières	N—1 students, N—1 classes
recitations	Séances de récitation	N—1 students
payments	Paiements enregistrés	N—1 students
reports	Rapports générés (méta)	N—1 students
generated_documents	Registre des documents (reçus, rapports, etc.)	N—1 markaz, polymorphique
activity_logs	Journal d'activité	N—1 users, N—1 markaz
Règles de conception
    • Clé primaire auto-incrémentée ou UUID sur chaque table ; markaz_id en clé étrangère indexée sur toutes les tables métier.
    • Timestamps created_at/updated_at systématiques ; soft delete (deleted_at) sur students, classes et payments pour l'archivage sans perte d'historique.
    • Contraintes d'unicité composées lorsque pertinent (ex. un même élève ne peut avoir deux paiements identiques pour le même mois sans confirmation explicite).
    • Index composés (markaz_id, created_at) sur les tables à fort volume (attendances, recitations, activity_logs) pour les requêtes de reporting.
Un diagramme entité-relation (ERD) détaillé, avec cardinalités précises et types de colonnes, doit être produit lors de la phase de conception technique (Phase 1 de la roadmap) et versionné avec le code.
19. Sécurité
    • Authentification : mots de passe hashés (bcrypt/argon2), tokens d'API (Laravel Sanctum), expiration et révocation des tokens par appareil.
    • Transport : HTTPS obligatoire sur toutes les communications, HSTS activé.
    • Autorisation : policies systématiques par ressource, vérifiées côté serveur pour chaque requête (voir section 16).
    • Validation des données : validation stricte de toute entrée utilisateur avant traitement ou stockage.
    • Protection applicative : requêtes préparées (ORM) contre les injections SQL, échappement systématique contre le XSS, protection CSRF sur les routes concernées, en-têtes de sécurité HTTP standards.
    • Rate limiting : limitation du nombre de tentatives sur les routes d'authentification et de génération de documents.
    • Journalisation : logs applicatifs et journal d'activité métier (section 22), conservés de façon non modifiable par les utilisateurs standards.
    • Sauvegardes et secrets : sauvegardes chiffrées (voir section 24) ; secrets (clés API, identifiants base de données) gérés via variables d'environnement et jamais versionnés.
Principe directeur : la sécurité multi-tenant est appliquée exclusivement côté serveur ; le client Flutter n'est jamais considéré comme une source de confiance pour déterminer les droits d'accès aux données.
20. Mode hors ligne
L'application mobile doit rester utilisable en l'absence temporaire de connexion, un scénario fréquent pour des Markaz situés dans des zones à connectivité limitée. La base officielle demeure MySQL via l'API ; le mode hors ligne est un cache local avec file d'attente de synchronisation.
Données disponibles hors ligne
    • Liste des élèves et classes du Markaz courant (lecture).
    • Présences et récitations du jour et des jours récents (lecture et saisie).
    • Paiements récents (lecture) ; la saisie de nouveaux paiements hors ligne est mise en file d'attente.
Fonctionnement du cache et de la synchronisation
    • Cache local en base SQLite embarquée (Drift), peuplé à chaque connexion réussie et rafraîchi périodiquement.
    • Toute action de saisie effectuée hors ligne (présence, récitation, paiement) est stockée localement avec un statut « en attente de synchronisation ».
    • À la reconnexion, une synchronisation automatique rejoue les actions en attente dans leur ordre chronologique, avec accusé de réception de l'API pour chaque élément.
    • Gestion des conflits : en cas de modification concurrente de la même ressource (ex. deux appareils), la règle par défaut est « dernière écriture serveur gagnante », avec conservation d'une trace du conflit dans le journal d'activité pour arbitrage manuel si nécessaire.
    • Indicateur visuel clair dans l'interface signalant l'état de connexion et le nombre d'actions en attente de synchronisation.
21. Documents PDF — Document Engine
Un moteur de génération de documents indépendant (« Document Engine ») centralise la production de tous les documents PDF de la plateforme : reçu de paiement, rapport hebdomadaire, rapport mensuel, et, en évolution future, attestations, certificats et cartes d'élève.
Composants du moteur
    • Templates : gabarits HTML/CSS par type de document, permettant une mise en page fidèle avant conversion PDF (DomPDF ou équivalent).
    • Générateurs : un générateur dédié par type de document, consommant un template et un jeu de données structurées.
    • Thèmes et branding : injection automatique du logo, des couleurs et des coordonnées du Markaz dans chaque document.
    • Signature et cachet : zones dédiées dans le template, alimentées si le Markaz a fourni ces éléments.
    • Numérotation : séquence unique par Markaz et par type de document (ex. reçu n° MK-2026-000123).
    • Métadonnées et versionnement : chaque document généré est enregistré dans generated_documents avec son type, sa version de template, sa date et son auteur.
Contenu du reçu de paiement
Logo Markazi, logo du Markaz si disponible, nom et coordonnées du Markaz, numéro du reçu, nom de l'élève et du parent, téléphone du parent, montant, mois concerné, date, nom du maître ayant enregistré le paiement, zone de signature et de cachet.
Partage
Chaque document généré peut être prévisualisé, téléchargé, enregistré et imprimé, puis partagé via les mécanismes natifs de partage d'Android, iOS et Web (share sheet système). Aucune intégration propriétaire avec WhatsApp ou un autre service n'est développée : le partage se fait vers l'application choisie par l'utilisateur au moment du partage.
22. Tests
Type de test	Portée	Priorité
Tests unitaires	Services métier, calculs (taux de présence, progression)	Critique
Tests des Services / Repositories	Logique d'accès aux données, isolation multi-tenant	Critique
Tests API	Endpoints REST, codes de statut, validation, autorisation	Critique
Tests Widget Flutter	Composants d'interface clés (formulaires, listes)	Élevée
Tests d'intégration	Parcours complets (présence → rapport, paiement → reçu)	Élevée
Tests de sécurité	Authentification, injection, contrôle d'accès	Critique
Tests multi-tenant	Isolation stricte des données entre deux Markaz distincts	Critique
Les fonctionnalités devant impérativement être couvertes par des tests automatisés avant toute mise en production sont : l'authentification, l'isolation multi-tenant sur chaque ressource, l'enregistrement des paiements et la génération des reçus, ainsi que les calculs de taux de présence et de progression, car ce sont les points où une régression aurait un impact direct sur la confiance des utilisateurs.
23. Déploiement
Flutter
    • Android : publication sur Google Play Store, gestion des versions et des canaux de test (interne, fermé, production).
    • iOS : publication sur l'App Store via App Store Connect, respect des guidelines Apple (notamment sur le partage de fichiers et l'absence de paiement in-app).
    • Web : déploiement sur un hébergement statique avec CDN, nom de domaine dédié en HTTPS.
Backend
    • Serveur applicatif (VPS ou PaaS) hébergeant l'API Laravel, avec environnement de staging et de production distincts.
    • Base MySQL managée ou auto-hébergée avec sauvegardes automatisées (voir section 24).
    • Stockage des fichiers (logos, documents PDF) sur volume dédié ou stockage compatible S3.
    • Monitoring et logs applicatifs centralisés, alertes en cas d'erreur critique ou de dépassement de seuils.
    • HTTPS obligatoire avec certificat renouvelé automatiquement, nom de domaine dédié à l'API.
Étapes de publication
    • Recette fonctionnelle sur environnement de staging avant chaque mise en production.
    • Soumission Google Play (délai court) puis App Store (délai de revue plus long, à anticiper).
    • Mise en production du web et de l'API en parallèle de la publication mobile, avec bascule progressive.
24. Sauvegardes et récupération
    • Sauvegardes MySQL : sauvegarde complète quotidienne et sauvegarde incrémentale (binlog) pour permettre une restauration à un instant précis.
    • Fréquence : quotidienne pour les sauvegardes complètes, continue pour les journaux de transactions.
    • Rétention : conservation glissante sur 30 jours minimum, avec archivage mensuel plus long pour la conformité et l'historique métier.
    • Restauration : procédure documentée et testée périodiquement (restauration à blanc) pour garantir un délai de reprise maîtrisé.
    • Reprise après incident : plan simple mais formalisé — bascule vers une sauvegarde récente, communication aux Markaz affectés, post-mortem systématique après tout incident majeur.
Concernant les notifications, la contrainte explicite du projet exclut Firebase Cloud Messaging. L'architecture prévoit une table de notifications internes consultables dans l'application (polling ou WebSocket léger via le backend REST/MySQL existant) ; si un besoin de notification push natif s'avère indispensable, il sera traité comme une évolution future nécessitant un service externe, à évaluer et documenter séparément (voir section 29).
25. Performances
    • Pagination systématique sur toutes les listes (élèves, paiements, présences) pour éviter le chargement de volumes non maîtrisés.
    • Cache applicatif (Redis) pour les données peu volatiles (fiche Markaz, listes de classes) avec invalidation ciblée par markaz_id.
    • Index MySQL alignés sur les requêtes de reporting les plus fréquentes (filtrage par Markaz, par élève, par période).
    • Requêtes optimisées : chargement différé (eager loading maîtrisé) pour éviter les problèmes de requêtes N+1 côté Laravel/Eloquent.
    • Chargement progressif des listes longues côté Flutter (pagination infinie), avec squelettes de chargement plutôt que des blocages d'interface.
    • Compression et redimensionnement des images (photos élèves, logos) avant stockage et à l'affichage.
    • Génération des PDF volumineux en tâche asynchrone (file d'attente) pour ne jamais bloquer l'interface utilisateur.
    • Attention portée à la consommation réseau et mémoire sur mobile d'entrée de gamme, matériel représentatif du terrain visé.
L'application doit pouvoir évoluer progressivement de quelques Markaz pilotes à plusieurs centaines de Markaz actifs simultanément, sans refonte architecturale, grâce à la stratégie d'isolation logique et d'indexation décrite en sections 16 et 18.
26. Roadmap
Phase	Objectif	Livrables clés
1 — Fondations	Architecture et environnements	Dépôts de code, environnements dev/staging, ERD validé, squelette Laravel + Flutter
2 — Auth & multi-Markaz	Authentification et isolation tenant	Inscription/connexion, policies multi-tenant, fiche Markaz
3 — Élèves & classes	Gestion pédagogique de base	CRUD élèves, classes, parents, fiche élève détaillée
4 — Présences & récitations	Suivi quotidien	Marquage de présence, suivi de récitation, calcul de progression
5 — Paiements	Gestion financière manuelle	Enregistrement des paiements, détection de doublons, historique
6 — Document Engine & PDF	Génération de documents	Reçu PDF, moteur de templates, partage natif
7 — Dashboard & statistiques	Pilotage	Tableau de bord, rapports hebdo/mensuel, graphiques
8 — Offline & synchronisation	Continuité de service	Cache local, file d'attente, résolution de conflits
9 — Tests & sécurité	Fiabilisation	Suites de tests automatisés, audit de sécurité, correctifs
10 — Déploiement	Mise en production	Publication Play Store/App Store, mise en ligne web, monitoring
Pour chaque phase, l'équipe doit formaliser en amont les dépendances vis-à-vis des phases précédentes et les critères d'acceptation associés (voir section 27), afin qu'une phase ne démarre que lorsque ses prérequis fonctionnels et techniques sont réellement disponibles.
27. Critères d'acceptation
Chaque fonctionnalité importante doit être assortie de critères vérifiables permettant de statuer objectivement sur sa complétude. Exemples représentatifs :
    • Un maître peut créer un élève appartenant à son Markaz ; un autre Markaz ne peut jamais consulter, modifier ou supprimer cet élève, y compris en modifiant manuellement les identifiants dans les requêtes API.
    • Un paiement enregistré génère systématiquement un reçu PDF conforme au gabarit défini, incluant les informations du Markaz et de l'élève concerné.
    • Le taux de présence affiché pour un élève correspond exactement au calcul (jours présents / jours de cours) sur la période sélectionnée, vérifié par des tests automatisés.
    • Une action réalisée hors ligne apparaît dans l'historique dès la synchronisation, avec la date réelle de réalisation et non la date de synchronisation.
    • Aucune route API protégée n'est accessible sans token valide, et aucune route ne renvoie de données d'un Markaz différent de celui de l'utilisateur authentifié.
28. Risques
Risque	Impact	Mitigation
Fuite de données entre Markaz (défaut d'isolation)	Élevé	Global scopes systématiques, policies testées, tests multi-tenant obligatoires (section 22)
Connectivité Internet instable sur le terrain	Moyen	Mode hors ligne robuste avec synchronisation différée (section 20)
Faible appétence numérique de certains maîtres	Moyen	UX simplifiée, onboarding guidé, formation/support à prévoir
Volumétrie de documents PDF impactant la performance	Faible	Génération asynchrone en file d'attente (section 25)
Retard de validation App Store	Moyen	Anticiper la soumission, respecter strictement les guidelines dès la conception
Dérive de périmètre vers une application scolaire générique	Moyen	Vocabulaire et fonctionnalités systématiquement validés vis-à-vis du métier du Markaz
29. Évolutions futures
    • Application dédiée aux parents (consultation en lecture seule).
    • Support de plusieurs enseignants par Markaz, avec répartition des classes.
    • Rôles Admin Markaz et Super Admin de la plateforme.
    • Notifications avancées (rappel d'absence, rappel de paiement, rapport disponible) — nécessitant l'évaluation d'un service externe compatible avec l'architecture REST/MySQL, hors Firebase.
    • Statistiques et tableaux de bord avancés (comparaisons inter-classes, tendances sur plusieurs mois).
    • Attestations et certificats de mémorisation, cartes d'élève, via le Document Engine déjà en place.
    • Portail web dédié aux parents et aux structures fédératrices de Markaz.
    • Multilinguisme : arabe et anglais, en complément du français.
    • Stratégie de sauvegarde avancée (réplication multi-site, sauvegardes off-site automatisées).
30. Conclusion
Markazi répond à un besoin métier précis et sous-desservi : la gestion numérique d'un Markaz, avec le vocabulaire et les processus propres à l'enseignement coranique, sans dépendre d'un système de paiement en ligne et sans recourir aux briques Firebase/Supabase/MongoDB explicitement exclues du projet.
La V1 livre une application complète pour un maître unique, tout en posant dès la première ligne de code une architecture multi-tenant sécurisée, capable d'accueillir sans refonte les évolutions attendues : plusieurs enseignants, rôles d'administration, accès parent, notifications avancées. Le découpage en dix phases (section 26) et les critères d'acceptation associés (section 27) donnent à l'équipe de développement une trajectoire claire, vérifiable à chaque étape, pour livrer un produit fiable, sécurisé et fidèle aux réalités de terrain des Markaz.
