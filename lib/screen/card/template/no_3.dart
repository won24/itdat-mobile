import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No3 extends StatelessWidget {
  final BusinessCard cardInfo;

  const No3({
    super.key,
    required this.cardInfo
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 240,
      decoration: const BoxDecoration(
        color: Colors.black,
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
                      cardInfo.userName ?? "",
                      style: const TextStyle(fontSize: 23,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    if(cardInfo.email != null && cardInfo.email!.isNotEmpty)
                      ...[
                        SizedBox(width: 10,),
                        Text(
                          cardInfo.position ?? "",
                          style: const TextStyle(
                            fontSize: 13, color: Colors.white,),
                        ),
                      ]
                  ]
              ),
              Text(
                cardInfo.department ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                cardInfo.phone ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                cardInfo.email ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.grey),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cardInfo.companyName ?? "",
                style: const TextStyle(fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                cardInfo.companyAddress ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              if(cardInfo.companyNumber != null &&
                  cardInfo.companyNumber!.isNotEmpty)
                ...[
                  Text(
                    "T. ${cardInfo.companyNumber ?? " "}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              if(cardInfo.companyFax != null &&
                  cardInfo.companyFax!.isNotEmpty)
                ...[
                  Text(
                    "F. ${cardInfo.companyFax ?? " "}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ]
            ],
          )
        ],
      ),
    );
  }
}

