import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';


class NaverLoginScreen extends StatelessWidget {
  String? _currentState;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Naver 로그인 시작');
      try {
        // Authorization Code 획득
        final String authCode = await _getAuthorizationCode(context);
        print('Authorization Code: $authCode');

        // Authorization Code로 Access Token 요청
        final String accessToken = await _getAccessToken(authCode);
        print('Naver Access Token: $accessToken');

        // Access Token을 사용하여 API 요청 (예: 사용자 정보 가져오기)
        final userInfo = await _getUserInfo(accessToken);
        print('Naver 사용자 정보: $userInfo');

        if (userInfo != null) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Naver 로그인 실패')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Naver 로그인 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Naver 로그인 실패: $e')),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Naver 로그인 중...')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Future<String> _getAuthorizationCode(BuildContext context) async {
    const String clientId = 'Kk0mlnghLzPAi0TpquZj'; // 네이버 Client ID
    const String redirectUri = 'myapp://naver-login'; // Redirect URI

    final uuid = Uuid();
    _currentState = uuid.v4(); // 랜덤 State 값 생성

    final String authorizationUrl =
        'https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&state=$_currentState';

    if (await canLaunch(authorizationUrl)) {
      await launch(authorizationUrl);
    } else {
      throw Exception('브라우저를 열 수 없습니다.');
    }

    // Redirect URI 처리
    final MethodChannel channel = MethodChannel('redirect_uri_channel');
    try {
      final String? uriString = await channel.invokeMethod('onRedirectUriReceived');
      if (uriString == null) {
        throw Exception('Redirect URI를 받을 수 없습니다.');
      }

      final Uri uri = Uri.parse(uriString);
      final String? code = uri.queryParameters['code'];
      final String? returnedState = uri.queryParameters['state'];

      if (code == null || returnedState != _currentState) {
        throw Exception('인증 코드 또는 state가 일치하지 않습니다.');
      }

      return code;
    } catch (e) {
      throw Exception('Redirect URI 처리 중 오류 발생: $e');
    }
  }

  Future<String> _getAccessToken(String authCode) async {
    const String clientId = 'Kk0mlnghLzPAi0TpquZj';
    const String clientSecret = 'mwNpwGjHrR';
    const String redirectUri = 'myapp://naver-login';

    final String tokenUrl = 'https://nid.naver.com/oauth2.0/token';

    final response = await http.post(
      Uri.parse(tokenUrl),
      body: {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': authCode,
        'state': _currentState,
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['access_token'];
    } else {
      throw Exception('Access Token 요청 실패: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String accessToken) async {
    const String userInfoUrl = 'https://openapi.naver.com/v1/nid/me';

    final response = await http.get(
      Uri.parse(userInfoUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['response'];
    } else {
      throw Exception('사용자 정보 요청 실패: ${response.body}');
    }
  }
}
