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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(255, 249, 163, 1), Color.fromRGBO(165, 255, 229, 1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            cardInfo.userName ?? "",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            cardInfo.companyName ?? "",
            style: const TextStyle(fontSize: 7, color: Colors.black87),
          ),
          Row(
            children: [
              Text(
                cardInfo.position ?? "",
                style: const TextStyle(fontSize: 7,color: Colors.black87),
              ),
              Text(
                cardInfo.department ?? "",
                style: const TextStyle(fontSize: 7,color: Colors.black87),
              ),
            ],
          ),
          Text(
            cardInfo.companyAddress ?? "",
            style: const TextStyle(fontSize: 7,color: Colors.black87),
          ),
          Row(
            children: [
              Text("M. "),
              Text(
                cardInfo.phone ?? "",
                style: const TextStyle(fontSize: 7,color: Colors.black87),
              ),
              Text("E. "),
              Text(
                cardInfo.email ?? "",
                style: const TextStyle(fontSize: 7,color: Colors.black87),
              ),
            ],
          ),
          Row(
            children: [
              Text("T. ",),
              Text(
                cardInfo.companyNumber ?? "",
                style: const TextStyle(fontSize: 7,color: Colors.black87),
              ),
              Text("F. "),
              Text(
                cardInfo.companyFax ?? "",
                style: const TextStyle(fontSize: 7,color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
