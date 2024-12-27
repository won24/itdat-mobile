import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itdat/providers/auth_provider.dart';

import '../../screen/mainLayout.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 원하는 비율로 크기 설정
    final containerWidth = screenWidth * 0.8; // 화면의 너비
    final containerHeight = screenHeight * 0.95; // 화면의 높이

    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라올 때 화면 크기 조정 방지
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
                Image.asset(
                  'assets/logoblack.png',
                  width: 80, // 로고의 너비 조정
                  height: 100, // 로고의 높이 조정
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 10), // 이메일 입력 필드와 비밀번호 입력 필드 사이 간격
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20), // 비밀번호 입력 필드와 버튼 사이 간격

                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text('Login'),
                    onPressed: () async {
                      print("버튼 눌림"); // 버튼이 눌렸는지 확인하기 위한 로그
                      final email = _emailController.text;
                      final password = _passwordController.text;

                      bool success = await Provider.of<AuthProvider>(context, listen: false).login(email, password);

                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainLayout()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed. Please try again.')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 10), // 구분 간격 추가
                Text(
                  "또는",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 10),
                // 소셜 로그인 버튼들
                Column(
                  children: [
                    // 네이버 로그인
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 네이버 로그인 로직 추가
                          print("네이버 로그인");
                        },
                        icon: Icon(Icons.account_circle),
                        label: Text('Naver'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // 네이버 색상
                        ),
                      ),
                    ),
                    SizedBox(height: 5), // 버튼 사이 간격
                    // 카카오 로그인
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 카카오 로그인 로직 추가
                          print("카카오 로그인");
                        },
                        icon: Icon(Icons.chat_bubble),
                        label: Text('Kakao'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow, // 카카오 색상
                          foregroundColor: Colors.black, // 텍스트 색상
                        ),
                      ),
                    ),
                    SizedBox(height: 5), // 버튼 사이 간격
                    // 구글 로그인
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 구글 로그인 로직 추가
                          print("구글 로그인");
                        },
                        icon: Icon(Icons.login),
                        label: Text('Google'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // 구글 색상
                        ),
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