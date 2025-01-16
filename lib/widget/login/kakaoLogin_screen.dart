import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:itdat/models/social_model.dart';



import '../setting/waitwidget.dart';import '../setting/waitwidget.dart';

class KakaoLoginScreen extends StatelessWidget {
  final SocialsModel socialsModel = SocialsModel();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Kakao 로그인 시작');
      try {
        final String accessToken = await _getKakaoAccessToken();
        print('획득한 Access Token: $accessToken');

        final result = await socialsModel.kakaoLogin(accessToken);
        print('Kakao 로그인 결과: $result');

        if (result['success']) {
          if (result['data']['requiresRegistration']) {
            Future.microtask(() => Navigator.pushNamed(
              context,
              '/register',
              arguments: {
                'provider': 'KAKAO',
                'providerId': result['data']['providerId'],
                'email': result['data']['email'],
              },
            ));
          } else {
            Future.microtask(() =>
                Navigator.pushReplacementNamed(context, '/main'));
          }
        } else {
          _showSnackBar(context, 'Kakao 로그인 실패: ${result['message']}');
          Navigator.pop(context);
        }
      } catch (e) {
        _showSnackBar(context, 'Kakao 로그인 실패: $e');
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Kakao 로그인 중...')),
      body: Center(child: WaitAnimationWidget()),
    );
  }

  Future<String> _getKakaoAccessToken() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print('Kakao Access Token: ${token.accessToken}');
      return token.accessToken;
    } catch (e) {
      print('Kakao 로그인 오류: $e');
      throw Exception('Kakao 로그인 실패');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
