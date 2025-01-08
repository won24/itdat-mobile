import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/back_form_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/mainLayout.dart';


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

  static const Color primaryColor = Color.fromRGBO(0, 202, 145, 1);
  static const double fieldSpacing = 10.0;

  // 명함 저장
  void _saveCard() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("명함이 저장 되었습니다.", style: TextStyle(fontSize: 18),),
              const Text("해당 명함의 뒷면을 추가로 만드시겠습니까?", style: TextStyle(fontSize: 15),),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(onPressed: (){
                    moveToBackFormScreen();
                  }, child: const Text("네")),
                  TextButton(
                    onPressed: () {
                      _createCard();
                      // showDialog(
                      //   context: context,
                      //   builder: (context) => AlertDialog(
                      //     shape: Border.all(
                      //       color: Colors.transparent,
                      //     ),
                      //     content: SizedBox(
                      //       width: 250,
                      //       height: 120,
                      //       child: Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           const Padding(
                      //             padding: const EdgeInsets.only(bottom: 20.0),
                      //             child: Text(
                      //               "명함을 저장 하시겠습니까?",
                      //               style: TextStyle(fontSize: 17),
                      //               textAlign: TextAlign.center,
                      //             ),
                      //           ),
                      //           Row(
                      //             mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //             children: [
                      //               TextButton(
                      //                 onPressed: () {
                      //                   _createCard();
                      //                 },
                      //                 child: Text("저장"),
                      //               ),
                      //               TextButton(
                      //                 onPressed: () {
                      //                   Navigator.pushAndRemoveUntil(
                      //                     context,
                      //                     MaterialPageRoute(
                      //                       builder: (BuildContext context) => MainLayout(),
                      //                     ),
                      //                         (route) => false,
                      //                   );
                      //                 },
                      //                 child: Text("취소"),
                      //               ),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // );
                    },
                    child: Text("아니오"),
                  )
                ],
              )
            ],
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  void moveToBackFormScreen() async {
    await CardModel().createBusinessCard(widget.cardInfo);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) =>
              BackFormScreen(cardInfo: widget.cardInfo)), (route) => false
    );
  }


  void _createCard() async {
    try {
      await CardModel().createBusinessCard(widget.cardInfo);
      _showSnackBar("새로운 명함이 생성되었습니다.");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) =>
                MainLayout()), (route) => false
      );
    } catch (e) {
      _showSnackBar(
          "명함 생성에 실패했습니다. 다시 시도해주세요.", isError: true);
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

  void _showBottomSheet({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 150,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 18)),
              Text(content, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions,
              ),
            ],
          ),
        );
      },
    );
  }


  // 명함 템플릿
  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'No3':
        return No3(cardInfo: cardInfo);
      default:
        return No2(cardInfo: cardInfo); // 기본값
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
          borderSide: BorderSide(color: primaryColor, width: 1.0),
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
    return Scaffold(
      appBar: AppBar(title: const Text("명함 미리보기")),
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
              const SizedBox(height: fieldSpacing),
              _buildTextField(
                label: "연락처",
                hint: "연락처를 입력하세요",
                icon: Icons.phone_android_sharp,
                initialValue: widget.cardInfo.phone,
                onChanged: (value) => widget.cardInfo.phone = value,
              ),
              const SizedBox(height: fieldSpacing),
              _buildTextField(
                label: "이메일",
                hint: "이메일을 입력하세요",
                icon: Icons.mail,
                initialValue: widget.cardInfo.email,
                onChanged: (value) => widget.cardInfo.email = value,
              ),
              const SizedBox(height: fieldSpacing),
              _buildTextField(
                label: "회사 이름",
                hint: "회사 이름을 입력하세요",
                icon: Icons.business,
                initialValue: widget.cardInfo.companyName,
                onChanged: (value) => widget.cardInfo.companyName = value,
              ),
              const SizedBox(height: fieldSpacing),
              _buildTextField(
                label: "회사 연락처",
                hint: "회사 연락처를 입력하세요",
                icon: Icons.call,
                initialValue: widget.cardInfo.companyNumber,
                onChanged: (value) => widget.cardInfo.companyNumber = value,
              ),
              const SizedBox(height: fieldSpacing),
              _buildTextField(
                label: "회사 주소",
                hint: "회사 주소를 입력하세요",
                icon: Icons.location_on,
                initialValue: widget.cardInfo.companyAddress,
                onChanged: (value) => widget.cardInfo.companyAddress = value,
              ),
              const SizedBox(height: fieldSpacing),
              _buildTextField(
                label: "팩스 번호",
                hint: "팩스 번호를 입력하세요",
                icon: Icons.fax_sharp,
                initialValue: widget.cardInfo.companyFax,
                onChanged: (value) => widget.cardInfo.companyFax = value,
              ),
              const SizedBox(height: fieldSpacing),
              _buildTextField(
                label: "부서",
                hint: "부서를 입력하세요",
                icon: Icons.work_sharp,
                initialValue: widget.cardInfo.department,
                onChanged: (value) => widget.cardInfo.department = value,
              ),
              const SizedBox(height: fieldSpacing),
              _buildTextField(
                label: "직급",
                hint: "직급을 입력하세요",
                icon: Icons.work,
                initialValue: widget.cardInfo.position,
                onChanged: (value) => widget.cardInfo.position = value,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _saveCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
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

