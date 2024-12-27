import 'dart:io';  // File 클래스를 사용하기 위해 임포트
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/form_screen.dart';
import 'package:path_provider/path_provider.dart';

class TemplateSelectionScreen extends StatefulWidget {
  final String userId;


  const TemplateSelectionScreen({
    super.key,
    required this.userId,
  });

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final CardModel _cardModel = CardModel();
  late Future<List<Map<String, dynamic>>> _templates;

  @override


  void initState() {
    super.initState();
    _templates = _cardModel.getTemplates();

  }

  List<String> svgUrls(List<Map<String, dynamic>> templates) {
    return templates.map((template) => template['svgUrl'] as String).toList();
  }


  // SVG 파일을 로컬에 저장하는 함수
  Future<void> saveSvgToLocal(String svgContent) async {
    print("svgContent: $svgContent");
    try {
      // 앱의 문서 디렉터리 경로 얻기
      final directory = await getApplicationDocumentsDirectory();

      // 파일 경로 지정 (여기서는 'template.svg'로 저장)
      final file = File('${directory.path}/template.svg');

      // 파일 저장
      await file.writeAsString(svgContent);
      print('SVG file 저장: ${file.path}');
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  // 로컬에서 SVG 파일을 읽어오는 함수
  Future<String> loadSvgFromLocal() async {
    try {
      // 앱의 문서 디렉터리 경로 얻기
      final directory = await getApplicationDocumentsDirectory();

      // 파일 경로 지정
      final file = File('${directory.path}/template.svg');

      // 파일이 존재하면 읽어오기
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        throw Exception('SVG file not found');
      }
    } catch (e) {
      throw Exception('Error loading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("템플릿 선택"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _templates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final templates = snapshot.data!;

          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, i) {
              final template = templates[i];
              final templateId = template['templateId'];
              final svgUrl = template['svgUrl'];

              // 'file://' 접두어를 제거하고 로컬 경로를 File 객체로 처리
              final filePath = svgUrl.replaceFirst('file://', ''); // 'file://' 제거
              final file = File(filePath); // 파일 객체로 변환

              return ListTile(
                title: Text("명함 템플릿 #$templateId"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  // SVG URL을 통해 SVG 내용을 가져오기
                  try {
                    final svgContent = await _cardModel.fetchSvgContent(svgUrl);

                    // 가져온 SVG를 로컬에 저장하기
                    await saveSvgToLocal(svgContent);

                    // FormScreen으로 이동
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => FormScreen(templateId: templateId, userId: widget.userId),
                    //   ),
                    // );
                  } catch (e) {
                    print("Error: $e");
                  }
                },
                leading: svgUrl.isNotEmpty
                    ? SvgPicture.file(
                  file,  // 로컬 파일 경로로 SVG 렌더링
                  width: 50,
                  height: 50,
                  placeholderBuilder: (context) => const CircularProgressIndicator(),
                )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
