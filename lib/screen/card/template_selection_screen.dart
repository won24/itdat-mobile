import 'package:flutter/material.dart';
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
  final CardModel _cardModel = CardModel();
  late Future<List<Map<String,dynamic>>> _templates;


  @override
  void initState() {
    super.initState();
    _templates = _cardModel.getTemplates();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder<List<Map<String,dynamic>>>(
        future: _templates,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }else if(snapshot.hasError){
            return Center(child: Text("error: ${snapshot.error}"),);
          }

          final templates = snapshot.data!;
          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, i){
              final template = templates[i];
              final templateId = template['templateId'];
              final svgUrl = template['svgUrl'];  // 템플릿 이미지 URL

              return ListTile(
                title: Text("명함 템플릿 #$templateId"),
                subtitle: Text("$svgUrl"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (_) => FormScreen(templateId: templateId, userId: widget.userId),)
                  );
                },
              );
            },
          );
        },
      )
    );
  }
}
