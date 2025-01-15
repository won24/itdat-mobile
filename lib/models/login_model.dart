import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/io_client.dart';

class LoginModel extends ChangeNotifier{
  final baseUrl = dotenv.env['BASE_URL'];
  IOClient? _httpClient;
  Future<IOClient> createHttpClient() async {
    if (_httpClient != null) return _httpClient!; // 이미 HttpClient 객체가 생성된 경우 재사용

    // 인증서 파일 로드 (res/raw/ca_bundle.crt)
    final ByteData data = await rootBundle.load('res/raw/ca_bundle.crt');
    final List<int> bytes = data.buffer.asUint8List();

    // 인증서 파일을 SecurityContext에 추가
    final SecurityContext context = SecurityContext(withTrustedRoots: false);
    context.setTrustedCertificatesBytes(bytes);

    // dart:io HttpClient 생성 및 인증서 적용
    final HttpClient httpClient = HttpClient(context: context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    // IOClient 생성
    _httpClient = IOClient(httpClient);

    return _httpClient!;
  }


  Future<Map<String, dynamic>> login(Map<String, String> requestLogin) async {
    final client = await createHttpClient();
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
