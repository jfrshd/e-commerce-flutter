import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _authToken = _prefs?.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    _authToken = token;
    await _prefs?.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _authToken = null;
    await _prefs?.remove('auth_token');
  }

  String get _baseUrl => ApiConfig.baseUrl;

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'An error occurred');
    }
  }

  // Auth methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl${ApiConfig.loginEndpoint}'),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final data = await _handleResponse(response);
    
    if (data['access_token'] != null) {
      await _saveToken(data['access_token']);
    }
    
    return data;
  }

  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    required bool acceptTerms,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl${ApiConfig.signupEndpoint}'),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'acceptTerms': acceptTerms,
      }),
    );

    final data = await _handleResponse(response);
    
    if (data['access_token'] != null) {
      await _saveToken(data['access_token']);
    }
    
    return data;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl${ApiConfig.forgotPasswordEndpoint}'),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({'email': email}),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> resetPassword(String token, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl${ApiConfig.resetPasswordEndpoint}'),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({
        'token': token,
        'password': password,
      }),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl${ApiConfig.verifyEmailEndpoint}'),
      headers: ApiConfig.defaultHeaders,
      body: json.encode({'token': token}),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl${ApiConfig.profileEndpoint}'),
      headers: ApiConfig.getAuthHeaders(_authToken ?? ''),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl${ApiConfig.profileEndpoint}'),
      headers: ApiConfig.getAuthHeaders(_authToken ?? ''),
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'profileImage': profileImage,
      }),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> updatePreferences({
    String? language,
    bool? notificationsEnabled,
    String? location,
    String? theme,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl${ApiConfig.preferencesEndpoint}'),
      headers: ApiConfig.getAuthHeaders(_authToken ?? ''),
      body: json.encode({
        'language': language,
        'notificationsEnabled': notificationsEnabled,
        'location': location,
        'theme': theme,
      }),
    );

    return await _handleResponse(response);
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl${ApiConfig.changePasswordEndpoint}'),
      headers: ApiConfig.getAuthHeaders(_authToken ?? ''),
      body: json.encode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    return await _handleResponse(response);
  }

  Future<void> logout() async {
    await clearToken();
  }

  bool get isLoggedIn => _authToken != null;
  String? get authToken => _authToken;
}
