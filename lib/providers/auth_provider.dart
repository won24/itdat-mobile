import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widget/login/login_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _isLoggedIn = false;
  String? _userEmail; // 로그인 시 사용한 아이디 또는 이메일 저장

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail; // 그대로 사용 가능 (아이디 또는 이메일 반환)

  Future<bool> checkLoginStatus() async {
    String? token = await _storage.read(key: 'auth_token');
    String? storedIdentifier = await _storage.read(key: 'user_identifier'); // 저장된 아이디 또는 이메일 가져오기
    print("토큰 확인: $token");
    print("저장된 아이디 또는 이메일: $storedIdentifier");

    if (token != null && token.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = storedIdentifier; // 아이디 또는 이메일 설정
    } else {
      _isLoggedIn = false;
      _userEmail = null; // 로그아웃 상태에서는 초기화
    }
    notifyListeners();
    return _isLoggedIn;
  }

  Future<bool> login(String identifier, String password) async {
    print("프로바이더 로그인 정보 확인: identifier = $identifier, password = $password");

    // AuthService의 login 메서드 호출
    bool success = await _authService.login(identifier, password);
    if (success) {
      await _storage.write(key: 'user_identifier', value: identifier); // 아이디 또는 이메일 저장
      _userEmail = identifier; // 아이디 또는 이메일 설정
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
      _userEmail = null;
    }
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_identifier'); // 아이디 또는 이메일 삭제
    _isLoggedIn = false;
    _userEmail = null; // 로그아웃 시 초기화
    notifyListeners();
  }
}
