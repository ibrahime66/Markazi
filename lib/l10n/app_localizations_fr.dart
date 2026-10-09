// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navOverview => 'Vue d\'ensemble';

  @override
  String get navStudents => 'Élèves';

  @override
  String get navGroups => 'Groupes';

  @override
  String get navPayments => 'Paiements';

  @override
  String get navAttendance => 'Présences';

  @override
  String get navReports => 'Rapports';

  @override
  String get navMyMarkaz => 'Mon Markaz';

  @override
  String get navGuardians => 'Tuteurs / Parents';

  @override
  String get navRecitations => 'Récitations';

  @override
  String get navLogout => 'Déconnexion';

  @override
  String get navDarkMode => 'Mode sombre';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSaving => 'Enregistrement...';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionDownload => 'Télécharger';

  @override
  String get markazSettingsTitle => 'Mon Markaz';

  @override
  String get markazHeaderSubtitle =>
      'Ces informations sont utilisées dans toute l\'application.';

  @override
  String get markazSectionIdentity => 'Identité';

  @override
  String get markazSectionIdentitySubtitle =>
      'Apparaît sur les reçus et rapports générés.';

  @override
  String get markazSectionContact => 'Coordonnées';

  @override
  String get markazSectionFinance => 'Finance';

  @override
  String get markazSectionFinanceSubtitle =>
      'Devise utilisée pour tous les montants de l\'app.';

  @override
  String get markazSectionSchedule => 'Jours de cours';

  @override
  String get markazSectionScheduleSubtitle =>
      'Utilisés pour calculer le taux de présence des élèves.';

  @override
  String get markazSectionAppearance => 'Apparence';

  @override
  String get markazSectionAppearanceSubtitle =>
      'Choisissez l\'apparence de l\'application sur cet appareil.';

  @override
  String get markazSectionLanguage => 'Langue';

  @override
  String get markazSectionLanguageSubtitle =>
      'Choisissez la langue de l\'application.';

  @override
  String get fieldMarkazName => 'Nom du Markaz';

  @override
  String get fieldSlogan => 'Slogan';

  @override
  String get fieldAddress => 'Adresse';

  @override
  String get fieldCity => 'Ville';

  @override
  String get fieldCountry => 'Pays';

  @override
  String get fieldCurrency => 'Devise (ex: GNF, XOF, EUR)';

  @override
  String get fieldPhone => 'Téléphone';

  @override
  String get fieldEmail => 'Email';

  @override
  String get appearanceSystem => 'Système';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get markazNameRequired => 'Le nom du Markaz est obligatoire';

  @override
  String get markazUpdated => 'Fiche Markaz mise à jour';

  @override
  String get genericError => 'Erreur';

  @override
  String get navActivityLog => 'Journal d\'activité';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get activityFilterAll => 'Tout';

  @override
  String get activityCategoryStudent => 'Élèves';

  @override
  String get activityCategoryClass => 'Groupes';

  @override
  String get activityCategoryGuardian => 'Tuteurs';

  @override
  String get activityCategoryAttendance => 'Présences';

  @override
  String get activityCategoryRecitation => 'Récitations';

  @override
  String get activityCategoryPayment => 'Paiements';

  @override
  String get activityCategoryMarkaz => 'Markaz';

  @override
  String get activityCategoryUser => 'Compte';

  @override
  String get activityCategorySync => 'Conflits';

  @override
  String get activityPeriodAll => 'Toutes les dates';

  @override
  String get activityPeriod7 => '7 derniers jours';

  @override
  String get activityPeriod30 => '30 derniers jours';

  @override
  String get activityToday => 'Aujourd\'hui';

  @override
  String get activityYesterday => 'Hier';

  @override
  String get activityEmpty => 'Aucune activité pour ce filtre.';

  @override
  String get activityLoadError =>
      'Impossible de charger le journal. Vérifiez votre connexion.';

  @override
  String get activityOfflineBadge => 'Saisi hors ligne';

  @override
  String activityByUser(String name) {
    return 'par $name';
  }

  @override
  String get activityConflictTitle => 'Conflit de synchronisation';

  @override
  String activityConflictExplanation(
      String performedAt, String serverUpdatedAt) {
    return 'Cette action a été faite hors ligne le $performedAt, mais la donnée avait été modifiée entre-temps sur le serveur (le $serverUpdatedAt). La version hors ligne a été appliquée. Version serveur remplacée :';
  }

  @override
  String get activityConflictHint => 'Touchez pour voir la version remplacée';

  @override
  String get receiptPendingSync =>
      'Paiement enregistré hors ligne. Le reçu sera disponible après synchronisation (son numéro est attribué par le serveur).';

  @override
  String get navSync => 'Synchronisation';

  @override
  String get syncOnline => 'Connecté au serveur';

  @override
  String get syncOffline => 'Hors ligne';

  @override
  String get syncOfflineBanner =>
      'Hors ligne — vos saisies sont enregistrées sur l\'appareil et seront envoyées automatiquement.';

  @override
  String syncPendingBanner(String count) {
    return '$count action(s) en attente de synchronisation';
  }

  @override
  String syncFailedBanner(String count) {
    return '$count action(s) refusée(s) par le serveur — à vérifier';
  }

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncInProgress => 'Synchronisation en cours…';

  @override
  String get syncAllDone => 'Tout est synchronisé.';

  @override
  String syncResult(String synced, String failed) {
    return '$synced action(s) envoyée(s), $failed refusée(s).';
  }

  @override
  String get syncStillOffline =>
      'Serveur toujours injoignable. Nouvel essai automatique dès le retour de la connexion.';

  @override
  String get syncEmpty =>
      'Aucune action en attente. Toutes vos saisies sont sur le serveur.';

  @override
  String get syncPendingTitle => 'Actions en attente';

  @override
  String get syncOpCreate => 'Création';

  @override
  String get syncOpUpdate => 'Modification';

  @override
  String get syncOpDelete => 'Suppression';

  @override
  String get syncEntityPayment => 'Paiement';

  @override
  String get syncEntityAttendance => 'Présence';

  @override
  String get syncEntityGuardian => 'Tuteur';

  @override
  String get syncEntityRecitation => 'Récitation';

  @override
  String get syncEntityClass => 'Groupe';

  @override
  String get syncEntityStudentClass => 'Affectation à un groupe';

  @override
  String syncDoneAt(String date) {
    return 'Saisi le $date';
  }

  @override
  String syncRejected(String message) {
    return 'Refusé par le serveur : $message';
  }

  @override
  String get syncDiscard => 'Abandonner cette action';

  @override
  String get syncDiscardConfirmTitle => 'Abandonner cette action ?';

  @override
  String get syncDiscardConfirmBody =>
      'Elle ne sera jamais envoyée au serveur. Une création sera retirée de l\'appareil ; une modification sera remplacée par la version du serveur à la prochaine synchronisation.';

  @override
  String get syncConflictsHint =>
      'Les conflits éventuels (donnée modifiée entre-temps sur le serveur) sont consultables dans le journal d\'activité.';

  @override
  String get guardianDeleteTitle => 'Supprimer ce tuteur ?';

  @override
  String guardianDeleteBody(Object guardian) {
    return '« $guardian » sera définitivement supprimé.';
  }

  @override
  String get guardianDeleted => 'Tuteur supprimé';

  @override
  String commonErrorWithDetail(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get guardianEmptyTitle => 'Aucun tuteur enregistré';

  @override
  String get guardianEmptyBody =>
      'Ajoutez les parents/tuteurs pour les rattacher aux élèves.';

  @override
  String get guardianNamePhoneRequired => 'Nom et téléphone sont obligatoires';

  @override
  String get guardianEditTitle => 'Modifier le tuteur';

  @override
  String get guardianAddTitle => 'Ajouter un tuteur';

  @override
  String get fieldNameRequired => 'Nom *';

  @override
  String get fieldPhoneRequired => 'Téléphone *';

  @override
  String get guardianLinkedStudents => 'Élèves rattachés';

  @override
  String get commonAddStudentFirst => 'Ajoutez d\'abord un élève';

  @override
  String get recitationDeleteTitle => 'Supprimer cette séance ?';

  @override
  String get recitationDeleteBody =>
      'Cette récitation sera définitivement supprimée.';

  @override
  String get recitationDeleted => 'Récitation supprimée';

  @override
  String get recitationStatusRecited => 'Récité';

  @override
  String get recitationStatusPartial => 'Partiel';

  @override
  String get recitationStatusNotRecited => 'Non récité';

  @override
  String get recitationEmptyTitle => 'Aucune récitation enregistrée';

  @override
  String get recitationEmptyBody =>
      'Enregistrez la sourate étudiée par chaque élève après chaque séance.';

  @override
  String get commonStudentDeleted => 'Élève supprimé';

  @override
  String recitationVerseRange(Object ayahFrom, Object ayahTo) {
    return ' (versets $ayahFrom-$ayahTo)';
  }

  @override
  String get recitationSurahRequired => 'La sourate est obligatoire';

  @override
  String get recitationEditTitle => 'Modifier la récitation';

  @override
  String get recitationAddTitle => 'Enregistrer une récitation';

  @override
  String get fieldStudentRequired => 'Élève *';

  @override
  String commonDateDmy(Object day, Object month, Object year) {
    return 'Date : $day/$month/$year';
  }

  @override
  String get fieldSurahRequired => 'Sourate *';

  @override
  String get fieldAyahFrom => 'Verset début';

  @override
  String get fieldAyahTo => 'Verset fin';

  @override
  String get fieldStatus => 'Statut';

  @override
  String get fieldNoteOptional => 'Note (optionnel)';

  @override
  String get groupInfoTitle => 'Informations du groupe';

  @override
  String get fieldLevel => 'Niveau';

  @override
  String get fieldTeacher => 'Enseignant';

  @override
  String get fieldCapacity => 'Capacité';

  @override
  String groupCapacityValue(Object studentIdsCount, Object maxStudents) {
    return '$studentIdsCount/$maxStudents élèves';
  }

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldSchedule => 'Emploi du temps';

  @override
  String get fieldRoom => 'Salle';

  @override
  String get commonInactive => 'Inactif';

  @override
  String get fieldCreatedOn => 'Créé le';

  @override
  String get groupStatsTitle => 'Statistiques du groupe';

  @override
  String get statAttendanceRate => 'Taux présence';

  @override
  String get statPaymentRate => 'Taux paiement';

  @override
  String get statTotalPaid => 'Total payé';

  @override
  String get groupNoStudents => 'Aucun élève dans ce groupe';

  @override
  String get groupStudentsTitle => 'Élèves du groupe';

  @override
  String get fieldStudentName => 'Nom de l\'élève';

  @override
  String get fieldAmount => 'Montant';

  @override
  String get authEnterValidEmail => 'Entrez un email valide';

  @override
  String get forgotCodeSent =>
      'Code envoyé par email. Vérifiez aussi vos spams.';

  @override
  String get authAllFieldsRequired => 'Tous les champs doivent être remplis';

  @override
  String get authPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get forgotPasswordReset =>
      'Mot de passe réinitialisé. Connectez-vous.';

  @override
  String get forgotTitle => 'Mot de passe oublié';

  @override
  String get forgotStepCode =>
      'Entrez le code reçu par email et votre nouveau mot de passe.';

  @override
  String get forgotStepEmail =>
      'Entrez votre email, un code de réinitialisation vous sera envoyé.';

  @override
  String get authEmailHint => 'votre.email@exemple.com';

  @override
  String get forgotSendCode => 'Envoyer le code';

  @override
  String get forgotCodeLabel => 'Code reçu par email';

  @override
  String get forgotCodeHint => 'Collez le code ici';

  @override
  String get forgotNewPassword => 'Nouveau mot de passe';

  @override
  String get authPasswordHint => 'Au moins 6 caractères';

  @override
  String get forgotConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get forgotResetButton => 'Réinitialiser le mot de passe';

  @override
  String get forgotRestart => 'Je n\'ai pas reçu de code, recommencer';

  @override
  String get authInvalidEmail => 'Email invalide';

  @override
  String get loginUnknownError => 'Erreur inconnue lors de la connexion';

  @override
  String get loginError => 'Erreur de connexion. Veuillez réessayer.';

  @override
  String get registerUnknownError =>
      'Erreur inconnue lors de la création du compte';

  @override
  String get registerError =>
      'Erreur lors de la création du compte. Veuillez réessayer.';

  @override
  String get authLogin => 'Se connecter';

  @override
  String get loginSubtitle => 'Accédez à votre compte markaz';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginNoAccount => 'Pas encore de compte ? ';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get registerSubtitle => 'Rejoignez Markazi en quelques secondes';

  @override
  String get fieldFullName => 'Nom complet';

  @override
  String get registerNameHint => 'Ex: Ahmed Ben Ali';

  @override
  String get registerMarkazHint => 'Ex: Markaz Al-Nour';

  @override
  String get registerHaveAccount => 'Vous avez déjà un compte ? ';

  @override
  String get splashTagline => 'Gérez votre markaz\nsimplement et efficacement';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get dayShortMon => 'Lun';

  @override
  String get dayShortTue => 'Mar';

  @override
  String get dayShortWed => 'Mer';

  @override
  String get dayShortThu => 'Jeu';

  @override
  String get dayShortFri => 'Ven';

  @override
  String get dayShortSat => 'Sam';

  @override
  String get dayShortSun => 'Dim';

  @override
  String get onboardingTitle1 => 'Gérez vos élèves\nfacilement';

  @override
  String get onboardingBody1 =>
      'Ajoutez vos élèves et leurs informations complètes en quelques secondes. Retrouvez-les facilement à tout moment.';

  @override
  String get onboardingTitle2 => 'Suivez les\npaiements';

  @override
  String get onboardingBody2 =>
      'Enregistrez les paiements et générez automatiquement des reçus. Plus de confusion dans la gestion financière.';

  @override
  String get onboardingTitle3 => 'Suivi journalier\ndes cours';

  @override
  String get onboardingBody3 =>
      'Notez chaque jour la progression des élèves et leur récitation. Un suivi précis et structuré pour chaque séance.';

  @override
  String get onboardingTitle4 => 'Rapports\nautomatiques';

  @override
  String get onboardingBody4 =>
      'Obtenez des statistiques hebdomadaires et mensuelles exportables en PDF. Partagez facilement avec les parents.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get homeMainFeatures => 'Fonctionnalités principales';

  @override
  String get homeMainFeaturesSubtitle =>
      'Tout ce dont vous avez besoin pour gérer votre markaz';

  @override
  String get homeWhyTitle => 'Pourquoi choisir Markazi ?';

  @override
  String get homeWhySubtitle => 'Les avantages qui font la différence';

  @override
  String get navFeatures => 'Fonctionnalités';

  @override
  String get navAbout => 'À propos';

  @override
  String get homeBadge => 'Solution pour maîtres de markaz';

  @override
  String get homeHeroTitle => 'Gérez votre markaz\nde façon moderne';

  @override
  String get homeHeroBody =>
      'Élèves, paiements, présences, récitation — tout centralisé dans une seule application simple et efficace.';

  @override
  String get homeStatFree => 'Gratuit';

  @override
  String get homeStatFiveMin => '5 min';

  @override
  String get homeStatToStart => 'Pour démarrer';

  @override
  String get homeStatMulti => 'Multi';

  @override
  String get homeFeatureStudents => 'Gestion élèves';

  @override
  String get homeFeatureStats => 'Statistiques';

  @override
  String get homeFeatureReports => 'Rapports PDF';

  @override
  String get homeAdvTimeTitle => 'Gain de temps';

  @override
  String get homeAdvTimeBody =>
      'Réduisez le temps administratif de 80%. Concentrez-vous sur ce qui compte : l\'enseignement.';

  @override
  String get homeAdvOrgTitle => 'Mieux organisé';

  @override
  String get homeAdvOrgBody =>
      'Toutes vos données centralisées, accessibles partout et à tout moment depuis votre téléphone.';

  @override
  String get homeAdvParentsTitle => 'Communication parents';

  @override
  String get homeAdvParentsBody =>
      'Partagez reçus et rapports PDF avec les familles de vos élèves en un geste.';

  @override
  String get homeCtaTitle => 'Prêt à digitaliser votre markaz ?';

  @override
  String get homeCtaBody =>
      'Rejoignez les maîtres qui gèrent leur markaz avec Markazi.';

  @override
  String get homeStart => 'Commencer';

  @override
  String get homeLearnMore => 'En savoir plus';

  @override
  String get appTagline => 'La solution digitale pour les markaz islamiques';

  @override
  String get aboutBadgeIslamic => 'Islamique';

  @override
  String get aboutBadgeMobile => 'Mobile First';

  @override
  String get aboutBadgeAfrica => 'Afrique';

  @override
  String get aboutGoalTitle => 'Notre objectif';

  @override
  String get aboutGoalSubtitle => 'Digitaliser les markaz';

  @override
  String get aboutGoalBody1 =>
      'Markazi est né d\'un constat simple : les maîtres de markaz gèrent encore leur école avec des cahiers, des notes manuscrites et de la mémoire.';

  @override
  String get aboutGoalBody2 =>
      'Notre objectif est de leur offrir un outil numérique moderne, simple et adapté à leurs besoins, pour qu\'ils puissent se concentrer sur l\'essentiel : transmettre le savoir islamique.';

  @override
  String get aboutVisionTitle => 'Notre vision';

  @override
  String get aboutVisionModernTitle => 'Solution moderne';

  @override
  String get aboutVisionModernBody =>
      'Une application pensée pour les réalités des maîtres africains : simple, rapide et fonctionnant même avec une connexion limitée.';

  @override
  String get aboutVisionEcosystemTitle => 'Écosystème connecté';

  @override
  String get aboutVisionEcosystemBody =>
      'À terme, relier les maîtres, les élèves et les parents dans un seul écosystème pour une meilleure communication et suivi.';

  @override
  String get aboutVisionImpactTitle => 'Impact continental';

  @override
  String get aboutVisionImpactBody =>
      'Devenir la référence en gestion de markaz à travers l\'Afrique francophone et au-delà.';

  @override
  String get aboutApproachTitle => 'Notre approche';

  @override
  String get aboutApproachUserTitle => 'Centré utilisateur';

  @override
  String get aboutApproachUserBody =>
      'Conçu avec et pour les maîtres de markaz';

  @override
  String get aboutApproachOfflineBody =>
      'Fonctionne sans connexion internet permanente';

  @override
  String get aboutApproachSecureTitle => 'Sécurisé';

  @override
  String get aboutApproachSecureBody =>
      'Vos données protégées et confidentielles';

  @override
  String get aboutApproachLangTitle => 'Multilingue';

  @override
  String get aboutApproachLangBody => 'Français, anglais et arabe';

  @override
  String get aboutValuesTitle => 'Nos valeurs';

  @override
  String get aboutValueSimplicityTitle => 'Simplicité';

  @override
  String get aboutValueSimplicityBody =>
      'Un outil qui ne demande pas de formation. Intuitif dès le premier jour.';

  @override
  String get aboutValueRespectTitle => 'Respect';

  @override
  String get aboutValueRespectBody =>
      'Respectueux des valeurs islamiques et des pratiques des communautés.';

  @override
  String get aboutValueImpactTitle => 'Impact';

  @override
  String get aboutValueImpactBody =>
      'Chaque fonctionnalité est conçue pour avoir un impact réel sur le quotidien du maître.';

  @override
  String get aboutContactTitle => 'Contactez-nous';

  @override
  String get aboutContactBody =>
      'Une question, une suggestion ou un partenariat ?\nNous sommes à votre écoute.';

  @override
  String get aboutContactButton => 'Nous contacter';

  @override
  String get featStudentsTitle => 'Gestion des élèves';

  @override
  String get featStudentsBody =>
      'Créez une fiche complète pour chaque élève : nom, prénom, date de naissance, informations des parents, niveau en Coran, date d\'inscription. Recherchez, filtrez et gérez facilement tous vos élèves depuis une seule page.';

  @override
  String get featStudentsH1 => 'Fiche individuelle complète';

  @override
  String get featStudentsH2 => 'Informations des parents';

  @override
  String get featStudentsH3 => 'Historique de progression';

  @override
  String get featStudentsH4 => 'Recherche et filtrage rapides';

  @override
  String get featPaymentsTitle => 'Paiements & Reçus';

  @override
  String get featPaymentsBody =>
      'Gérez les mensualités de chaque élève. Enregistrez les paiements reçus et générez automatiquement des reçus PDF professionnels. Consultez l\'historique des paiements et identifiez facilement les retards.';

  @override
  String get featPaymentsH1 => 'Suivi des mensualités';

  @override
  String get featPaymentsH2 => 'Génération de reçus PDF';

  @override
  String get featPaymentsH3 => 'Historique des paiements';

  @override
  String get featPaymentsH4 => 'Alertes de retard';

  @override
  String get featAttendanceTitle => 'Présence & Récitation';

  @override
  String get featAttendanceBody =>
      'Pointez les présences et les absences chaque jour en quelques secondes. Évaluez la récitation de chaque élève à chaque séance. Un historique complet pour suivre l\'assiduité et la progression.';

  @override
  String get featAttendanceH1 => 'Pointage quotidien rapide';

  @override
  String get featAttendanceH2 => 'Évaluation de récitation';

  @override
  String get featAttendanceH3 => 'Historique de présence';

  @override
  String get featAttendanceH4 => 'Notes personnalisées';

  @override
  String get featStatsTitle => 'Statistiques hebdomadaires';

  @override
  String get featStatsBody =>
      'Obtenez une vue d\'ensemble de votre classe chaque semaine. Taux d\'assiduité, progression en récitation, paiements reçus — toutes les métriques importantes visualisées clairement.';

  @override
  String get featStatsH1 => 'Tableau de bord hebdomadaire';

  @override
  String get featStatsH2 => 'Graphiques de progression';

  @override
  String get featStatsH3 => 'Taux d\'assiduité';

  @override
  String get featStatsH4 => 'Comparaison des élèves';

  @override
  String get featReportTitle => 'Rapport mensuel PDF';

  @override
  String get featReportBody =>
      'Générez un rapport mensuel complet pour chaque élève ou pour toute la classe. Partagez-le avec les parents par WhatsApp, e-mail ou toute application de votre téléphone. Rapport professionnel avec toutes les informations importantes.';

  @override
  String get featReportH1 => 'Rapport élève individuel';

  @override
  String get featReportH2 => 'Rapport de classe complet';

  @override
  String get featReportH3 => 'Partage WhatsApp, e-mail…';

  @override
  String get featReportH4 => 'Format PDF professionnel';

  @override
  String get featAbsenceTitle => 'Gestion des absences';

  @override
  String get featAbsenceBody =>
      'Suivez le taux d\'absentéisme de chaque élève sur les jours de cours réels du markaz. Distinguez les absences justifiées et partagez les rapports d\'assiduité avec les parents.';

  @override
  String get featAbsenceH1 => 'Taux d\'absentéisme par élève';

  @override
  String get featAbsenceH2 => 'Jours de cours configurables';

  @override
  String get featAbsenceH3 => 'Rapports d\'assiduité à partager';

  @override
  String get featAbsenceH4 => 'Justifications d\'absence';

  @override
  String get featHeaderBadge => '6 fonctionnalités essentielles';

  @override
  String get featHeaderTitle =>
      'Tout ce qu\'il vous faut\npour gérer votre markaz';

  @override
  String get featHeaderBody =>
      'Markazi regroupe tous les outils nécessaires à la gestion quotidienne de votre markaz dans une application simple et intuitive.';

  @override
  String get featCtaTitle => 'Essayez Markazi gratuitement';

  @override
  String get featCtaBody =>
      'Créez votre compte et démarrez en moins de 5 minutes.';

  @override
  String get featCtaButton => 'Créer mon compte';
}
