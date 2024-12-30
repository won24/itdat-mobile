import 'package:flutter/material.dart';
import 'package:itdat/screen/card/preview_screen.dart';

class PersonalCardFormScreen extends StatefulWidget {
  final String userId;
  final String selectedTemplate;

  const PersonalCardFormScreen({
    super.key,
    required this.userId,
    required this.selectedTemplate,
  });

  @override
  State<PersonalCardFormScreen> createState() => _PersonalCardFormScreenState();
}

class _PersonalCardFormScreenState extends State<PersonalCardFormScreen> {


  Map<String, dynamic> cardInfo = {
    "userName": "",
    "phone": "",
    "email": "",
    "companyName": "",
    "companyNumber": "",
    "companyAddress": "",
    "companyFax": "",
    "position": "",
    "department": "",
  };

  Map<String, bool> fieldVisibility = {
    "email": true,
    "companyNumber": true,
    "companyAddress": true,
    "companyFax": true,
    "position": true,
    "department": true,
  };


  void toggleFieldVisibility(String field) {
    setState(() {
      fieldVisibility[field] = !fieldVisibility[field]!;
    });
  }

  void previewBusinessCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewScreen(
          userId: widget.userId,
          selectedTemplate: widget.selectedTemplate,
          cardInfo: cardInfo,
          fieldVisibility: fieldVisibility,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("개인 명함 정보 입력")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => cardInfo["userName"] = value,
              decoration: InputDecoration(labelText: "이름"),
            ),
            TextField(
              onChanged: (value) => cardInfo["phone"] = value,
              decoration: InputDecoration(labelText: "연락처"),
            ),
            TextField(
              onChanged: (value) => cardInfo["companyName"] = value,
              decoration: InputDecoration(labelText: "회사 이름"),
            ),
            ...fieldVisibility.keys.map((field) {
              return Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: fieldVisibility[field],
                        onChanged: (value) => toggleFieldVisibility(field),
                      ),
                      Text("Include ${field[0].toUpperCase()}${field.substring(1)}"),
                    ],
                  ),
                  if (fieldVisibility[field]!)
                    TextField(
                      onChanged: (value) => cardInfo[field] = value,
                      decoration: InputDecoration(labelText: field),
                    ),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: previewBusinessCard,
              child: Text("미리보기"),
            ),
          ],
        ),
      ),
    );
  }
}