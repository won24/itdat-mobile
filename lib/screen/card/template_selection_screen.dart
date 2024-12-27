import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/form_screen.dart';

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

  List templates = [];
  String selectedTemplate = "";
  final CardModel cardModel = CardModel();
  final String serverBaseUrl = "http://112.221.66.174:8001";

  @override
  void initState() {
    super.initState();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    try {
      final data = await cardModel.getTemplates();
      setState(() {
        templates = data.map((template) {
          return {
            'templateId': template['templateId'],
            'svgUrl': "$serverBaseUrl${template['svgUrl']}",
            'thumbnailUrl': "$serverBaseUrl${template['thumbnailUrl']}",
          };
        }).toList();
      });
    } catch (e) {
      print("Error 템플릿 가져오기: $e");
    }
  }

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
        itemBuilder: (context, index) {
          final template = templates[index];
          return GestureDetector(
            onTap: () =>
                setState(() {
                  selectedTemplate = template['svgUrl'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormScreen(templateUrl:template['svgUrl'], userId: widget.userId),
                    ),
                  );
                }),
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: SvgPicture.network(
                        template['thumbnailUrl'], fit: BoxFit.contain),
                  ),
                  Text(template['templateId'].toString()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}