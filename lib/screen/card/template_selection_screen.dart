import 'package:flutter/material.dart';
import 'package:itdat/screen/card/form_screen.dart';

class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = ['Template1', 'Template2','Template3'];
    
    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: templates.length,
        itemBuilder: (context, index){
          return GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>
                    FormScreen(selectedTemplate: templates[index]),
                  ));
            },
            child: Card(
              child: Center(child: Text(templates[index]),),
          ),
          );
        }),
    );
  }
}
