import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';


class FormScreen extends StatefulWidget {
  final String userId;

  const FormScreen({
    super.key,
    required this.userId,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {

  final CardModel cardModel = CardModel();
  Map<String, dynamic>? userData;
  late BusinessCard _card;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _card = BusinessCard(
        userName: "",
        phone: "",
        email: "",
        companyName: "",
        companyNumber: "",
        companyAddress: "",
        companyFax: "",
        department: "",
        position: ""
    );
  }

  Future<dynamic> fetchUserData() async {
    try {
      final data = await cardModel.getUserById(widget.userId);
      setState(() {
        userData = data;
      });
    } catch (e) {
      print("Error 유저 정보 가져오기: $e");
    }
  }

  void _saveCard() async {
    try {
      await cardModel.createBusinessCard(widget.userId, _card);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("새로운 명함이 생성되었습니다.")));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("명함 생성에 실패했습니다. 다시 시도해주세요.")));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("명함 만들기")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: userData!['userName'],
              decoration: InputDecoration(labelText: "이름"),
              onChanged: (value) => _card.userName = value,
            ),
            TextFormField(
              initialValue: userData!['phone'],
              decoration: InputDecoration(labelText: "연락처"),
              onChanged: (value) => _card.phone = value,
            ),
            TextFormField(
              initialValue: userData!['userEmail'],
              decoration: InputDecoration(labelText: "이메일"),
              onChanged: (value) => _card.email = value,
            ),
            TextFormField(
              initialValue: userData!['company'],
              decoration: InputDecoration(labelText: "회사 이름"),
              onChanged: (value) => _card.companyName = value,
            ),
            TextFormField(
              initialValue: userData!['companyPhone'],
              decoration: InputDecoration(labelText: "회사 연락처"),
              onChanged: (value) => _card.companyNumber = value,
            ),
            TextFormField(
              initialValue: userData!['companyAddr'] +
                  userData!['companyAddrDetail'],
              decoration: InputDecoration(labelText: "회사 주소"),
              onChanged: (value) => _card.companyAddress = value,
            ),
            TextFormField(
              initialValue: userData!['companyFax'],
              decoration: InputDecoration(labelText: "팩스번호"),
              onChanged: (value) => _card.companyFax = value,
            ),
            TextFormField(
              initialValue: userData!['companyDept'],
              decoration: InputDecoration(labelText: "부서"),
              onChanged: (value) => _card.department = value,
            ),
            TextFormField(
              initialValue: userData!['companyRank'],
              decoration: InputDecoration(labelText: "직책"),
              onChanged: (value) => _card.position = value,
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveCard,
              child: Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}
