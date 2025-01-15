import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/back_form_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/mainLayout.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FormScreen extends StatefulWidget {
  final BusinessCard cardInfo;

  const FormScreen({
    super.key,
    required this.cardInfo,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {

  File? _selectedCompanyImage;
  late Color backgroundColor;


  @override
  void initState() {
    super.initState();
    backgroundColor = hexToColor(widget.cardInfo.backgroundColor ?? "#FFFFFF");
  }


  // Hex -> Color
  Color hexToColor(String? hex, {Color fallback = Colors.white}) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }


  // Color -> Hex
  String colorToHex(Color color) {
    int r = (color.r * 255).toInt();
    int g = (color.g * 255).toInt();
    int b = (color.b * 255).toInt();

    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }


  // 색 선택
  void _changeColor(Color currentColor, bool isBackgroundColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(AppLocalizations.of(context)!.selectcolor),
          content: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              setState(() {
                if (isBackgroundColor) {
                  widget.cardInfo.backgroundColor = colorToHex(color);
                } else {
                  widget.cardInfo.textColor = colorToHex(color);
                }
              });
            },
            labelTypes: [ColorLabelType.rgb, ColorLabelType.hex],
            pickerAreaHeightPercent: 0.8,
          ),
          actions: [
            TextButton(
              child:  Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:  Text(AppLocalizations.of(context)!.confirm),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  // 글씨체 선택
  void _changeFontFamily() {
    final fontList = [
      'Nanum Gothic',
      'Do Hyeon',
      'Gowun Batang',
      'Gowun Dodum',
      'Song Myung',
      'Orbit',
      'IBM Plex Sans KR',
      'Roboto',
      'Lobster',
      'Noto Sans KR',
      'Roboto Mono',
      'Playfair Display',
      'Jura',
      'Major Mono Display',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(AppLocalizations.of(context)!.font),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: fontList.length,
              itemBuilder: (context, index) {
                final fontName = fontList[index];
                return ListTile(
                  title: Text(
                    fontName,
                    style: GoogleFonts.getFont(fontName),
                  ),
                  onTap: () {
                    setState(() {
                      widget.cardInfo.fontFamily = fontName;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }




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

  // 이미지 선택
  Future<void> _selectCompanyImage() async {
    if (await requestStoragePermission()) {
      File? image = await getImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedCompanyImage = image;
          widget.cardInfo.logoUrl = image.path;
        });
      }
    }
  }

  // 이미지 삭제
  void _removeCompanyImage() {
    setState(() {
      _selectedCompanyImage = null;
      widget.cardInfo.logoUrl = null;
    });
  }


  // 이미지 선택 위젯
  Widget _buildCompanyNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("회사 로고 이미지", style: TextStyle(fontSize: 16)),
        Text("회사이름 대신 사용", style: TextStyle(color: Colors.grey.shade400),),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectCompanyImage,
          child: _selectedCompanyImage != null
            ? Row(
              children: [
                Image.file(
                  _selectedCompanyImage!,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: _removeCompanyImage,
                ),
              ],
            )
            : Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: const Icon(Icons.add_a_photo, color: Colors.grey),
            ),
        ),
      ],
    );
  }


  // 명함 저장 버튼
  void _saveCard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: Border.all(
          color: Colors.transparent,
        ),
        content: SizedBox(
          width: double.infinity,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("추가로 명함 뒷면을 제작하시겠습니까?",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(onPressed: (){
                    moveToBackFormScreen();
                  }, child: Text("네")),
                  TextButton(
                    onPressed: () {
                      _createCard();
                    },
                    child: Text("아니오"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  void moveToBackFormScreen() async {
    await CardModel().createBusinessCard(widget.cardInfo);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => BackFormScreen(cardInfo: widget.cardInfo),
      ),
          (route) => false,
    );
  }



  // 저장
  void _createCard() async {
    try {

      if (_selectedCompanyImage == null) {
        await CardModel().createBusinessCard(widget.cardInfo);
      } else {
        await CardModel().saveBusinessCardWithLogo(widget.cardInfo);
      }

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

  // 명함 템플릿
  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo, image: _selectedCompanyImage);
      case 'No2':
        return No2(cardInfo: cardInfo, image: _selectedCompanyImage);
      case 'No3':
        return No3(cardInfo: cardInfo, image: _selectedCompanyImage,);
      default:
        return No1(cardInfo: cardInfo); // 기본값
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required String? initialValue,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(0, 202, 145, 1), width: 1.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
      validator: validator,
      onChanged: (value) => setState(() => onChanged(value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("명함 제작"),
        actions: [
          IconButton(
            icon: Image.asset('assets/icons/background.png', height: 25, width: 25,  color: isDarkMode ? Colors.grey[200] : Colors.black,),
            onPressed: () {
              _changeColor(backgroundColor, true);
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/text.png', height: 25, width: 25,  color: isDarkMode ? Colors.grey[200] : Colors.black,),
            onPressed: () {
              _changeColor(backgroundColor, false);
            },
          ),
          IconButton(
            icon: Image.asset('assets/icons/font.png', height: 25, width: 25,  color: isDarkMode ? Colors.grey[200] : Colors.black,),
            onPressed: _changeFontFamily,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: buildBusinessCard(widget.cardInfo),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: "이름",
                hint: "이름을 입력하세요",
                icon: Icons.person,
                initialValue: widget.cardInfo.userName,
                onChanged: (value) => widget.cardInfo.userName = value,
                validator: (value) => value == null || value.isEmpty ? "이름을 입력하세요." : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: "연락처",
                hint: "연락처를 입력하세요",
                icon: Icons.phone_android_sharp,
                initialValue: widget.cardInfo.phone,
                onChanged: (value) => widget.cardInfo.phone = value,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: "이메일",
                hint: "이메일을 입력하세요",
                icon: Icons.mail,
                initialValue: widget.cardInfo.email,
                onChanged: (value) => widget.cardInfo.email = value,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: "회사 이름",
                hint: "회사 이름을 입력하세요",
                icon: Icons.business,
                initialValue: widget.cardInfo.companyName,
                onChanged: (value) => widget.cardInfo.companyName = value,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: "회사 연락처",
                hint: "회사 연락처를 입력하세요",
                icon: Icons.call,
                initialValue: widget.cardInfo.companyNumber,
                onChanged: (value) => widget.cardInfo.companyNumber = value,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: "회사 주소",
                hint: "회사 주소를 입력하세요",
                icon: Icons.location_on,
                initialValue: widget.cardInfo.companyAddress,
                onChanged: (value) => widget.cardInfo.companyAddress = value,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: "팩스 번호",
                hint: "팩스 번호를 입력하세요",
                icon: Icons.fax_sharp,
                initialValue: widget.cardInfo.companyFax,
                onChanged: (value) => widget.cardInfo.companyFax = value,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: "부서",
                hint: "부서를 입력하세요",
                icon: Icons.work_sharp,
                initialValue: widget.cardInfo.department,
                onChanged: (value) => widget.cardInfo.department = value,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                label: "직급",
                hint: "직급을 입력하세요",
                icon: Icons.work,
                initialValue: widget.cardInfo.position,
                onChanged: (value) => widget.cardInfo.position = value,
              ),
              const SizedBox(height: 10),

              _buildCompanyNameInput(), // 회사 이름 또는 이미지 선택 UI
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 202, 145, 1),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("저장"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

