import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_1_back.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_2_back.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template/no_3_back.dart';

class ExpandedCardScreen extends StatelessWidget {
  final BusinessCard cardInfo;
  final BusinessCard? backCard;

  const ExpandedCardScreen({
    super.key,
    required this.cardInfo,
    required this.backCard,
  });

  // 앞면 렌더링
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

  // 뒷면 렌더링
  Widget buildBackCardWithLogo(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1Back(cardInfo: cardInfo);
      case 'No2':
        return No2Back(cardInfo: cardInfo);
      case 'No3':
        return No3Back(cardInfo: cardInfo);
      default:
        return No2Back(cardInfo: cardInfo); // 기본값
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildBusinessCard(cardInfo),
            if (backCard != null) ...[
              const SizedBox(height: 10),
              buildBackCardWithLogo(backCard!),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context), // 모달 닫기
              child: const Text("닫기"),
            ),
          ],
        ),
      ),
    );
  }
}