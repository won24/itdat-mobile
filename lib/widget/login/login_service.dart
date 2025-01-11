import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/login_model.dart';

class AuthService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final LoginModel _loginModel = LoginModel();

  Future<bool> login(String identifier, String password) async {
    print("서비스쪽: identifier = $identifier, password = $password");

    Map<String, String> requestBody = {
      'identifier': identifier, // identifier를 사용
      'password': password,
    };

    var result = await _loginModel.login(requestBody);

    if (result['success']) {
      try {
        var token = result['data']['token'];
        if (token != null) {
          await storage.write(key: 'auth_token', value: token);
          await storage.write(key: 'identifier', value: identifier); // identifier 저장
          print("토큰 및 identifier 저장 완료");
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

  Future<bool> logout() async {
    try {
      await storage.delete(key: 'auth_token');
      await storage.delete(key: 'identifier'); // identifier 삭제
      print("로그아웃 완료");
      return true;
    } catch (e) {
      print("로그아웃 중 에러 발생: $e");
      return false;
    }
  }
}
