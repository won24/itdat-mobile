import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/login_model.dart';
import '../../utils/HttpClientManager.dart';

class AuthService {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final LoginModel _loginModel = LoginModel();

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    Map<String, String> requestBody = {
      'identifier': identifier,
      'password': password,
    };

    // 로그인 요청 실행
    var result = await _loginModel.login(requestBody);

    if (result['success'] == true) {
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
          return {'success': true};
        } else {
          return {'success': false, 'message': '응답 데이터가 불완전합니다.'};
        }
      } catch (e) {
        return {'success': false, 'message': '로그인 데이터 저장 중 오류 발생: $e'};
      }
    } else {
      // 실패 처리
      return {
        'success': false,
        'message': result['message'] ?? '로그인 실패',
      };
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
