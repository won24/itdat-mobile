import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PhoneVerificationService {
  final baseUrl = dotenv.env['BASE_URL'];

  // 인증번호 발송
  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/sms/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

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
        Uri.parse('$baseUrl/api/sms/verify'),
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
