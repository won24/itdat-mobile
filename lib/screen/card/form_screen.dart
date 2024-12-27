import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/preview_screen.dart';

class FormScreen extends StatefulWidget {
  final String templateUrl;
  final String userId;

  const FormScreen({
    super.key,
    required this.templateUrl,
    required this.userId
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {

  final CardModel cardModel = CardModel();
  Map<String, dynamic>? userData;
  XFile? logoImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final data = await cardModel.getUserById(widget.userId);
      setState(() {
        userData = data;
        print("유저 정보: $data");
      });
    } catch (e) {
      print("Error 유저 정보 가져오기: $e");
    }
  }

  Future<void> pickLogo() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        logoImage = pickedImage;
      });
    }
  }

  void navigateToPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewScreen(userData: userData!, logoPath: logoImage?.path, templateUrl: widget.templateUrl),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("명함 정보 확인")),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ...[
            'userName',
            'userPhone',
            'userEmail',
            'company',
            'companyPhone',
            'companyAddr',
            'companyFax',
            'companyRank',
            'companyDept'
          ].map((field) {
            return TextField(
              controller: TextEditingController(text: userData![field]),
              decoration: InputDecoration(labelText: field),
              onChanged: (value) {
                userData![field] = value;
              },
            );
          }).toList(),


          logoImage == null
              ? Text("선택된 로고 없음")
              : Image.file(File(logoImage!.path)),
          ElevatedButton( onPressed: pickLogo, child: Text("로고 선택"),),

          ElevatedButton(
            onPressed: navigateToPreview,
            child: Text("미리보기"),
          ),
        ],
      ),
    );
  }
}


