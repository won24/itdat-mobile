import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widget/login_screen/login_service.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final Dio _dio = Dio();

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> checkLoginStatus() async {
    String? token = await _storage.read(key: 'auth_token');
    print("토큰확인: $token");

    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    return _isLoggedIn;
  }

  Future<bool> login(String email, String password) async {
    print("프로바이더 로그인 정보확인: email = $email, password = $password");
    bool success = await _authService.login(email, password);
    _isLoggedIn = success;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
