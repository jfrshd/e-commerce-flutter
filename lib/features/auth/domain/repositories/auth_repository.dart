import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    required bool acceptTerms,
  });
  Future<void> resetPassword(String code, String password);
  Future<void> verifyEmail(String token);
  Future<UserEntity> getProfile(String token);
  Future<UserEntity> updateProfile(String token, Map<String, dynamic> data);
  Future<UserEntity> updatePreferences(String token, Map<String, dynamic> data);
  Future<void> changePassword(
      String token, String currentPassword, String newPassword);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getCurrentUser();
  Future<void> requestEmailVerificationCode(String email);
  Future<void> verifyEmailCode(String email, String code);
  Future<void> requestPasswordResetCode(String email);
  Future<void> verifyPasswordResetCode(String email, String code);
  Future<void> deleteAccount(String token);
}
