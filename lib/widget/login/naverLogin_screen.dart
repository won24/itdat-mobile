import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../models/social_model.dart';

class NaverLoginScreen extends StatefulWidget {
  @override
  _NaverLoginScreenState createState() => _NaverLoginScreenState();
}

class _NaverLoginScreenState extends State<NaverLoginScreen> {
  final SocialsModel socialsModel = SocialsModel();
  final MethodChannel _channel = const MethodChannel('redirect_uri_channel');

  @override
  void initState() {
    super.initState();

    // MethodChannel 핸들러 설정
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onLoginSuccess") {
        final String token = call.arguments as String;
        print("Flutter에서 받은 JWT Token: $token");

        Navigator.pushReplacementNamed(context, '/main');
      } else if (call.method == "onRegister") {
        final arguments = call.arguments as Map<String, dynamic>;
        final String providerId = arguments['providerId'];
        final String email = arguments['email'];
        print("Flutter에서 받은 ProviderId: $providerId, Email: $email");

        Navigator.pushReplacementNamed(context, '/register', arguments: {
          'providerId': providerId,
          'email': email,
          'providerType': 'NAVER',
        });
      } else {
        print("알 수 없는 메서드 호출: ${call.method}");
      }
    });


  }

  Future<void> _handleLogin(String code, String state) async {
    try {
      // 서버로 code와 state 전달
      await socialsModel.sendCodeAndState(code, state);

      // 백엔드에서 로그인 결과 가져오기
      final Map<String, dynamic> loginResult = await socialsModel.fetchBackendLoginResult();

      if (loginResult['success'] == true) {
        final String? jwtToken = loginResult['data']['token'];
        if (jwtToken != null) {
          print("JWT 토큰: $jwtToken");
          Navigator.pushReplacementNamed(context, '/main');
          print("Main 화면으로 이동 성공");
        } else {
          throw Exception('JWT 토큰이 없습니다.');
        }
      } else if (loginResult['requiresRegistration'] == true) {
        final Map<String, String> registrationData = {
          'providerId': loginResult['data']['providerId'],
          'email': loginResult['data']['email'],
          'providerType': 'NAVER',
        };
        Navigator.pushReplacementNamed(context, '/register', arguments: registrationData);
      } else {
        throw Exception('네이버 로그인 실패: ${loginResult['message']}');
      }
    } catch (e) {
      print('로그인 처리 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e')),
      );
    }
  }

  void _navigateToRegister(String providerId, String email) {
    final Map<String, String> registrationData = {
      'providerId': providerId,
      'email': email,
      'providerType': 'NAVER',
    };
    Navigator.pushReplacementNamed(context, '/register', arguments: registrationData);
  }

  Future<void> _startNaverLogin() async {
    try {
      print('Naver 로그인 시작');
      final String state = DateTime.now().millisecondsSinceEpoch.toString();
      final String authorizationUrl = socialsModel.getNaverAuthorizationUrl(
        'Kk0mlnghLzPAi0TpquZj', // 네이버 클라이언트 ID
        'http://10.0.2.2:8082/api/oauth/callback/naver', // 백엔드 콜백 URL
        state,
      );

      if (await canLaunch(authorizationUrl)) {
        await launch(authorizationUrl);
      } else {
        throw Exception('네이버 로그인 URL을 열 수 없습니다.');
      }
    } catch (e) {
      print('Naver 로그인 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Naver Login Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNaverLogin());

    return Scaffold(
      appBar: AppBar(title: const Text('Naver Logining...')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
