import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/login_model.dart';

class AuthService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final LoginModel _loginModel = LoginModel();

  // 로그인 메서드
  Future<bool> login(String email, String password) async {
    print("서비스쪽: email = $email, password = $password");

    Map<String, String> requestBody = {
      'email': email,
      'password': password,
    };

    var result = await _loginModel.login(requestBody);

    // 로그인 성공 시
    if (result['success']) {
      try {
        var token = result['data']['token'];
        if (token != null) {
          await storage.write(key: 'auth_token', value: token);
          await storage.write(key: 'email', value: email);
          print("토큰, 이메일 저장 완료");
          return true;
        } else {
          print("토큰이 없습니다.");
          return false;
        }
      } catch (e) {
        print("토큰 저장 중 에러 발생: $e");
        return false;
      }
    } else {
      print(result['message']);
      return false;
    }
  }

  // 로그아웃 메서드
  Future<bool> logout() async {
    try {
      // 토큰을 안전한 저장소에서 삭제
      await storage.delete(key: 'auth_token');
      print("로그아웃 완료");
      return true;
    } catch (e) {
      print("로그아웃 중 에러 발생: $e");
      return false;
    }
  }
}
