import 'package:flutter/material.dart';
import 'dart:io';

class PreviewScreen extends StatelessWidget {
  final File imageFile;


  const PreviewScreen({
    super.key,
    required this.imageFile
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("명함 미리보기"),
          Text("명함 정보는 내 정보에서 수정 가능합니다."),
          Image.file(imageFile),
        ],
      ),
    );
  }
}
