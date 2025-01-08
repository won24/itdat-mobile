import 'package:flutter/material.dart';
import 'package:itdat/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  EditProfileScreen({Key? key, required this.userInfo}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserModel _userModel = UserModel();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _companyRankController;
  late TextEditingController _companyDeptController;
  late TextEditingController _companyFaxController;
  late TextEditingController _companyAddrController;
  late TextEditingController _companyAddrDetailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userInfo['userName']);
    _phoneController = TextEditingController(text: widget.userInfo['userPhone']);
    _companyController = TextEditingController(text: widget.userInfo['company'] ?? '');
    _companyRankController = TextEditingController(text: widget.userInfo['companyRank'] ?? '');
    _companyDeptController = TextEditingController(text: widget.userInfo['companyDept'] ?? '');
    _companyFaxController = TextEditingController(text: widget.userInfo['companyFax'] ?? '');
    _companyAddrController = TextEditingController(text: widget.userInfo['companyAddr'] ?? '');
    _companyAddrDetailController = TextEditingController(text: widget.userInfo['companyAddrDetail'] ?? '');
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> updateData = {
          'userName': _nameController.text,
          'userPhone': _phoneController.text,
          'company': _companyController.text,
          'companyRank': _companyRankController.text,
          'companyDept': _companyDeptController.text,
          'companyFax': _companyFaxController.text,
          'companyAddr': _companyAddrController.text,
          'companyAddrDetail': _companyAddrDetailController.text,
        };

        await _userModel.updateUserInfo(updateData);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('정보 업데이트 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: '전화번호'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '전화번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(labelText: '회사'),
              ),
              TextFormField(
                controller: _companyRankController,
                decoration: InputDecoration(labelText: '직급'),
              ),
              TextFormField(
                controller: _companyDeptController,
                decoration: InputDecoration(labelText: '부서'),
              ),
              TextFormField(
                controller: _companyFaxController,
                decoration: InputDecoration(labelText: '회사 팩스'),
              ),
              TextFormField(
                controller: _companyAddrController,
                decoration: InputDecoration(labelText: '회사 주소'),
              ),
              TextFormField(
                controller: _companyAddrDetailController,
                decoration: InputDecoration(labelText: '회사 상세주소'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _companyRankController.dispose();
    _companyDeptController.dispose();
    _companyFaxController.dispose();
    _companyAddrController.dispose();
    _companyAddrDetailController.dispose();
    super.dispose();
  }
}