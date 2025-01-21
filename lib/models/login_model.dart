import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itdat/utils/HttpClientManager.dart';


class LoginModel extends ChangeNotifier{
  final baseUrl = dotenv.env['BASE_URL'];

  Future<Map<String, dynamic>> login(Map<String, String> requestLogin) async {
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestLogin),
      );

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          return {'success': true, 'data': jsonDecode(response.body)};
        } else {
          return {'success': false, 'message': '서버에서 빈 응답을 받았습니다.'};
        }
      } else if (response.statusCode == 403) {
        return {'success': false, 'message': '계정이 제재 상태입니다. 관리자에게 문의하세요.'};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ?? '로그인 실패'
        };
      }
    } catch (e) {
      print("네트워크 오류 발생: $e");
      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }


  Future<bool> register(Map<String, dynamic> formData) async {
    final String registerUrl = '$baseUrl/api/auth/register';
    final client = await HttpClientManager().createHttpClient();

    try {
      final response = await client.post(
        Uri.parse(registerUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(formData),
      );

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

  Future<bool> checkAvailability(String type, String value) async {
    final String url = '$baseUrl/api/auth/check-availability?type=$type&value=$value';
    final client = await HttpClientManager().createHttpClient();
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody['available'] ?? false;
      } else {
        print("서버 오류: 상태 코드 ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("네트워크 오류: $e");
      return false;
    }
  }


}
