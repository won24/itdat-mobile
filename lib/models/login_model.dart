import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginModel {
  final String baseUrl = 'http://112.221.66.174:8001'; // 원

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("모델"+email);
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
}