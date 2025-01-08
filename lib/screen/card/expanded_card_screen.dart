import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/screen/card/template/load_no1_back.dart';
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

  @override
  Widget build(BuildContext context) {

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
      String imageUrl = 'http://112.221.66.174:8001' + cardInfo.logoPath!;
      switch (cardInfo.appTemplate) {
        case 'No1':
          // return LoadNo1Back(cardInfo: cardInfo, imageUrl:imageUrl);
          return No1Back(cardInfo: cardInfo, image: File(""));
        case 'No2':
          return No2Back(cardInfo: cardInfo, image: File(""));
        case 'No3':
          return No3Back(cardInfo: cardInfo, image: File(""));
        default:
          return No2Back(cardInfo: cardInfo, image: File("")); // 기본값
      }
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildBusinessCard(cardInfo),
                if (backCard != null) ...[
                  const SizedBox(height: 10),
                  buildBackCardWithLogo(backCard!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}