import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<void> saveToken(String token) async {
    print('💾 TokenStorage: Saving token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('💾 TokenStorage: Token saved successfully');
  }

  Future<String?> getToken() async {
    print('💾 TokenStorage: Getting token');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print(
        '💾 TokenStorage: Token retrieved: ${token != null ? 'exists' : 'null'}');
    if (token != null) {
      print('💾 TokenStorage: Token length: ${token.length}');
      print(
          '💾 TokenStorage: Token (first 50 chars): ${token.substring(0, 50)}...');
    }
    return token;
  }

  Future<void> clearToken() async {
    print('💾 TokenStorage: Clearing token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    print('💾 TokenStorage: Token cleared successfully');
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    print('💾 TokenStorage: Saving user data');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.toString());
    print('💾 TokenStorage: User data saved successfully');
  }

  Future<Map<String, dynamic>?> getUser() async {
    print('💾 TokenStorage: Getting user data');
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    print(
        '💾 TokenStorage: User data retrieved: ${userString != null ? 'exists' : 'null'}');
    return userString != null
        ? {'email': userString}
        : null; // Simplified for now
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
