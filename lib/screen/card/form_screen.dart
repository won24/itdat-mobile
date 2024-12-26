import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itdat/screen/card/preview_screen.dart';
import 'dart:io';

class FormScreen extends StatefulWidget {
  final String selectedTemplate;

  const FormScreen({
    super.key,
    required this.selectedTemplate
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey _tempatekey = GlobalKey(); // 캡쳐
  File? _logoFile;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _companyNumber = TextEditingController();
  final TextEditingController _position = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _fax = TextEditingController();

  Future<void> _pickLogo() async{
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if(pickedFile != null){
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  // Future<File> _saveTemplateAsImage() async {
  //   try{
  //     RenderRepaintBoundary boundary =
  //         _tempatekey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  //
  //     // 명함 위젯 이미지로 변환
  //     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //     if (byteData == null) throw Exception('Failed to convert image');
  //
  //     // 로컬에 저장
  //     final directory = await getApplicationDocumentsDirectory();
  //     final filePath = '${directory.path}/business_card.png';
  //     final file = File(filePath);
  //     await file.writeAsBytes(byteData.buffer.asUint8List());
  //     return file;
  //   } catch (e) {
  //     throw Exception('명함 템플릿 이미지 저장 실패: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: _position, decoration: const InputDecoration(labelText: 'Position')),
            TextField(controller: _department, decoration: const InputDecoration(labelText: 'Department')),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _fax, decoration: const InputDecoration(labelText: 'Fax')),
            TextField(controller: _companyName, decoration: const InputDecoration(labelText: 'Company Name')),
            TextField(controller: _companyNumber, decoration: const InputDecoration(labelText: 'Company Number')),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('로고 선택', style: TextStyle(fontSize: 16),),
                const SizedBox(height: 10,),
                _logoFile != null ?
                    Image.file(_logoFile!, width: 100, height: 100, fit: BoxFit.cover,)
                    : const Text("선택된 로고가 없습니다."),
                const SizedBox(height: 10,),
                ElevatedButton.icon(
                  onPressed: _pickLogo,
                  icon: Icon(Icons.image),
                  label: const Text("로고를 선택해주세요."),
                )
              ],
            ),
            const SizedBox(height: 20,),

            // 템플릿 미리보기 (캡처 영역)
            RepaintBoundary(
              key: _tempatekey,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _logoFile != null ? Image.file(_logoFile!, width: 80, height: 80) : const SizedBox(),
                    Text('Name: ${_name.text}', style: const TextStyle(fontSize: 16)),
                    Text('Position: ${_position.text}', style: const TextStyle(fontSize: 16)),
                    Text('Phone: ${_phone.text}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ElevatedButton(
            //     onPressed: () async {
            //       try {
            //         File savedFile = await _saveTemplateAsImage();
            //         Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => PreviewScreen(imageFile: savedFile),
            //           ),
            //         );
            //       } catch (e) {
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           SnackBar(content: Text('Error: $e')),
            //         );
            //       }
            //     }, child: const Text("미리보기 & 저장"))
          ],
        ),
      ),
    );
  }
}
