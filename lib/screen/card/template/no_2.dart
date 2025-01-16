import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:itdat/models/http_client_model.dart';

import '../../../widget/setting/waitwidget.dart';

class No2 extends StatelessWidget {
  final BusinessCard cardInfo;
  final File? image;

  No2({
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

  String getFullImageUrl() {
    final baseUrl = "${dotenv.env['BASE_URL']}";
    if (cardInfo.logoUrl != null &&
        (cardInfo.logoUrl!.startsWith('http://') || cardInfo.logoUrl!.startsWith('https://'))) {
      return cardInfo.logoUrl!;
    } else {
      return '$baseUrl/${cardInfo.logoUrl ?? ""}';
    }
  }


  Future<bool> checkFileExists(String url) async {
    final client = await HttpClientModel().createHttpClient();
    try {
      final response = await client.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  Color hexToColor(String? hex, {Color fallback = Colors.white}) {
    if (hex == null || hex.isEmpty) {
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FutureBuilder<bool>(
            future: checkFileExists(getFullImageUrl()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return WaitAnimationWidget();
              } else if (snapshot.hasData && snapshot.data == true) {
                return Image.network(
                  getFullImageUrl(),
                  height: 30,
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
          const Padding(padding: EdgeInsets.only(top: 20)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    cardInfo.position ?? "",
                    style: _buildTextStyle(
                      textColor: textColor,
                      fontFamily: cardInfo.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    cardInfo.userName ?? "",
                    style: _buildTextStyle(
                      textColor: textColor,
                      fontFamily: cardInfo.fontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                cardInfo.department ?? "",
                style: _buildTextStyle(
                  textColor: textColor,
                  fontFamily: cardInfo.fontFamily,
                  fontSize: 15,
                ),
              ),
              const Divider(thickness: 1, color: Colors.grey),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "M. ",
                    style: _buildTextStyle(
                      textColor: textColor,
                      fontFamily: cardInfo.fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cardInfo.phone ?? "",
                    style: _buildTextStyle(
                      textColor: textColor,
                      fontFamily: cardInfo.fontFamily,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (cardInfo.email != null && cardInfo.email!.isNotEmpty) ...[
                    Text(
                      "E. ",
                      style: _buildTextStyle(
                        textColor: textColor,
                        fontFamily: cardInfo.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cardInfo.email ?? "",
                      style: _buildTextStyle(
                        textColor: textColor,
                        fontFamily: cardInfo.fontFamily,
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  if (cardInfo.companyNumber != null &&
                      cardInfo.companyNumber!.isNotEmpty) ...[
                    Text(
                      "T. ",
                      style: _buildTextStyle(
                        textColor: textColor,
                        fontFamily: cardInfo.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cardInfo.companyNumber ?? "",
                      style: _buildTextStyle(
                        textColor: textColor,
                        fontFamily: cardInfo.fontFamily,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (cardInfo.companyFax != null &&
                      cardInfo.companyFax!.isNotEmpty) ...[
                    Text(
                      "F. ",
                      style: _buildTextStyle(
                        textColor: textColor,
                        fontFamily: cardInfo.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cardInfo.companyFax ?? "",
                      style: _buildTextStyle(
                        textColor: textColor,
                        fontFamily: cardInfo.fontFamily,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                cardInfo.companyAddress ?? "",
                style: _buildTextStyle(
                  textColor: textColor,
                  fontFamily: cardInfo.fontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
