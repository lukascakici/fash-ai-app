class AppConstants {
  static const String STORAGE_DEVICE_OPEN_FIRST_TIME = 'device_first_open';
  static const String STORAGE_USER_PROFILE_KEY = 'user-profile-key';
  static const String STORAGE_USER_TOKEN_KEY = 'user-token-key';
  static const String STORAGE_HAS_SEEN_TRIAL_END_SCREEN = 'has_seen_trial_end_screen';

  // New key for preference screen status
  static const String PREFERENCE_SCREEN_KEY = 'preference_screen_completed';

  static const List<String> clothingStyles = [
    'Casual',
    'Sporty',
    'Vintage',
    'Streetwear',
    'Formal',
    'Bohemian',
    'Punk',
  ];

  // Product preferences
  static const List<Map<String, String>> products = [
    {"image": "assets/icons/jacket.png", "label": "Jacket"},
    {"image": "assets/icons/pant.png", "label": "Pants"},
    {"image": "assets/icons/mini_skirt.png", "label": "Mini Skirt"},
    {"image": "assets/icons/shoes.png", "label": "Shoes"},
    {"image": "assets/icons/jacket_1.png", "label": "Coat"},
    {"image": "assets/icons/kot.png", "label": "Pink Pants"},
  ];
}
