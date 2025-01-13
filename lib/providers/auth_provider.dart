import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widget/login/login_service.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userId => _userId;

  Future<bool> checkLoginStatus() async {
    _isLoggedIn = false;
    _userEmail = null;
    _userId = null;

    String? token = await _storage.read(key: 'auth_token');
    String? email = await _storage.read(key: 'user_email');
    String? id = await _storage.read(key: 'user_id');

    print("토큰 확인: $token");
    print("저장된 이메일: $email");
    print("저장된 ID: $id");

    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = email;
      _userId = id;
    }

    notifyListeners();
    return _isLoggedIn;
  }

  Future<bool> login(String identifier, String password) async {
    bool success = await AuthService().login(identifier, password);
    if (success) {
      await checkLoginStatus(); // 로그인 후 상태 확인
    }
    return success;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_email');
    await _storage.delete(key: 'user_id');
    print("로그아웃: 토큰, 이메일, ID 삭제 완료");
    _isLoggedIn = false;
    _userEmail = null;
    _userId = null;
    notifyListeners();
  }
}
