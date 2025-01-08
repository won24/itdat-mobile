import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class LoginModel extends ChangeNotifier{
  // final String baseUrl = 'http://112.221.66.174:8001'; // 원
    final String baseUrl = 'http://10.0.2.2:8082';     // 김
  //final String baseUrl = 'http://112.221.66.174:8000/api/auth'; // son


  Future<Map<String, dynamic>> login(Map<String,String> requestLogin) async {
    try {
      print("Request: $requestLogin");
      print("URL: $baseUrl/api/auth/login");
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(requestLogin),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          try {
            Map<String, dynamic> responseBody = jsonDecode(response.body);
            String? token = responseBody['token'];
            print("Token: $token");

            if (token != null) {
              return {
                'success': true,
                'data': {'token': token},
              };
            } else {
              return {
                'success': false,
                'message': 'Token not found in response.',
              };
            }
          } catch (e) {
            print('Error decoding JSON: $e');
            return {
              'success': false,
              'message': 'Invalid response format.',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Empty response from server.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Login failed. Status code: ${response.statusCode}',
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

  Future<bool> checkAvailability(String type, String value) async {
    final String url = '$baseUrl/api/auth/check-availability?type=$type&value=$value';

    try {
      // print("요청 URL: $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      // print("응답 상태 코드: ${response.statusCode}");
      // print("응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // print("중복 여부: ${responseBody['available']}");
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
