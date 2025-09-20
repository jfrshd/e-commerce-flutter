class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String apiVersion = '/api/v1';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String signup = '$apiVersion/auth/signup';
  static const String resetPassword = '$apiVersion/auth/reset-password';
  static const String verifyEmail = '$apiVersion/auth/verify-email';
  static const String profile = '$apiVersion/auth/profile';
  static const String preferences = '$apiVersion/auth/preferences';
  static const String changePassword = '$apiVersion/auth/change-password';
  static const String requestEmailCode = '$apiVersion/auth/request-email-code';
  static const String verifyEmailCode = '$apiVersion/auth/verify-email-code';
  static const String requestResetCode = '$apiVersion/auth/request-reset-code';
  static const String verifyResetCode = '$apiVersion/auth/verify-reset-code';
  static const String deleteAccount = '$apiVersion/auth/account';

  // User endpoints
  static const String users = '$apiVersion/users';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
}
