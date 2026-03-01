
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/constants.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Check token on app startup
  Future<void> checkLoginStatus() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/v1/auth/login', data: {
        "email": email,
        "password": password
      });

      final token = response.data['access_token'];
      await _storage.write(key: 'jwt_token', value: token);
      
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      throw Exception("Login Failed: Please check your credentials.");
    }
  }

  Future<void> signup(String email, String password, String name) async {
    try {
      await _dio.post('/api/v1/auth/signup', data: {
        "email": email,
        "password": password,
        "full_name": name
      });
      // Auto login after signup
      await login(email, password);
    } catch (e) {
      throw Exception("Signup Failed: Email might be taken.");
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}