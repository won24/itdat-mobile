import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:itdat/models/social_model.dart';

class GoogleLoginScreen extends StatelessWidget {
  final SocialsModel socialsModel = SocialsModel();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Google 로그인 시작');
      try {
        final String idToken = await _getGoogleIdToken();
        print('Google ID Token: $idToken');

        final result = await socialsModel.googleLogin(idToken);
        print('Google 로그인 결과: $result');

        if (result['success']) {
          if (result['data']['requiresRegistration']) {
            Navigator.pushNamed(
              context,
              '/register',
              arguments: {
                'provider': 'GOOGLE',
                'providerId': result['data']['providerId'],
                'email': result['data']['email'],
              },
            );
          } else {
            Navigator.pushReplacementNamed(context, '/main');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google 로그인 실패: ${result['message']}')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google 로그인 실패: $e')),
        );
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text('Google 로그인 중...')),
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Future<String> _getGoogleIdToken() async {
    print('Google ID Token 가져오는 중...');
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email'],
    );

    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google 로그인 취소됨');
    }
    print('Google Account: $account');

    final GoogleSignInAuthentication auth = await account.authentication;
    print('Google ID Token: ${auth.idToken}');

    return auth.idToken!;
  }
}
