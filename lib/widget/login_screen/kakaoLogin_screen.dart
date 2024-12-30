import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:itdat/models/social_model.dart';

class KakaoLoginScreen extends StatelessWidget {
  final SocialsModel socialsModel = SocialsModel();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('kakao 로그인 시작');
      try {
        final String accessToken = await _getKakaoAccessToken();
        print('Kakao ID Token: $accessToken');

        final result = await socialsModel.kakaoLogin(accessToken);
        print('Kakao 로그인 결과: $result');

        if (result['success']) {
          if (result['data']['requiresRegistration']) {
            Navigator.pushNamed(
              context,
              '/register',
              arguments: {
                'provider': 'KAKAO',
                'providerId': result['data']['providerId'],
                'email': result['data']['email'],
              },
            );
          } else {
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kakao 로그인 실패: ${result['message']}')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kakao 로그인 실패: $e')),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Kakao 로그인 중...')),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<String> _getKakaoAccessToken() async {
    print('Kakao Access Token 가져오는 중...');
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        print('KakaoTalk 설치됨');
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        print('KakaoTalk 설치되지 않음, Kakao Account로 로그인');
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      return token.accessToken;
    } catch (e) {
      print('Kakao Access Token 오류: $e');
      throw Exception('Kakao Access Token 가져오기 오류: $e');
    }
  }
}
