import 'package:flutter/material.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/personal_card_form_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';

class TemplateSelectionScreen extends StatefulWidget {

  final String userId;

  const TemplateSelectionScreen({
    super.key,
    required this.userId
  });

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {

  List templates = [
    No1,
    No2,
    No3
  ];

  String selectedTemplate = "";
  final CardModel cardModel = CardModel();
  final String serverBaseUrl = "http://112.221.66.174:8001";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("템플릿 선택")),
      body: templates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: templates.length,
        itemBuilder: (context, i) {
          final template = templates[i];
          return GestureDetector(
            onTap: () =>
                setState(() {
                  selectedTemplate = template;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // builder: (context) => FormScreen(templateUrl:template['svgUrl'], userId: widget.userId),
                      builder: (context) => PersonalCardFormScreen(userId: widget.userId, selectedTemplate: selectedTemplate
                      )
                    ),
                  );
                },
                ),
            child: Card(
              child: template, // 템플릿 위젯 표시
            ),
          );
        },
      ),
    );
  }
}

