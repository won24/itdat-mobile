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

  // 명함 저장
  void _saveCard() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Container(
            height: 150,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("현재 명함의 뒷면을 만드시겠습니까?", style: TextStyle(fontSize: 18),),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(onPressed: (){
                      moveToBackFormScreen();
                    }, child: Text("명함 뒷면 만들기")),
                    TextButton(onPressed: (){
                      _createCard();
                    }, child: Text("현재 명함만 저장"))
                  ],
                )
              ],
            ),
          );
    });
  }

  void moveToBackFormScreen() async {
    try{
      await CardModel().createBusinessCard(widget.cardInfo);
      Navigator.push(context, MaterialPageRoute(
          builder: (BuildContext context) =>
              BackFormScreen(cardInfo: widget.cardInfo)
      ));
    }catch (e) {
      _showSnackBar(
          "명함 생성에 실패했습니다. 다시 시도해주세요.", isError: true);
    }
  }

  void _createCard() async {
    try {
      await CardModel().createBusinessCard(widget.cardInfo);
      _showSnackBar("새로운 명함이 생성되었습니다.");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  MainLayout()), (route) => false);
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

                TextFormField(
                  initialValue: widget.cardInfo.userName?? "",
                  decoration: InputDecoration(labelText: "이름"),
                  onChanged: (value){
                    setState(() {
                      widget.cardInfo.userName = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: widget.cardInfo.phone?? "",
                  decoration: InputDecoration(labelText: "연락처"),
                  onChanged: (value) {
                    setState(() {
                      widget.cardInfo.phone = value;
                    });
                  }
                ),
                TextFormField(
                  initialValue: widget.cardInfo.email?? "",
                  decoration: InputDecoration(labelText: "이메일"),
                  onChanged: (value){
                    setState(() {
                      widget.cardInfo.email = value;
                    });
                  }
                ),
                TextFormField(
                  initialValue: widget.cardInfo.companyName?? "",
                  decoration: InputDecoration(labelText: "회사 이름"),
                  onChanged: (value){
                    setState(() {
                      widget.cardInfo.companyName = value;
                    });
                  }
                ),
                TextFormField(
                  initialValue: widget.cardInfo.companyNumber?? "",
                  decoration: InputDecoration(labelText: "회사 연락처"),
                  onChanged: (value){
                    setState(() {
                      widget.cardInfo.companyNumber = value;
                    });
                  }
                ),
                TextFormField(
                  initialValue: widget.cardInfo.companyAddress?? "",
                  decoration: InputDecoration(labelText: "회사 주소"),
                  onChanged: (value){
                    setState(() {
                      widget.cardInfo.companyAddress = value;
                    });
                  }
                ),
                TextFormField(
                  initialValue: widget.cardInfo.companyFax?? "",
                  decoration: InputDecoration(labelText: "팩스번호"),
                  onChanged: (value){
                    setState(() {
                      widget.cardInfo.companyFax = value;
                    });
                  }
                ),
                TextFormField(
                  initialValue: widget.cardInfo.department?? "",
                  decoration: InputDecoration(labelText: "부서"),
                  onChanged: (value){
                    setState(() {
                      widget.cardInfo.department = value;
                    });
                  }
                ),
                TextFormField(
                  initialValue: widget.cardInfo.position?? "",
                  decoration: InputDecoration(labelText: "직급"),
                  onChanged: (value){
                   setState(() {
                     widget.cardInfo.position = value;
                   });
                  }
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _saveCard,
                  child: const Text("저장"),
                ),
              ],
            ),
        ),
      ),
    );
  }
}
