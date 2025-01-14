import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:http/http.dart' as http;

class BackTemplate extends StatelessWidget {
  final BusinessCard cardInfo;
  final File? image;

  BackTemplate({
    super.key,
    required this.cardInfo,
    this.image,
  });

  // 색 코드 변경
  Color hexToColor(String? hex, {Color fallback = Colors.white}) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }

  // 이미지 가져오기
  String getFullImageUrl() {
    const baseUrl = 'http://112.221.66.174:8001';
    if (cardInfo.logoUrl != null &&
        (cardInfo.logoUrl!.startsWith('http://') || cardInfo.logoUrl!.startsWith('https://'))) {
      return cardInfo.logoUrl!;
    } else {
      return '$baseUrl${cardInfo.logoUrl ?? ""}';
    }
  }

  // 이미지 있는 지 확인
  Future<bool> checkFileExists(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = hexToColor(cardInfo.backgroundColor);
    Color textColor = hexToColor(cardInfo.textColor);

    return Container(
      width: 420,
      height: 255,
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 로고 이미지 렌더링
          cardInfo.logoUrl != null
              ? FutureBuilder<bool>(
            future: checkFileExists(getFullImageUrl()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData && snapshot.data == true) {
                return Image.network(
                  getFullImageUrl(),
                  height: 50,
                  fit: BoxFit.contain,
                );
              } else if (image != null) {
                return Image.file(
                  image!,
                  height: 50,
                  fit: BoxFit.contain,
                );
              } else {
                return Text(
                  cardInfo.companyName ?? "회사 이름",
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
            },
          )
              : Text(
            cardInfo.companyName ?? "",
            style: TextStyle(
              fontSize: 20,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          // 텍스트가 활성화 되어 있으면 텍스트 렌더링
          if (cardInfo.isTextEnabled != null) ...[
            if (cardInfo.textPosition == 'above')
              Text(
                cardInfo.customText ?? "",
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],

          // 텍스트가 활성화 되어 있으면 텍스트 렌더링 (아래)
          if (cardInfo.isTextEnabled != null) ...[
            if (cardInfo.textPosition == 'below')
              Text(
                cardInfo.customText ?? "",
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

