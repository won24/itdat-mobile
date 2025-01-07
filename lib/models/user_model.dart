import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserModel {
  final storage = FlutterSecureStorage();
  final String baseUrl = "http://112.221.66.174:8000";

  Future<Map<String, dynamic>> getUserInfo() async {
    String? email = await storage.read(key: 'email');
    print('email: $email');
    if (email == null) {
      throw Exception('email not found');
    }

    final response = await http.post(
        Uri.parse('$baseUrl/nfc/userinfo'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email})
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<bool> updateUserInfo(Map<String, dynamic> map) async {
    String? email = await storage.read(key: 'email');
    if (email == null) {
      throw Exception('email not found');
    }
    map['email'] = email;
    print('Sending request to: $baseUrl/nfc/updateuser');
    print('Request body: ${jsonEncode(map)}');

    final response = await http.post(
        Uri.parse('$baseUrl/nfc/updateuser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(map)
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update user info');
    }
  }
}