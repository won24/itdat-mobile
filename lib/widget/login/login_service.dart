import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/login_model.dart';
import '../../utils/HttpClientManager.dart';

class AuthService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final LoginModel _loginModel = LoginModel();

  Future<bool> login(String identifier, String password) async {
    Map<String, String> requestBody = {
      'identifier': identifier,
      'password': password,
    };

    // 로그인 요청 실행
    var result = await _loginModel.login(requestBody);

    // 성공 처리
    if (result['success']) {
      try {
        // 데이터 추출
        String? token = result['data']['token'];
        String? userEmail = result['data']['userEmail'];
        String? userId = result['data']['userId']?.toString();

        // 데이터 검증 및 저장
        if (token != null && userEmail != null && userId != null) {
          await storage.write(key: 'auth_token', value: token);
          await storage.write(key: 'user_email', value: userEmail);
          await storage.write(key: 'user_id', value: userId);
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
      // 실패 처리
      if (result['message'] == '계정이 제재 상태입니다. 관리자에게 문의하세요.') {
        print("계정 제재 상태: ${result['message']}");
      } else {
        print("로그인 실패: ${result['message']}");
      }
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
