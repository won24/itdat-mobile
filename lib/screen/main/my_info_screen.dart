import 'package:flutter/material.dart';
import 'package:itdat/widget/setting/exitWidget.dart';
import 'package:itdat/widget/setting/passwordChange.dart';
import 'package:itdat/widget/setting/settingWidget.dart';
import 'package:itdat/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widget/setting/editProfileWidget.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final UserModel _userModel = UserModel();
  Map<String, dynamic> userInfo = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final info = await _userModel.getUserInfo();
      print(info);
      setState(() {
        userInfo = info;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading user info: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  String _formatPhoneNumber(String? phone) {
    if (phone == null || phone.length != 11) return phone ?? '정보 없음';
    return '${phone.substring(0, 3)}-${phone.substring(3, 7)}-${phone.substring(7)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.userinfo,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.edit,
                            size: 24,
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                          onSelected: (String result) async {
                            switch (result) {
                              case 'edit':
                                final editResult = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditProfileScreen(userInfo: userInfo)),
                                );
                                if (editResult == true) {
                                  _loadUserInfo(); // 프로필이 수정되었을 때만 정보를 다시 로드
                                }
                                break;
                              case 'password':
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PasswordChangeScreen(userEmail: userInfo['userEmail'])),
                                );
                                break;
                              case 'exit':
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AccountDeletionScreen(userEmail: userInfo['userEmail'])),
                                );
                                break;
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Text(
                                AppLocalizations.of(context)!.profilemodify,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'password',
                              child: Text(
                                AppLocalizations.of(context)!.passwordChange,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'exit',
                              child: Text(
                                AppLocalizations.of(context)!.userdelete,
                                style: TextStyle(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildInfoRow(AppLocalizations.of(context)!.name, userInfo['userName']),
                    _buildInfoRow(AppLocalizations.of(context)!.phone, _formatPhoneNumber(userInfo['userPhone'])),
                    _buildInfoRow(AppLocalizations.of(context)!.email, userInfo['userEmail']),
                    // 필요한 다른 사용자 정보 필드를 여기에 추가
                  ]
              ),
            ),
            Divider(
              height: 1,
              color: Colors.grey[300],
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Settings(), // Settings 위젯의 구조 확인 필요
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? AppLocalizations.of(context)!.notfound,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}