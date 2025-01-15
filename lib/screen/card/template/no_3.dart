import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itdat/models/http_client_model.dart';

class No3 extends StatelessWidget {
  final BusinessCard cardInfo;
  final File? image;

  const No3({
    super.key,
    required this.cardInfo,
    this.image,
  });

  TextStyle _buildTextStyle({
    required Color? textColor,
    required String? fontFamily,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.getFont(
      fontFamily ?? 'Nanum Gothic',
      color: textColor ?? Colors.black87,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  // 이미지 가져오기
  String getFullImageUrl() {
    final baseUrl = "${dotenv.env['BASE_URL']}";
    if (cardInfo.logoUrl != null &&
        (cardInfo.logoUrl!.startsWith('http://') || cardInfo.logoUrl!.startsWith('https://'))) {
      return cardInfo.logoUrl!;
    } else {
      return '$baseUrl${cardInfo.logoUrl ?? ""}';
    }
  }


  // 이미지 있는 지 확인
  Future<bool> checkFileExists(String url) async {
    final client = await HttpClientModel().createHttpClient();
    try {
      final response = await client.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 색 코드 변경
  Color hexToColor(String? hex, {Color fallback = Colors.white}) {
    if (hex == null || hex.isEmpty){
      return fallback;
    }
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
  }


  @override
  Widget build(BuildContext context) {

    Color backgroundColor = hexToColor(cardInfo.backgroundColor, fallback: Colors.white);
    Color textColor = hexToColor(cardInfo.textColor, fallback: Colors.black87);


    return Container(
      width: 420,
      height: 255,
      decoration: BoxDecoration(
        color: backgroundColor,
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
                          style: _buildTextStyle(
                            textColor: textColor,
                            fontFamily: cardInfo.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    },
                  ),
                  Container(
                    width: 1,
                    height: 180,
                    color: textColor ?? Colors.grey,
                  ),
                  Column(
                    children: [
                      Text(
                        cardInfo.userName ?? "이름",
                        style: _buildTextStyle(
                          textColor: textColor,
                          fontFamily: cardInfo.fontFamily,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        cardInfo.phone ?? "핸드폰 번호",
                        style: _buildTextStyle(
                          textColor: textColor,
                          fontFamily: cardInfo.fontFamily,
                        ),
                      ),
                      if (cardInfo.email != null && cardInfo.email!.isNotEmpty) ...[
                        Text(
                          cardInfo.email ?? "이메일",
                          style: _buildTextStyle(
                            textColor: textColor,
                            fontFamily: cardInfo.fontFamily,
                          ),
                        ),
                      ],
                      Text(
                        cardInfo.companyAddress ?? "회사 주소",
                        style: _buildTextStyle(
                          textColor: textColor,
                          fontFamily: cardInfo.fontFamily,
                        ),
                      ),
                      if (cardInfo.companyNumber != null &&
                          cardInfo.companyNumber!.isNotEmpty) ...[
                        Text(
                          "T. ${cardInfo.companyNumber ?? "회사 번호"}",
                          style: _buildTextStyle(
                            textColor: textColor,
                            fontFamily: cardInfo.fontFamily,
                          ),
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
