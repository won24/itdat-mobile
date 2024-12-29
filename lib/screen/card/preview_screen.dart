import 'package:flutter/material.dart';
import 'package:itdat/screen/card/personal_card_form_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';

class PreviewScreen extends StatelessWidget {
  final String userId;
  final String selectedTemplate;
  final Map<String, dynamic> cardInfo;
  final Map<String, bool> fieldVisibility;

  const PreviewScreen({
    super.key,
    required this.userId,
    required this.selectedTemplate,
    required this.cardInfo,
    required this.fieldVisibility,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("미리보기")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: buildBusinessCard(selectedTemplate, cardInfo),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PersonalCardFormScreen(
                    userId: userId,
                    selectedTemplate: selectedTemplate,
                  ),
                ),
              );
            },
            child: Text("돌아가기"),
          ),
        ],
      ),
    );
  }
}

Widget buildBusinessCard(String template, Map<String, dynamic> cardInfo) {
  switch (template) {
    case 'No1':
      return No1(cardInfo: cardInfo);
    case 'No2':
      return No2(cardInfo: cardInfo);
    case 'No3':
      return No3(cardInfo: cardInfo);
    default:
      return No2(cardInfo: cardInfo); // 기본값
  }
}

