/// Constantes textuelles de l'application Markazi
class AppStrings {
  AppStrings._();

  static const String appName = 'Markazi';
  static const String slogan = 'Gérez votre markaz\nsimplement et efficacement';
  static const String sloganShort = 'La solution digitale pour vos markaz';

  // Onboarding
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Gérez vos élèves facilement',
      'description': 'Ajoutez vos élèves et leurs informations complètes en quelques secondes. Retrouvez-les facilement à tout moment.',
      'icon': 'people',
    },
    {
      'title': 'Suivez les paiements',
      'description': 'Enregistrez les paiements et générez automatiquement des reçus. Plus de confusion dans vos finances.',
      'icon': 'payments',
    },
    {
      'title': 'Suivi journalier des cours',
      'description': 'Notez chaque jour la progression des élèves et leur récitation. Un suivi précis et complet.',
      'icon': 'menu_book',
    },
    {
      'title': 'Rapports automatiques',
      'description': 'Obtenez des statistiques hebdomadaires et mensuelles exportables en PDF. Partagez avec les parents facilement.',
      'icon': 'bar_chart',
    },
  ];

  // Fonctionnalités
  static const List<Map<String, String>> features = [
    {
      'title': 'Gestion des élèves',
      'description': 'Fiche complète par élève : informations personnelles, parents, niveau, historique.',
      'icon': 'school',
    },
    {
      'title': 'Paiements & Reçus',
      'description': 'Suivi des paiements mensuels avec génération automatique de reçus PDF.',
      'icon': 'receipt_long',
    },
    {
      'title': 'Présence & Récitation',
      'description': 'Pointage quotidien et évaluation de la récitation de chaque élève.',
      'icon': 'fact_check',
    },
    {
      'title': 'Statistiques hebdomadaires',
      'description': 'Tableau de bord avec statistiques claires sur la progression de la classe.',
      'icon': 'insights',
    },
    {
      'title': 'Rapport mensuel PDF',
      'description': 'Générez et envoyez des rapports mensuels complets aux parents.',
      'icon': 'picture_as_pdf',
    },
    {
      'title': 'Gestion des absences',
      'description': 'Suivi du taux d\'assiduité et notifications automatiques aux parents.',
      'icon': 'event_busy',
    },
  ];

  // Avantages
  static const List<Map<String, String>> advantages = [
    {
      'title': 'Gain de temps',
      'description': 'Réduisez le temps administratif de 80%. Concentrez-vous sur l\'enseignement.',
      'icon': 'schedule',
    },
    {
      'title': 'Mieux organisé',
      'description': 'Toutes vos données centralisées, accessibles partout, à tout moment.',
      'icon': 'folder_special',
    },
    {
      'title': 'Communication parents',
      'description': 'Envoyez des rapports et notifications directement aux familles.',
      'icon': 'family_restroom',
    },
  ];
}
