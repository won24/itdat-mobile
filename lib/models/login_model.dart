import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itdat/models/http_client_model.dart';

class LoginModel extends ChangeNotifier{
  final baseUrl = dotenv.env['BASE_URL'];


  Future<Map<String, dynamic>> login(Map<String, String> requestLogin) async {
    final client = await HttpClientModel().createHttpClient();

    try {

      final response = await client.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestLogin),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");


      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          Map<String, dynamic> responseBody = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseBody,
          };
        } else {
          return {
            'success': false,
            'message': 'Empty response from server.',
          };
        }
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['message'] ??
              'Login failed. Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      print("네트워크 오류: $e");
      return {
        'success': false,
        'message': 'An error occurred. Please try again later.',
      };
    }
  }

  Future<bool> register(Map<String, dynamic> formData) async {
    final String registerUrl = '$baseUrl/api/auth/register';
    final client = await HttpClientModel().createHttpClient();

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
    final client = await HttpClientModel().createHttpClient();
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
