import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widget/login/login_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _isLoggedIn = false;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  Future<bool> checkLoginStatus() async {
    _isLoggedIn = false;
    _userEmail = null;

    String? token = await _storage.read(key: 'auth_token');
    String? storedIdentifier = await _storage.read(key: 'user_identifier');

    print("토큰 확인: $token");
    print("저장된 아이디 또는 이메일: $storedIdentifier");

    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = storedIdentifier;
    }

    notifyListeners();
    return _isLoggedIn;
  }


  Future<bool> login(String identifier, String password) async {
    await logout();
    print("프로바이더 로그인 정보 확인: identifier = $identifier, password = $password");

    bool success = await _authService.login(identifier, password);
    if (success) {
      await _storage.write(key: 'user_identifier', value: identifier);
      _userEmail = identifier;
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
      _userEmail = null;
    }
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_identifier');
      print("로그아웃: auth_token과 user_identifier 삭제 완료");
      _isLoggedIn = false;
      _userEmail = null;
      notifyListeners();
    } catch (e) {
      print("로그아웃 중 에러 발생: $e");
    }
  }
}
