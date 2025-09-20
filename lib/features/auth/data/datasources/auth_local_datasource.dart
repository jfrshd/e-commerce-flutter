import 'package:injectable/injectable.dart';
import 'package:flutter_shop_app/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_shop_app/core/storage/token_storage.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(String userJson);
  Future<String?> getCachedUser();
  Future<void> clearCache();
  Future<void> cacheAuthResponse(AuthResponseModel authResponse);
  Future<void> clearAuthData();
  Future<String?> getToken();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final TokenStorage _tokenStorage;

  AuthLocalDataSourceImpl({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  @override
  Future<void> cacheUser(String userJson) async {
    print('💾 AuthLocalDataSource: Caching user data');
    // Implementation would cache user data locally
  }

  @override
  Future<String?> getCachedUser() async {
    print('💾 AuthLocalDataSource: Getting cached user data');
    // Implementation would retrieve cached user data
    return null;
  }

  @override
  Future<void> clearCache() async {
    print('💾 AuthLocalDataSource: Clearing cache');
    // Implementation would clear cached data
  }

  @override
  Future<void> cacheAuthResponse(AuthResponseModel authResponse) async {
    print('💾 AuthLocalDataSource: Caching auth response');
    print(
        '💾 AuthLocalDataSource: Token length: ${authResponse.accessToken.length}');
    print('💾 AuthLocalDataSource: User email: ${authResponse.user.email}');

    // Save the token
    await _tokenStorage.saveToken(authResponse.accessToken);

    // Save user data
    await _tokenStorage.saveUser(authResponse.user.toJson());

    print('💾 AuthLocalDataSource: Auth response cached successfully');
  }

  @override
  Future<void> clearAuthData() async {
    print('💾 AuthLocalDataSource: Clearing auth data');
    await _tokenStorage.clearToken();
    print('💾 AuthLocalDataSource: Auth data cleared successfully');
  }

  @override
  Future<String?> getToken() async {
    print('💾 AuthLocalDataSource: Getting token');
    final token = await _tokenStorage.getToken();
    print(
        '💾 AuthLocalDataSource: Token retrieved: ${token != null ? 'exists' : 'null'}');
    return token;
  }
}
