import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itdat/providers/auth_provider.dart';
import 'package:itdat/widget/register/register_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
                  'assets/logo_white.png',
                  width: 80,
                  height: 100,
                )
                    : Image.asset(
                  'assets/logo_black.png',
                  width: 80,
                  height: 100,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: '아이디 또는 이메일',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.email),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(202, 202, 202, 1.0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(0, 202, 145, 1), width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: Icon(Icons.lock),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(202, 202, 202, 1.0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(0, 202, 145, 1), width: 2),
                    ),
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
                            SnackBar(
                              content: Text(
                                Provider.of<AuthProvider>(context, listen: false).errorMessage ?? "로그인 실패",
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.login),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color.fromRGBO(0, 202, 145, 1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                        foregroundColor : Colors.black87
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
                    child: Text(AppLocalizations.of(context)!.register,),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color:Color.fromRGBO(0, 202, 145, 1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                        foregroundColor : Colors.black87
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Text(
                  AppLocalizations.of(context)!.or,
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
