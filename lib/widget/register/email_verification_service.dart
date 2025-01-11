import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailVerificationService {
  // test commit
  final String sendEmailUrl = "http://10.0.2.2:8082/api/email/send";
  final String verifyEmailUrl = "http://10.0.2.2:8082/api/email/verify";

  // 이메일 인증 코드 발송
  //test
  Future<bool> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse(sendEmailUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("서버 응답 상태 코드: ${response.statusCode}");
        print("서버 응답 메시지: ${response.body}");
        return false;
      }
    } catch (e) {
      print("이메일 발송 실패: $e");
      return false;
    }
  }

  // 이메일 인증 코드 검증
  //test
  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse(verifyEmailUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("이메일 인증 실패: $e");
      return false;
    }
  }
}
