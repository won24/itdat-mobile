import 'package:flutter/material.dart';
import 'package:itdat/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../login/login_screen.dart';

class PasswordChangeScreen extends StatefulWidget {
  final String userEmail;

  PasswordChangeScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserModel _userModel = UserModel();

  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  bool _isPasswordVerified = false;
  bool _passwordsMatch = false;
  bool _newPasswordValid = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _newPasswordController.addListener(_checkPasswordsMatch);
    _confirmPasswordController.addListener(_checkPasswordsMatch);
  }

  void _checkPasswordsMatch() {
    setState(() {
      _passwordsMatch = _newPasswordController.text.isNotEmpty &&
          _newPasswordController.text == _confirmPasswordController.text;
      _newPasswordValid = _newPasswordController.text.isNotEmpty;
    });
  }

  Future<void> _verifyPassword() async {
    bool isValid = await _userModel.verifyPassword(_currentPasswordController.text, widget.userEmail);
    setState(() {
      _isPasswordVerified = isValid;
    });
    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('현재 비밀번호가 확인되었습니다.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('현재 비밀번호가 일치하지 않습니다.')),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate() && _isPasswordVerified && _passwordsMatch) {
      try {
        bool success = await _userModel.changePassword(_confirmPasswordController.text);
        if (success) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('비밀번호 변경 성공'),
                content: Text('비밀번호가 성공적으로 변경되었습니다. 다시 로그인해주세요.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // 서버에서 실패 응답을 받은 경우
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('비밀번호 변경에 실패했습니다. 다시 시도해 주세요.')),
          );
        }
      } catch (e) {
        // 예외가 발생한 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.passwordChange),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _currentPasswordController,
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: l10n.currentPassword,
                      labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureCurrentPassword = !_obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureCurrentPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterCurrentPassword;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _verifyPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: BorderSide(
                        color: Color.fromRGBO(0, 202, 145, 1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Color.fromRGBO(0, 202, 145, 1);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return Color.fromRGBO(0, 202, 145, 1);
                        }
                        return Colors.white;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.white;
                        }
                        return Colors.black87;
                      }),
                    ),
                    child: Text(l10n.verifyCurrentPassword),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _newPasswordController,
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: l10n.newPassword,
                      labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureNewPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.enterNewPassword;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _checkPasswordsMatch();
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: l10n.confirmNewPassword,
                      labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _passwordsMatch && _confirmPasswordController.text.isNotEmpty
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : SizedBox.shrink(),
                          IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.reenterNewPassword;
                      }
                      if (value != _newPasswordController.text) {
                        return l10n.newpasswordMismatch;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _checkPasswordsMatch();
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isPasswordVerified && _passwordsMatch ? _changePassword : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: Text(l10n.changePassword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}