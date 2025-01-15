import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/back_template.dart';
import 'package:itdat/screen/mainLayout.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class BackFormScreen extends StatefulWidget {
  final BusinessCard cardInfo;

  const BackFormScreen({
    super.key,
    required this.cardInfo,
  });

  @override
  State<BackFormScreen> createState() => _BackFormScreenState();
}

class _BackFormScreenState extends State<BackFormScreen> {

  File? _image;
  String? _customText;
  bool _isTextEnabled = false;
  String _textPosition = '';


  Future<File?> getImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return File(image.path);
    } else {
      print('선택된 이미지가 없습니다.');
      return null;
    }
  }


  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }


  void _saveCard() async {
    widget.cardInfo.cardSide = 'BACK';
    widget.cardInfo.logoUrl = _image?.path;
    widget.cardInfo.appTemplate = 'BackTemplate';
    widget.cardInfo.customText = _customText;
    widget.cardInfo.isTextEnabled = _isTextEnabled;
    widget.cardInfo.textPosition = _textPosition;

    if (_image == null) {
      _showSnackBar("로고 이미지를 선택해주세요.", isError: true);
      return;
    }

    try {
      await CardModel().saveBusinessCardWithLogo(widget.cardInfo);
      _showSnackBar("명함 제작 성공");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) =>
              MainLayout()), (route) => false);
    } catch (e) {
      _showSnackBar("명함 저장 실패. 다시 시도해주세요.", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      action: SnackBarAction(
        label: '확인',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("명함 뒷장")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                    width: double.infinity,
                    child: BackTemplate(cardInfo: widget.cardInfo, image: _image),
                  )
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("로고 선택",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade200,
                              width: 1),
                        ),
                        child: IconButton(
                          onPressed: () async {
                            if (await requestStoragePermission()) {
                              File? imageFile = await getImageFromGallery();
                              if (imageFile != null) {
                                setState(() {
                                  _image = imageFile;
                                });
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("권한 거부"),
                                      content: Text("갤러리 접근 권한이 필요합니다."),
                                      actions: <Widget>[
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("확인")
                                        )
                                      ],
                                    );
                                  });
                            }
                          },
                          icon: Icon(
                            Icons.add_photo_alternate_sharp, size: 30,),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _image != null
                          ? "선택된 이미지: ${path.basename(_image!.path)}"
                          : "선택된 이미지가 없습니다.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                title: Text("명함에 텍스트 추가"),
                value: _isTextEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isTextEnabled = value;
                    widget.cardInfo.isTextEnabled = _isTextEnabled;
                    print(widget.cardInfo.isTextEnabled);
                  });
                },
              ),
              if (_isTextEnabled) ...[
                TextField(
                  decoration: InputDecoration(labelText: "명함 텍스트 입력"),
                  onChanged: (value) {
                    setState(() {
                      _customText = value;
                      widget.cardInfo.customText = _customText;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("텍스트 위치: "),
                    Radio<String>(
                      value: 'above',
                      groupValue: _textPosition,
                      onChanged: (String? value) {
                        setState(() {
                          _textPosition = value!;
                          widget.cardInfo.textPosition = _textPosition;
                        });
                      },
                    ),
                    Text("로고 위"),
                    Radio<String>(
                      value: 'below',
                      groupValue: _textPosition,
                      onChanged: (String? value) {
                        setState(() {
                          _textPosition = value!;
                          widget.cardInfo.textPosition = _textPosition;
                        });
                      },
                    ),
                    Text("로고 아래"),
                  ],
                ),
              ],
              SizedBox(height:100),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _saveCard,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(0, 202, 145, 1),
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text("저장"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    MainLayout()), (route) => false
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text("취소"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
