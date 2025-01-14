import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itdat/models/BusinessCard.dart';


class No1 extends StatelessWidget {
  final BusinessCard cardInfo;

  const No1({
    super.key,
    required this.cardInfo,

  });

    // 명함 텍스트 스타일
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
        color: cardInfo.backgroundColor
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
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      cardInfo.userName ?? "이름",
                      style: _buildTextStyle(
                        textColor: cardInfo.textColor,
                        fontFamily: cardInfo.font,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if(cardInfo.position != null && cardInfo.position!.isNotEmpty)
                      ...[
                        SizedBox(width: 10,),
                        Text(
                          cardInfo.position ?? "직급",
                          style: _buildTextStyle(
                            textColor: cardInfo.textColor,
                            fontFamily: cardInfo.font,
                            fontSize: 13,
                          ),
                        ),
                      ]
                  ]
              ),
              Text(
                cardInfo.department ?? "부서",
                style: _buildTextStyle(
                  textColor: cardInfo.textColor,
                  fontFamily: cardInfo.font,
                ),
              ),
              Text(
                cardInfo.phone ?? "핸드폰 번호",
                style: _buildTextStyle(
                  textColor: cardInfo.textColor,
                  fontFamily: cardInfo.font,
                ),
              ),
              Text(
                cardInfo.email ?? "이메일",
                style: _buildTextStyle(
                  textColor: cardInfo.textColor,
                  fontFamily: cardInfo.font,
                ),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                Text(
                  cardInfo.companyName ?? "회사 이름",
                  style: _buildTextStyle(
                    textColor: cardInfo.textColor,
                    fontFamily: cardInfo.font,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                cardInfo.companyAddress ?? "회사 주소",
                style: _buildTextStyle(
                  textColor: cardInfo.textColor,
                  fontFamily: cardInfo.font,
                ),
              ),
              if(cardInfo.companyNumber != null && cardInfo.companyNumber!.isNotEmpty)
                ...[
                  Text(
                    "T. ${cardInfo.companyNumber ?? "회사 번호"}",
                    style: _buildTextStyle(
                      textColor: cardInfo.textColor,
                      fontFamily: cardInfo.font,
                    ),
                  ),
                ],
              if(cardInfo.companyFax != null && cardInfo.companyFax!.isNotEmpty)
                ...[
                  Text(
                    "F. ${cardInfo.companyFax ?? "팩스번호"}",
                    style: _buildTextStyle(
                      textColor: cardInfo.textColor,
                      fontFamily: cardInfo.font,
                    ),
                  ),
                ]
            ],
          )
        ],
      ),
    );
  }
}

