import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No3 extends StatelessWidget {
  final BusinessCard cardInfo;
  final File? image;

  const No3({
    super.key,
    required this.cardInfo,
    this.image,
  });

  @override
  Widget build(BuildContext context) {

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

    Future<bool> checkFileExists(String url) async {
      try {
        final response = await http.head(Uri.parse(url));
        return response.statusCode == 200;
      } catch (e) {
        return false;
      }
    }

    return Container(
      width: 400,
      height: 240,
      decoration: BoxDecoration(
        color: cardInfo.backgroundColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FutureBuilder<bool>(
                    future: checkFileExists(getFullImageUrl()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData && snapshot.data == true) {
                        if (cardInfo.logoUrl != null && cardInfo.logoUrl!.isNotEmpty) {
                          return Image.network(
                            getFullImageUrl(),
                            height: 50,
                            fit: BoxFit.contain,
                          );
                        } else {
                          return Text(
                            cardInfo.companyName ?? "회사 이름",
                            style: TextStyle(
                              fontSize: 18,
                              color: cardInfo.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      } else {
                        if (image != null){
                          return Image.file(
                            image!,
                            height: 50,
                            fit: BoxFit.contain,
                          );
                        }else{
                          return Text(
                            cardInfo.companyName ?? "회사 이름",
                            style: TextStyle(
                              fontSize: 18,
                              color: cardInfo.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  Container(
                    width: 1, // 세로 줄의 두께
                    height: 180, // 세로 줄의 길이
                    color: cardInfo.textColor ?? Colors.grey
                  ),
                  Column(
                    children: [
                      Text(
                        cardInfo.userName ?? "이름",
                        style: TextStyle(
                            fontSize: 23,
                            color: cardInfo.textColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        cardInfo.phone ?? "핸드폰 번호",
                        style: TextStyle(color: cardInfo.textColor),
                      ),
                      if (cardInfo.email != null && cardInfo.email!.isNotEmpty)
                      ...[
                        Text(
                          cardInfo.email ?? "이메일",
                          style: TextStyle(color: cardInfo.textColor),
                        ),
                      ],
                      Text(
                        cardInfo.companyAddress ?? "회사 주소",
                        style: TextStyle(color: cardInfo.textColor),
                      ),
                      if (cardInfo.companyNumber != null && cardInfo.companyNumber!.isNotEmpty)
                        ...[
                          Text(
                            "T. ${cardInfo.companyNumber ?? "회사 번호"}",
                            style: TextStyle(color: cardInfo.textColor),
                          ),
                        ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
