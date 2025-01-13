import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itdat/providers/auth_provider.dart';
import 'package:itdat/widget/register/register_screen.dart';

import '../../screen/mainLayout.dart';
import 'googleLogin_sacreen.dart';
import 'kakaoLogin_screen.dart';
import 'naverLogin_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController(); // identifier (아이디 또는 이메일)
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final containerWidth = screenWidth * 0.8;
    final containerHeight = screenHeight * 0.95;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: containerWidth,
            height: containerHeight,
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Theme.of(context).brightness == Brightness.dark
                    ? Image.asset(
                  'assets/logowhite.png',
                  width: 80,
                  height: 100,
                )
                    : Image.asset(
                  'assets/logoblack.png',
                  width: 80,
                  height: 100,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: '아이디 또는 이메일',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final identifier = _identifierController.text.trim();
                      final password = _passwordController.text;
                      bool success = await Provider.of<AuthProvider>(context, listen: false).login(identifier, password);

                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainLayout()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('존재하지 않는 사용자입니다.')),
                        );
                      }
                    },
                    child: Text('로그인'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text('회원가입'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Text(
                  "또는",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NaverLoginScreen()),
                        );
                      },
                      child: Image.asset(
                        'assets/icons/btnG.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => KakaoLoginScreen()),
                        );
                      },
                      child: Image.asset(
                        'assets/icons/kakaologin.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GoogleLoginScreen()),
                        );
                      },
                      child: Image.asset(
                        'assets/icons/android_light_rd_na@4x.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
