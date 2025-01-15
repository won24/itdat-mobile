import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/io_client.dart';

import '../utils/HttpClientManager.dart';

class LoginModel extends ChangeNotifier{
  final baseUrl = dotenv.env['BASE_URL'];
  final HttpClientManager _httpClientManager;

  LoginModel(this._httpClientManager);

  Future<Map<String, dynamic>> login(Map<String, String> requestLogin) async {
    final IOClient client = await _httpClientManager.createHttpClient();
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

    try {
      final response = await http.post(
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

    try {
      final response = await http.get(
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
