import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/login_model.dart';
import '../../utils/HttpClientManager.dart';

class AuthService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final LoginModel _loginModel = LoginModel(HttpClientManager());

  Future<bool> login(String identifier, String password) async {
    // print("서비스쪽: identifier = $identifier, password = $password");

    Map<String, String> requestBody = {
      'identifier': identifier,
      'password': password,
    };

    var result = await _loginModel.login(requestBody);

    if (result['success']) {
      try {
        var token = result['data']['token'];
        var userEmail = result['data']['userEmail']; // 이메일
        var userId = result['data']['userId'].toString(); // ID를 문자열로 변환

        if (token != null && userEmail != null && userId != null) {
          await storage.write(key: 'auth_token', value: token);
          await storage.write(key: 'user_email', value: userEmail); // 이메일 저장
          await storage.write(key: 'user_id', value: userId); // ID 저장
          // print("토큰, 이메일, 아이디 저장 완료");
          return true;
        } else {
          print("응답 데이터에 필요한 정보가 없습니다.");
          return false;
        }
      } catch (e) {
        print("로그인 데이터 저장 중 오류 발생: $e");
        return false;
      }
    } else {
      print("로그인 실패: ${result['message']}");
      return false;
    }
  }



  Future<bool> logout() async {
    try {
      await storage.delete(key: 'auth_token');
      await storage.delete(key: 'identifier'); // identifier 삭제
      // print("로그아웃 완료");
      return true;
    } catch (e) {
      print("로그아웃 중 에러 발생: $e");
      return false;
    }
  }
}
