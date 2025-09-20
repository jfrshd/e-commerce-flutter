class AppConstants {
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String userDataKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';

  // API timeout
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
}
