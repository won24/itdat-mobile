import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../models/social_model.dart';

class NaverLoginScreen extends StatelessWidget {
  final SocialsModel socialsModel = SocialsModel();
  final MethodChannel _channel = const MethodChannel('redirect_uri_channel');

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Naver 로그인 시작');
      try {
        // 1. 네이버 로그인 URL 생성 및 브라우저 실행
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

        // 2. Android에서 전달받은 code와 state 처리
        _channel.setMethodCallHandler((call) async {
          if (call.method == "onLoginSuccess") {
            final Map<dynamic, dynamic> arguments = call.arguments;
            final String code = arguments['code'];
            final String stateReceived = arguments['state'];

            print("Flutter에서 받은 Code: $code, State: $stateReceived");

            // 서버에 code와 state 전달
            await socialsModel.sendCodeAndState(code, stateReceived);

            // 3. 백엔드에서 로그인 결과 가져오기
            final Map<String, dynamic> loginResult =
            await socialsModel.fetchBackendLoginResult();

            if (loginResult['success'] == true) {
              final String? jwtToken = loginResult['data']['token'];

              if (jwtToken != null) {
                // 로그인 성공 처리
                print('네이버 로그인 성공: JWT 토큰: $jwtToken');
                Navigator.pushReplacementNamed(context, '/main');
              } else {
                throw Exception('JWT 토큰이 없습니다.');
              }
            } else if (loginResult['requiresRegistration'] == true) {
              // 회원가입 필요
              final Map<String, String> registrationData = {
                'providerId': loginResult['data']['providerId'],
                'email': loginResult['data']['email'],
                'providerType': 'NAVER',
              };
              Navigator.pushNamed(context, '/register', arguments: registrationData);
            } else {
              throw Exception('네이버 로그인 실패: ${loginResult['message']}');
            }
          }
        });
      } catch (e) {
        print('Naver 로그인 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Naver 로그인 실패: $e')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Naver 로그인 중...')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
