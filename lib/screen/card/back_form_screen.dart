import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/no_1_back.dart';
import 'package:itdat/screen/card/template/no_2_back.dart';
import 'package:itdat/screen/card/template/no_3_back.dart';
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

  // 갤러리 사진 선택
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

  // 갤러리 권한 받기
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status; // 권한 상태 확인
    if (status.isGranted) {
      return true; // 이미 권한이 허용된 경우
    } else {
      var result = await Permission.storage.request(); // 권한 요청
      if (result.isGranted) {
        return true; // 권한 허용된 경우
      } else {
        // 권한 거부된 경우 처리
        print('갤러리 권한이 거부되었습니다.');
        return false;
      }
    }
  }

  // 명함 저장
  void _saveCard() async {
    widget.cardInfo.cardSide = 'BACK';
    widget.cardInfo.logoPath = _image?.path;

    if (_image == null) {
      _showSnackBar("로고 이미지를 선택해주세요.", isError: true);
      return;
    }

    try {
      await CardModel().saveBusinessCardWithLogo(widget.cardInfo);
      _showSnackBar("명함이 제작되었습니다.");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) =>
              MainLayout()), (route) => false);
    } catch (e) {
      _showSnackBar("명함 저장에 실패했습니다. 다시 시도해주세요.", isError: true);
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

  // 명함 템플릿
  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1Back(cardInfo: cardInfo, image: _image);
      case 'No2':
        return No2Back(cardInfo: cardInfo, image: _image);
      case 'No3':
        return No3Back(cardInfo: cardInfo, image: _image);
      default:
        return No2Back(cardInfo: cardInfo, image: _image); // 기본값
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("명함 미리보기")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                    width: double.infinity,
                    child: buildBusinessCard(widget.cardInfo),
                  )
              ),
              const SizedBox(height: 20),

              // TextFormField(
              //   initialValue: widget.cardInfo.companyName?? "",
              //   decoration: InputDecoration(labelText: "회사 이름"),
              //   onChanged: (value){
              //     setState(() {
              //       widget.cardInfo.companyName = value;
              //     });
              //   }
              // ),
              // TextFormField(
              //     initialValue: widget.cardInfo.companyNumber?? "",
              //     decoration: InputDecoration(labelText: "회사 연락처"),
              //     onChanged: (value){
              //       setState(() {
              //         widget.cardInfo.companyNumber = value;
              //       });
              //     }
              // ),
              // TextFormField(
              //     initialValue: widget.cardInfo.companyAddress?? "",
              //     decoration: InputDecoration(labelText: "회사 주소"),
              //     onChanged: (value){
              //       setState(() {
              //         widget.cardInfo.companyAddress = value;
              //       });
              //     }
              // ),
              // TextFormField(
              //     initialValue: widget.cardInfo.companyFax?? "",
              //     decoration: InputDecoration(labelText: "팩스번호"),
              //     onChanged: (value){
              //       setState(() {
              //         widget.cardInfo.companyFax = value;
              //       });
              //     }
              // ),
              // const SizedBox(height: 20),

              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("로고 선택",
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
                    const SizedBox(width: 10), // 버튼 간 간격
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
