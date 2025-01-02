import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class LoginModel extends ChangeNotifier{
  //final String baseUrl = 'http://112.221.66.174:8001'; // 원
   final String baseUrl = 'http://10.0.2.2:8082';     // 김
  // final String baseUrl = 'http://112.221.66.174:8000'; // son

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("모델" + email);
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Extract the token
      String? token = responseBody['token'];
      print(token);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': {'token': token},
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed. Please try again.',
        };
      }
    } catch (e) {
      print('Error during login: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again later.',
      };
    }
  }

  Future<bool> register(Map<String, dynamic> formData) async {
    final String registerUrl = '$baseUrl/api/auth/register';

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(formData),
      );

      print("응답 상태 코드: ${response.statusCode}");
      print("응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        print("회원가입 성공: ${response.body}");
        return true;
      } else {
        print("회원가입 실패: ${response.body}");
        return false;
      }
    } catch (error) {
      print('회원가입 오류: $error');
      return false;
    }
  }

  Future<bool> checkUserIdAvailability(String userId) async {
    final String url = '$baseUrl/api/auth/check-availability?type=userId&value=$userId';

    try {
      print("요청 URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("서버 응답: $responseBody");
        return responseBody['available'] ?? false;
      } else {
        print("서버 오류: 상태 코드 ${response.statusCode}");
        print("응답 데이터: ${response.body}");
        return false;
      }
    } catch (e) {
      print("네트워크 오류: $e");
      return false;
    }
  }

}
