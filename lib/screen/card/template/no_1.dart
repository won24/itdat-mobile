import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No1 extends StatelessWidget {
  final BusinessCard cardInfo;

  const No1({
    super.key,
    required this.cardInfo,

  });

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
                      style: TextStyle(fontSize: 23,
                          color: cardInfo.textColor,
                          fontWeight: FontWeight.bold),
                    ),
                    if(cardInfo.position != null && cardInfo.position!.isNotEmpty)
                      ...[
                        SizedBox(width: 10,),
                        Text(
                          cardInfo.position ?? "직급",
                          style: TextStyle(
                            fontSize: 13, color: cardInfo.textColor),
                        ),
                      ]
                  ]
              ),
              Text(
                cardInfo.department ?? "부서",
                style: TextStyle(color: cardInfo.textColor),
              ),
              Text(
                cardInfo.phone ?? "핸드폰 번호",
                style: TextStyle(color: cardInfo.textColor),
              ),
              Text(
                cardInfo.email ?? "이메일",
                style: TextStyle(color: cardInfo.textColor),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
                Text(
                  cardInfo.companyName ?? "회사 이름",
                  style: TextStyle(
                    fontSize: 18,
                    color: cardInfo.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                cardInfo.companyAddress ?? "회사 주소",
                style: TextStyle(color: cardInfo.textColor),
              ),
              if(cardInfo.companyNumber != null && cardInfo.companyNumber!.isNotEmpty)
                ...[
                  Text(
                    "T. ${cardInfo.companyNumber ?? "회사 번호"}",
                    style: TextStyle(color: cardInfo.textColor),
                  ),
                ],
              if(cardInfo.companyFax != null && cardInfo.companyFax!.isNotEmpty)
                ...[
                  Text(
                    "F. ${cardInfo.companyFax ?? "팩스번호"}",
                    style: TextStyle(color: cardInfo.textColor),
                  ),
                ]
            ],
          )
        ],
      ),
    );
  }
}

