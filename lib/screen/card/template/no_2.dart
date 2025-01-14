import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itdat/models/BusinessCard.dart';

class No2 extends StatelessWidget {
  final BusinessCard cardInfo;

  No2({
    super.key,
    required this.cardInfo,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 240,
      decoration: BoxDecoration(
        color: cardInfo.backgroundColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            children: [
              Text(
                cardInfo.companyName ?? "",
                style: _buildTextStyle(
                  textColor: cardInfo.textColor,
                  fontFamily: cardInfo.font,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
                      textColor: cardInfo.textColor,
                      fontFamily: cardInfo.font,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    cardInfo.userName ?? "",
                    style: _buildTextStyle(
                      textColor: cardInfo.textColor,
                      fontFamily: cardInfo.font,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                cardInfo.department ?? "",
                style: _buildTextStyle(
                  textColor: cardInfo.textColor,
                  fontFamily: cardInfo.font,
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
                      textColor: cardInfo.textColor,
                      fontFamily: cardInfo.font,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    cardInfo.phone ?? "",
                    style: _buildTextStyle(
                      textColor: cardInfo.textColor,
                      fontFamily: cardInfo.font,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (cardInfo.email != null && cardInfo.email!.isNotEmpty) ...[
                    Text(
                      "E. ",
                      style: _buildTextStyle(
                        textColor: cardInfo.textColor,
                        fontFamily: cardInfo.font,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cardInfo.email ?? "",
                      style: _buildTextStyle(
                        textColor: cardInfo.textColor,
                        fontFamily: cardInfo.font,
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
                        textColor: cardInfo.textColor,
                        fontFamily: cardInfo.font,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cardInfo.companyNumber ?? "",
                      style: _buildTextStyle(
                        textColor: cardInfo.textColor,
                        fontFamily: cardInfo.font,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (cardInfo.companyFax != null &&
                      cardInfo.companyFax!.isNotEmpty) ...[
                    Text(
                      "F. ",
                      style: _buildTextStyle(
                        textColor: cardInfo.textColor,
                        fontFamily: cardInfo.font,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cardInfo.companyFax ?? "",
                      style: _buildTextStyle(
                        textColor: cardInfo.textColor,
                        fontFamily: cardInfo.font,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                cardInfo.companyAddress ?? "",
                style: _buildTextStyle(
                  textColor: cardInfo.textColor,
                  fontFamily: cardInfo.font,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
