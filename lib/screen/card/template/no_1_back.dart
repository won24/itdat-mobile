import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No1Back extends StatelessWidget {
  final BusinessCard cardInfo;
  
  const No1Back({
    super.key,
    required this.cardInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      height: 230,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(255, 248, 194, 1.0), Color.fromRGBO(
              203, 255, 239, 1.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          cardInfo.companyName ?? "",
          style: const TextStyle(fontSize: 30, color: Colors.black87, fontWeight:FontWeight.w600),
        ),
      ],
    )
    );
  }
}
