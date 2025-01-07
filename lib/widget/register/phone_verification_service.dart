import 'dart:convert';
import 'package:http/http.dart' as http;

class PhoneVerificationService {
  final String sendSmsUrl = "http://10.0.2.2:8082/api/sms/send";
  final String verifySmsUrl = "http://10.0.2.2:8082/api/sms/verify";

  // 인증번호 발송
  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      print("SMS API 호출 시작: $sendSmsUrl"); // 디버깅 출력
      print("요청 데이터: $phoneNumber");

      final response = await http.post(
        Uri.parse(sendSmsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      print("응답 상태 코드: ${response.statusCode}");
      print("응답 바디: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("SMS 발송 실패: $e"); // 에러 로그 출력
      return false;
    }
  }


  // 인증번호 검증
  Future<bool> verifyCode(String phoneNumber, String code) async {
    try {
      final response = await http.post(
        Uri.parse(verifySmsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'code': code}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("SMS 인증 실패: $e");
      return false;
    }
  }
}
