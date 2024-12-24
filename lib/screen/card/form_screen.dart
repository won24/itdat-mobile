import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/preview_screen.dart';
import 'dart:io';

class FormScreen extends StatefulWidget {
  final int templateId;

  const FormScreen({
    super.key,
    required this.templateId
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {

  final CardModel cardModel = CardModel();
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _userInfo = {};
  File? _logo;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _companyName = TextEditingController();
  final TextEditingController _companyNumber = TextEditingController();
  final TextEditingController _position = TextEditingController();
  final TextEditingController _department = TextEditingController();
  final TextEditingController _fax = TextEditingController();

  Future<void> _pickLogo() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logo = File(pickedFile.path);
      });
    }
  }

  void changeInfo(){
    String updateName = _name.text;
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _logo != null) {
      _formKey.currentState!.save();
      final businessCard = await cardModel.createBusinessCard(_userInfo, _logo!.path, widget.templateId);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PreviewScreen(svgUrl: businessCard.svgUrl)),
      );
    }
  }


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
                _logo != null ?
                    Image.file(_logo!, width: 100, height: 100, fit: BoxFit.cover,)
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

            ElevatedButton(
                onPressed: _submitForm,
                child: const Text("명함 생성"))
          ],
        ),
      ),
    );
  }
}
