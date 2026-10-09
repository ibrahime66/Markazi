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

  @override
  String get dashUserFallback => 'Utilisateur';

  @override
  String dashWelcome(Object userName) {
    return 'Bienvenue, $userName';
  }

  @override
  String get dashGeneralStats => 'Statistiques générales';

  @override
  String get dashQuickActions => 'Actions rapides';

  @override
  String get dashMyGroups => 'Mes groupes';

  @override
  String get dashRecentPayments => 'Paiements récents';

  @override
  String get dashSeeAll => 'Tout voir';

  @override
  String get dashNoGroupYet => 'Aucun groupe créé pour l\'instant';

  @override
  String dashActiveGroups(Object activeCount) {
    return '$activeCount groupe(s) actif(s)';
  }

  @override
  String dashSeatsOccupied(Object occupied, Object capacity) {
    return '$occupied / $capacity places occupées';
  }

  @override
  String get dashNoPaymentYet => 'Aucun paiement enregistré pour l\'instant';

  @override
  String dashStudentsCount(Object studentsCount) {
    return '$studentsCount élève(s)';
  }

  @override
  String get dashNoStudent => 'Aucun élève enregistré';

  @override
  String dashPhoneShort(Object parentPhone) {
    return 'Tél: $parentPhone';
  }

  @override
  String get dashEditStudent => 'Modifier l\'élève';

  @override
  String get dashDeleteStudent => 'Supprimer l\'élève';

  @override
  String dashPaymentsCount(Object validPaymentsCount) {
    return '$validPaymentsCount paiement(s)';
  }

  @override
  String get dashNoPayment => 'Aucun paiement enregistré';

  @override
  String get dashNoValidPayment => 'Aucun paiement valide (élèves supprimés)';

  @override
  String dashPaymentsOfRemoved(Object paymentsCount) {
    return '$paymentsCount paiement(s) lié(s) à des élèves supprimés';
  }

  @override
  String dashAttendancesCount(Object validAttendancesCount) {
    return '$validAttendancesCount présence(s)';
  }

  @override
  String get dashNoAttendance => 'Aucune présence enregistrée';

  @override
  String get dashNoValidAttendance =>
      'Aucune présence valide (élèves supprimés)';

  @override
  String dashAttendancesOfRemoved(Object attendancesCount) {
    return '$attendancesCount présence(s) liée(s) à des élèves supprimés';
  }

  @override
  String get attendancePresent => 'Présent';

  @override
  String get attendanceAbsent => 'Absent';

  @override
  String get attendanceJustified => 'Absence justifiée';

  @override
  String get attendanceLate => 'Tardif';

  @override
  String get dashGenerateReports => 'Générer des rapports';

  @override
  String get dashWeeklyReport => 'Rapport hebdomadaire';

  @override
  String get dashMonthlyReport => 'Rapport mensuel';

  @override
  String get dashPaymentReport => 'Rapport des paiements';

  @override
  String get dashPerformanceReport => 'Rapport de performance';

  @override
  String get dashAttendanceByStudentShort => 'Taux présence par élève';

  @override
  String get dashExport => 'Export';

  @override
  String get dashExportPdf => 'Exporter en PDF';

  @override
  String get dashAddNewStudent => 'Ajouter un nouvel élève';

  @override
  String get fieldParentPhone => 'Téléphone du parent';

  @override
  String get dashPhoneHint => 'Ex: 622180933';

  @override
  String get commonFillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get commonInvalidPhone => 'Numéro de téléphone invalide';

  @override
  String get dashStudentAdded => 'Élève ajouté avec succès!';

  @override
  String commonErrorColon(Object error) {
    return 'Erreur: $error';
  }

  @override
  String get dashStudentUpdated => 'Élève modifié avec succès!';

  @override
  String get dashArchiveStudentTitle => 'Archiver cet élève ?';

  @override
  String get dashArchiveStudentQuestion =>
      'Êtes-vous sûr de vouloir retirer cet élève de la liste ?';

  @override
  String dashNameLine(Object student) {
    return 'Nom: $student';
  }

  @override
  String get dashArchiveStudentBody =>
      'L\'élève sera archivé : il n\'apparaîtra plus dans les listes, mais son historique (paiements, présences, récitations) est conservé et reste compté dans les totaux financiers.';

  @override
  String get dashStudentArchived => 'Élève archivé avec succès';

  @override
  String get actionArchive => 'Archiver';

  @override
  String get dashAddPayment => 'Ajouter un paiement';

  @override
  String get dashNoStudentAddFirst =>
      'Aucun élève enregistré. Veuillez d\'abord ajouter des élèves.';

  @override
  String get dashRecordPayment => 'Enregistrer un paiement';

  @override
  String get dashSelectStudent => 'Sélectionner un élève';

  @override
  String dashAmountWithCurrency(Object currency) {
    return 'Montant ($currency)';
  }

  @override
  String get fieldMonth => 'Mois';

  @override
  String get paymentPaid => 'Payé';

  @override
  String get paymentUnpaid => 'Non payé';

  @override
  String get dashPaymentDay => 'Jour du paiement';

  @override
  String get dashInvalidAmount => 'Montant invalide';

  @override
  String dashPaymentRecorded(Object month) {
    return 'Paiement pour $month enregistré!';
  }

  @override
  String get dashPaymentAlreadyRecorded => 'Paiement déjà enregistré';

  @override
  String get dashConfirmAnyway => 'Confirmer quand même';

  @override
  String get dashMarkAttendance => 'Marquer présence';

  @override
  String get dashLessonField => 'Leçon/Cours';

  @override
  String get dashLessonHint => 'Ex: Coran, Hadith';

  @override
  String get dashSelectStudentAndStatus =>
      'Veuillez sélectionner un élève et un statut';

  @override
  String get dashNoLessonDefault => 'Absence de cours';

  @override
  String get dashAttendanceRecorded => 'Présence enregistrée avec succès!';

  @override
  String dashWeekRange(Object day, Object month, Object day2, Object month2) {
    return 'Semaine du $day/$month au $day2/$month2';
  }

  @override
  String get dashPresentPlural => 'Présents';

  @override
  String get dashAbsentPlural => 'Absents';

  @override
  String get dashLatePlural => 'Tardifs';

  @override
  String dashTotalSessionsWeek(Object weeklyAttendancesCount) {
    return 'Total sessions: $weeklyAttendancesCount';
  }

  @override
  String dashMonthLine(Object month, Object year) {
    return 'Mois: $month/$year';
  }

  @override
  String dashTotalSessionsMonth(Object monthlyAttendancesCount) {
    return 'Total sessions: $monthlyAttendancesCount';
  }

  @override
  String dashAttendanceRateLine(Object length) {
    return 'Taux de présence: $length%';
  }

  @override
  String get dashAttendanceAlreadyRecorded => 'Présence déjà enregistrée';

  @override
  String dashReplaceAttendanceBody(
      Object status, Object lesson, Object newStatus, Object newLesson) {
    return 'Cet élève a déjà une présence aujourd\'hui :\n• Statut : $status\n• Leçon : $lesson\n\nUne seule présence est conservée par élève et par jour. Voulez-vous la remplacer par « $newStatus — $newLesson » ?';
  }

  @override
  String get actionReplace => 'Remplacer';

  @override
  String get dashAttendanceReplaced => 'Présence remplacée';

  @override
  String get dashTotalPending => 'Total en attente';

  @override
  String get dashGrandTotal => 'Total général';

  @override
  String dashPaymentsNumber(Object paymentsCount) {
    return 'Nombre de paiements: $paymentsCount';
  }

  @override
  String dashActiveStudents(Object studentsCount) {
    return 'Élèves actifs: $studentsCount';
  }

  @override
  String get dashManagementMetrics => 'Métriques de gestion:';

  @override
  String get statAttendanceRateFull => 'Taux de présence';

  @override
  String get statPaymentRateFull => 'Taux de paiement';

  @override
  String get dashSummary => 'Résumé:';

  @override
  String dashSummaryStudents(Object totalStudents) {
    return '• Total élèves: $totalStudents';
  }

  @override
  String dashSummarySessions(Object totalAttendance) {
    return '• Sessions enregistrées: $totalAttendance';
  }

  @override
  String dashSummaryPayments(Object paymentsCount) {
    return '• Paiements enregistrés: $paymentsCount';
  }

  @override
  String dashSummaryPaid(Object paidCount) {
    return '• Paiements complétés: $paidCount';
  }

  @override
  String get commonNotAvailable => 'Non disponible';

  @override
  String get dashPaymentDetails => 'Détails du paiement';

  @override
  String get fieldStudent => 'Élève';

  @override
  String get paymentPending => 'En attente';

  @override
  String get dashPaymentDate => 'Date du paiement';

  @override
  String get dashPaymentId => 'ID Paiement';

  @override
  String get dashPaymentMarkedPaid => 'Paiement marqué comme payé';

  @override
  String get dashMarkAsPaid => 'Marquer comme payé';

  @override
  String get dashReceipt => 'Reçu';

  @override
  String get commonNotSpecified => 'Non spécifié';

  @override
  String get dashAttendanceDetails => 'Détails de la présence';

  @override
  String get fieldLesson => 'Leçon';

  @override
  String get fieldDate => 'Date';

  @override
  String get dashAttendanceId => 'ID Présence';

  @override
  String get dashEditAttendance => 'Modifier la présence';

  @override
  String get dashAttendanceCorrected => 'Présence corrigée';

  @override
  String get dashStudentProfile => 'Profil de l\'élève';

  @override
  String get fieldContact => 'Contact';

  @override
  String get dashPaidPayments => 'Paiements payés';

  @override
  String get dashStudentId => 'ID Élève';

  @override
  String get dashAttendanceByStudent => 'Taux de présence par élève';

  @override
  String dashThisWeekSessions(Object weekAttendancesCount) {
    return 'Cette semaine ($weekAttendancesCount sessions)';
  }

  @override
  String dashThisMonthSessions(Object monthAttendancesCount) {
    return 'Ce mois ($monthAttendancesCount sessions)';
  }

  @override
  String dashGroupsCount(Object classesCount) {
    return '$classesCount groupes';
  }

  @override
  String get dashNoGroup => 'Aucun groupe';

  @override
  String get dashCreateFirstGroup => 'Commencez par créer votre premier groupe';

  @override
  String get dashCreateGroup => 'Créer un groupe';

  @override
  String get groupFull => 'Complet';

  @override
  String get groupAlmostFull => 'Presque complet';

  @override
  String get groupAvailable => 'Disponible';

  @override
  String get dashAddStudentToGroup => 'Ajouter un élève';

  @override
  String get dashRemoveStudentFromGroup => 'Retirer un élève';

  @override
  String get dashEditGroup => 'Modifier le groupe';

  @override
  String get dashDeleteGroup => 'Supprimer le groupe';

  @override
  String get dashOccupancy => 'Occupation';

  @override
  String get dashReceiptTitle => 'Reçu de paiement';

  @override
  String get dashReceiptGenerated =>
      'Le reçu a été généré. Que voulez-vous en faire ?';

  @override
  String get actionLater => 'Plus tard';

  @override
  String get actionPreviewPrint => 'Aperçu / Imprimer';

  @override
  String get dashGeneratingReport => 'Génération du rapport...';

  @override
  String dashGenerationError(Object error) {
    return 'Erreur lors de la génération : $error';
  }

  @override
  String get dashReportGenerated => 'Rapport généré';

  @override
  String get dashReportWhatToDo => 'Que voulez-vous faire de ce rapport ?';

  @override
  String get dashLogoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get actionLogout => 'Déconnecter';

  @override
  String dashLogoutError(Object error) {
    return 'Erreur déconnexion: $error';
  }

  @override
  String get dashAddGroup => 'Ajouter un groupe';

  @override
  String get fieldGroupName => 'Nom du groupe';

  @override
  String get dashGroupNameHint => 'Ex: Groupe Nouroul Bayan';

  @override
  String get fieldGroupLevel => 'Niveau du groupe';

  @override
  String get dashGroupLevelHint => 'Ex: Djouzou Amma, Nouroul Bayan, etc.';

  @override
  String get fieldGroupDescription => 'Description du groupe';

  @override
  String get fieldTeacherName => 'Nom de l\'enseignant';

  @override
  String get dashTeacherHint => 'Ex: Cheikh Ibrahim';

  @override
  String get fieldMaxStudents => 'Nombre maximum d\'élèves';

  @override
  String get dashMaxStudentsHint => 'Ex: 30 (modifiable, jusqu\'à 500)';

  @override
  String get dashMaxStudentsHelp =>
      'Vous pouvez augmenter ce nombre à tout moment.';

  @override
  String get dashGroupAdded => 'Classe ajoutée avec succès!';

  @override
  String dashEditNamed(Object classModel) {
    return 'Modifier: $classModel';
  }

  @override
  String get dashGroupUpdated => 'Classe modifiée avec succès!';

  @override
  String dashDeleteNamed(Object classModel) {
    return 'Supprimer: $classModel';
  }

  @override
  String get dashDeleteGroupConfirm =>
      'Êtes-vous sûr de vouloir supprimer ce groupe ? Le groupe sera archivé et tous ses élèves en seront retirés.';

  @override
  String get dashGroupDeleted => 'Classe supprimée avec succès!';

  @override
  String get dashAllStudentsInGroup =>
      'Tous les élèves sont déjà dans ce groupe.';

  @override
  String dashAddStudentTo(Object groupModel) {
    return 'Ajouter un élève à $groupModel';
  }

  @override
  String get dashSelectStudentToAdd => 'Sélectionnez un élève à ajouter:';

  @override
  String get dashChooseStudent => 'Choisissez un élève';

  @override
  String get dashStudentAddedToGroup => 'Élève ajouté au groupe avec succès!';

  @override
  String get dashGroupEmpty => 'Ce groupe ne contient aucun élève.';

  @override
  String dashRemoveStudentFrom(Object groupModel) {
    return 'Retirer un élève de $groupModel';
  }

  @override
  String get dashSelectStudentToRemove => 'Sélectionnez un élève à retirer:';

  @override
  String get dashStudentRemovedFromGroup =>
      'Élève retiré du groupe avec succès!';

  @override
  String get actionRemove => 'Retirer';

  @override
  String get dashGenerateReport => 'Générer un rapport';

  @override
  String get dashChooseReportPeriod => 'Choisissez la période du rapport :';

  @override
  String get dashWeekly => 'Hebdomadaire';

  @override
  String get dashMonthly => 'Mensuel';

  @override
  String get forgotResetting => 'Réinitialisation...';

  @override
  String get forgotSending => 'Envoi...';

  @override
  String get commonActive => 'Actif';

  @override
  String get errClassNotFound => 'Classe non trouvée';

  @override
  String get errStudentNotFound => 'Élève non trouvé';

  @override
  String get errMarkazAccessDenied => 'Accès refusé à cette Markaz';

  @override
  String get errLessonRequired => 'Le nom de la leçon est obligatoire';

  @override
  String get errAttendanceNotFound => 'Présence non trouvée';

  @override
  String get errStudentAccessDenied => 'Accès refusé à cet élève';

  @override
  String get errNotAuthenticated => 'Utilisateur non authentifié';

  @override
  String get errEmailPasswordRequired => 'Email et mot de passe requis';

  @override
  String get errRequiredFieldsMissing =>
      'Tous les champs obligatoires doivent être remplis';

  @override
  String get errPasswordTooShort => 'Mot de passe trop court (6+ caractères)';

  @override
  String get errEmailRequired => 'Email requis';

  @override
  String get errAllFieldsRequired => 'Tous les champs sont obligatoires';

  @override
  String get errGroupNameRequired => 'Le nom de la classe est obligatoire';

  @override
  String get errGroupLevelRequired => 'Le niveau de la classe est obligatoire';

  @override
  String get errTeacherNameRequired =>
      'Le nom de l\'enseignant est obligatoire';

  @override
  String get errMaxStudentsRange =>
      'Le nombre maximum d\'élèves doit être entre 1 et 500';

  @override
  String get errGroupNameExists => 'Un groupe avec ce nom existe déjà';

  @override
  String get errGroupNotFound => 'Groupe non trouvé';

  @override
  String get errGroupAccessDenied => 'Accès refusé à ce groupe';

  @override
  String errCapacityBelowCount(Object currentStudentCount) {
    return 'Impossible de réduire le nombre de places en dessous du nombre actuel d\'élèves ($currentStudentCount)';
  }

  @override
  String get errGroupNotEmpty =>
      'Impossible de supprimer un groupe contenant des élèves';

  @override
  String errGroupFull(Object maxStudents) {
    return 'Le groupe est déjà plein ($maxStudents élèves)';
  }

  @override
  String get errStudentAlreadyInGroup => 'L\'élève est déjà dans ce groupe';

  @override
  String get errStudentNotInGroup => 'L\'élève n\'est pas dans ce groupe';

  @override
  String get errGuardianNameRequired => 'Le nom du tuteur est obligatoire';

  @override
  String get errGuardianPhoneRequired =>
      'Le téléphone du tuteur est obligatoire';

  @override
  String get errGuardianNotFound => 'Tuteur non trouvé';

  @override
  String get errGuardianAccessDenied => 'Accès refusé à ce tuteur';

  @override
  String get errAmountPositive => 'Le montant doit être supérieur à 0';

  @override
  String get errPaymentNotFound => 'Paiement non trouvé';

  @override
  String get errRecitationNotFound => 'Récitation non trouvée';

  @override
  String get errRecitationAccessDenied => 'Accès refusé à cette récitation';

  @override
  String get errStudentNameRequired => 'Le nom de l\'élève est obligatoire';

  @override
  String get errNameMinLength => 'Le nom doit contenir au moins 3 caractères';

  @override
  String get errMarkazRequired =>
      'Markaz ID obligatoire et pas d\'utilisateur connecté';

  @override
  String get errNameInvalid => 'Nom invalide (3+ caractères)';

  @override
  String get errServerTimeout =>
      'Le serveur ne répond pas. Vérifiez votre connexion.';

  @override
  String get errServerUnreachable =>
      'Impossible de joindre le serveur. Vérifiez votre connexion internet.';

  @override
  String get errServerCommunication =>
      'Erreur de communication avec le serveur.';

  @override
  String get activityActionPaymentRecorded => 'Paiement enregistré';

  @override
  String get activityActionPaymentStatusUpdated =>
      'Statut de paiement mis à jour';

  @override
  String get activityActionAttendanceRecorded => 'Présence enregistrée';

  @override
  String get activityActionAttendanceUpdated => 'Présence corrigée';

  @override
  String get activityActionAttendanceDeleted => 'Présence supprimée';

  @override
  String get activityActionClassCreated => 'Groupe créé';

  @override
  String get activityActionClassUpdated => 'Groupe modifié';

  @override
  String get activityActionClassDeleted => 'Groupe archivé';

  @override
  String get activityActionGuardianCreated => 'Parent ajouté';

  @override
  String get activityActionGuardianUpdated => 'Parent modifié';

  @override
  String get activityActionGuardianDeleted => 'Parent supprimé';

  @override
  String get activityActionStudentCreated => 'Élève ajouté';

  @override
  String get activityActionStudentUpdated => 'Élève modifié';

  @override
  String get activityActionStudentArchived => 'Élève archivé';

  @override
  String get activityActionUserRegistered =>
      'Inscription et création du Markaz';

  @override
  String get activityActionUserLoggedIn => 'Connexion';

  @override
  String get activityActionRecitationRecorded => 'Récitation enregistrée';

  @override
  String get activityActionRecitationUpdated => 'Récitation corrigée';

  @override
  String get activityActionRecitationDeleted => 'Récitation supprimée';

  @override
  String get activityActionMarkazUpdated => 'Fiche du Markaz mise à jour';

  @override
  String get activityActionSyncConflict => 'Conflit de synchronisation';

  @override
  String get groupReport => 'Rapport du groupe';

  @override
  String get groupReportChoose =>
      'Rapport de tout le groupe : choisissez la période.';

  @override
  String get groupReportWeekly => 'Cette semaine';

  @override
  String get groupReportMonthly => 'Ce mois-ci';

  @override
  String get fieldPaymentMode => 'Mode de paiement';

  @override
  String get paymentModeCash => 'Espèces';

  @override
  String get paymentModeOther => 'Autre (mobile money, virement…)';

  @override
  String get fieldObservationOptional => 'Observation (optionnel)';

  @override
  String get fieldObservation => 'Observation';

  @override
  String get groupScheduleHint => 'Ex : Lun, Mer, Ven — 16h-18h';

  @override
  String get studentSearchHint => 'Rechercher (nom ou téléphone)';

  @override
  String get studentFilterAllGroups => 'Tous les groupes';

  @override
  String get studentFilterNoGroup => 'Sans groupe';

  @override
  String get studentSearchNoResult =>
      'Aucun élève ne correspond à la recherche.';
}
