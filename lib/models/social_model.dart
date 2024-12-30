import 'dart:convert';
import 'package:http/http.dart' as http;

class SocialsModel {
  final String baseUrl = 'http://10.0.2.2:8082'; // 김

  // Google 로그인
  Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final String googleUrl = '$baseUrl/api/oauth/google';
    print('Google API 호출 시작: $googleUrl');
    print('google 전송 데이터: $idToken');

    try {
      final response = await http.post(
        Uri.parse(googleUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'idToken': idToken}),
      );
      print('Google API 응답 상태 코드: ${response.statusCode}');
      print('Google API 응답 데이터: ${response.body}');

      final responseBody = jsonDecode(response.body);

      print("Google 응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'requiresRegistration': responseBody['requiresRegistration'] ?? false,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': 'Google 로그인 실패: ${response.body}',
        };
      }
    } catch (e) {
      print("Google 로그인 오류: $e");
      return {'success': false, 'message': 'Google 로그인 실패'};
    }
  }

  // Kakao 로그인
  Future<Map<String, dynamic>> kakaoLogin(String accessToken) async {
    final String kakaoUrl = '$baseUrl/api/oauth/kakao';
    print('Kakao API 호출 시작: $kakaoUrl');
    print('kakao 전송 데이터: $accessToken');

    try {
      final response = await http.post(
        Uri.parse(kakaoUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Kakao API 응답 상태 코드: ${response.statusCode}');
      print('Kakao API 응답 데이터: ${response.body}');

      final responseBody = jsonDecode(response.body);

      print("Kakao 응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'requiresRegistration': responseBody['requiresRegistration'] ?? false,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': 'Kakao 로그인 실패: ${response.body}',
        };
      }
    } catch (e) {
      print("Kakao 로그인 오류: $e");
      return {'success': false, 'message': 'Kakao 로그인 실패'};
    }
  }

  // Naver 로그인
  Future<Map<String, dynamic>> naverLogin(String accessToken) async {
    final String naverUrl = '$baseUrl/api/oauth/naver';
    print('Naver API 호출 시작: $naverUrl');
    print('naver 전송 데이터: $accessToken');

    try {
      final response = await http.post(
        Uri.parse(naverUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Naver API 응답 상태 코드: ${response.statusCode}');
      print('Naver API 응답 데이터: ${response.body}');

      final responseBody = jsonDecode(response.body);

      print("Naver 응답 데이터: ${response.body}");

      if (response.statusCode == 200) {
        return {
          'success': true,
          'requiresRegistration': responseBody['requiresRegistration'] ?? false,
          'data': responseBody,
        };
      } else {
        return {
          'success': false,
          'message': 'Naver 로그인 실패: ${response.body}',
        };
      }
    } catch (e) {
      print("Naver 로그인 오류: $e");
      return {'success': false, 'message': 'Naver 로그인 실패'};
    }
  }
}
