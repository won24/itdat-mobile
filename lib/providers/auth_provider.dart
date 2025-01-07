import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widget/login_screen/login_service.dart';
import 'package:dio/dio.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  bool get isLoggedIn => _isLoggedIn;

  Future<bool> checkLoginStatus() async {
    String? token = await _storage.read(key: 'auth_token');
    print("토큰 확인: $token");

    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }
    notifyListeners();
    return _isLoggedIn;
  }

  Future<bool> login(String email, String password) async {
    print("프로바이더 로그인 정보 확인: email = $email, password = $password");

    // AuthService의 login 메서드 호출
    bool success = await _authService.login(email, password);
    _isLoggedIn = success;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    await _storage.delete(key: 'auth_token');
    _isLoggedIn = false;
    notifyListeners();
  }
}
