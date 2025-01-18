import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/utils/HttpClientManager.dart';
import '../../../widget/setting/waitwidget.dart';

class BackTemplate extends StatelessWidget {
  final BusinessCard cardInfo;
  final File? image;

  BackTemplate({
    super.key,
    required this.cardInfo,
    this.image,
  });


  Color hexToColor(String? hex, {Color fallback = Colors.white}) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return fallback;
    }
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
    final client = await HttpClientManager().createHttpClient();
    try {
      final response = await client.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (cardInfo.isTextEnabled == true && cardInfo.textPosition == 'above') ...[
            Text(
              cardInfo.customText ?? "",
              style: TextStyle(
                fontSize: 18,
                color: textColor,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],

          cardInfo.logoUrl != null
              ? FutureBuilder<bool>(
            future: checkFileExists(getFullImageUrl()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return WaitAnimationWidget();
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

          if (cardInfo.isTextEnabled == true && cardInfo.textPosition == 'below') ...[
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

