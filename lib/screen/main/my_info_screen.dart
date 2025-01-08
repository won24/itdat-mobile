import 'package:flutter/material.dart';
import 'package:itdat/widget/setting/settingWidget.dart';
import 'package:itdat/models/user_model.dart';

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
                        '사용자 정보',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.edit, size: 24),
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
                            // 계정 삭제 로직을 여기에 구현
                             // _showDeleteAccountConfirmation();
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('기본프로필 수정'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'password',
                            child: Text('비밀번호 변경'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildInfoRow('이름', userInfo['userName']),
                  _buildInfoRow('전화번호', _formatPhoneNumber(userInfo['userPhone'])),
                  _buildInfoRow('이메일', userInfo['userEmail']),
                  // 필요한 다른 사용자 정보 필드를 여기에 추가
                ],
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value ?? '정보 없음'),
          ),
        ],
      ),
    );
  }
}
