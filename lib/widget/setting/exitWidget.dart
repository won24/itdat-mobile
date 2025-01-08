import 'package:flutter/material.dart';
import 'package:itdat/models/user_model.dart';
import 'package:itdat/widget/login_screen/login_screen.dart';

class AccountDeletionScreen extends StatefulWidget {
  final String userEmail;

  AccountDeletionScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _AccountDeletionScreenState createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserModel _userModel = UserModel();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _deleteAccount() async {
    if (_formKey.currentState!.validate()) {
      // 비밀번호 확인
      bool isPasswordValid = await _userModel.verifyPassword(_passwordController.text, widget.userEmail);
      
      if (isPasswordValid) {
        // 사용자에게 최종 확인
        bool? confirmDeletion = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('회원 탈퇴 확인'),
              content: Text('정말로 회원 탈퇴를 진행하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
              actions: <Widget>[
                TextButton(
                  child: Text('취소'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('확인'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        );

        if (confirmDeletion == true) {
          try {
            bool success = await _userModel.deleteAccount(widget.userEmail);
            if (success) {
              // 탈퇴 성공
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
              );
              // 로그인 화면으로 이동
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            } else {
              // 탈퇴 실패
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('회원 탈퇴에 실패했습니다. 다시 시도해 주세요.')),
              );
            }
          } catch (e) {
            // 오류 발생
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
            );
          }
        }
      } else {
        // 비밀번호 불일치
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 탈퇴'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '회원 탈퇴를 진행하려면 비밀번호를 입력해주세요.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteAccount,
                child: Text('회원 탈퇴')
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}