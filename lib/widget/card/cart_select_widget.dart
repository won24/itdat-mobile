import 'package:flutter/material.dart';
import 'business_card_List.dart';

class CardSelect extends StatelessWidget {
  const CardSelect({Key? key}) : super(key: key);

  // 하드코딩된 이메일 사용
  final String userEmail = "sksksk4502@naver.com";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("내 명함"),
      ),
      body: BusinessCardList(userEmail: userEmail),
    );
  }
}