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

        // 결과 처리
        if (userInfo != null) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Naver 로그인 실패')),
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
      appBar: AppBar(title: Text('Naver 로그인 중...')),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<String> _getAuthorizationCode(BuildContext context) async {
    const clientId = 'Kk0mlnghLzPAi0TpquZj'; // 네이버 개발자 센터에서 발급받은 Client ID
    const redirectUri = 'myapp://naver-login'; // 네이버 개발자 센터에서 등록한 Redirect URI

    // 랜덤한 state 값 생성 후 전역 변수에 저장
    final uuid = Uuid();
    _currentState = uuid.v4(); // 전역 변수에 저장

    final authorizationUrl =
        'https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&state=$_currentState';

    if (await canLaunch(authorizationUrl)) {
      await launch(authorizationUrl);
    } else {
      throw Exception('브라우저를 열 수 없습니다.');
    }

    // Redirect URI 처리
    final Completer<String> completer = Completer<String>();
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      resumeCallBack: () async {
        if (!completer.isCompleted) {
          try {
            final Uri redirectUriResult = await _getRedirectUri();
            final String? code = redirectUriResult.queryParameters['code'];
            final String? returnedState = redirectUriResult.queryParameters['state'];

            print('요청한 State: $_currentState');
            print('리다이렉트된 State: $returnedState');
            print('리다이렉트된 Code: $code');

            if (code == null || returnedState != _currentState) {
              print('State 또는 인증 코드가 올바르지 않음');
              completer.completeError('인증 코드 또는 state가 올바르지 않습니다.');
            } else {
              print('State와 인증 코드 검증 성공');
              completer.complete(code);
            }
          } catch (e) {
            completer.completeError('Redirect URI 처리 중 오류 발생: $e');
          }
        }
      },
    ));

    return completer.future;
  }

  Future<Uri> _getRedirectUri() async {
    const MethodChannel channel = MethodChannel('redirect_uri_channel');

    try {
      final String? uriString = await channel.invokeMethod('onRedirectUriReceived');
      if (uriString == null) {
        throw Exception('Redirect URI를 받을 수 없습니다.');
      }
      return Uri.parse(uriString);
    } catch (e) {
      throw Exception('Redirect URI 처리 중 오류 발생: $e');
    }
  }




  Future<String> _getAccessToken(String authCode) async {
    const clientId = 'Kk0mlnghLzPAi0TpquZj';
    const clientSecret = 'mwNpwGjHrR';
    const redirectUri = 'myapp://naver-login';

    final tokenUrl = 'https://nid.naver.com/oauth2.0/token';

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
      print('토큰 요청 실패: ${response.body}');
      throw Exception('토큰 요청 실패');
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String accessToken) async {
    final userInfoUrl = 'https://openapi.naver.com/v1/nid/me';

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
      print('사용자 정보 요청 실패: ${response.body}');
      return null;
    }
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallBack;

  LifecycleEventHandler({this.resumeCallBack});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && resumeCallBack != null) {
      resumeCallBack!();
    }
  }
}