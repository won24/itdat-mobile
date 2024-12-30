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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cardInfo.userName ?? "",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            cardInfo.phone ?? "",
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            cardInfo.email ?? "",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 16),
          Text(
            cardInfo.companyName ?? "",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            cardInfo.companyAddress ?? "",
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            cardInfo.companyFax ?? "",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
