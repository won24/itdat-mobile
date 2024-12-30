import 'package:flutter/material.dart';

class No2 extends StatelessWidget {
  final Map<String, dynamic> cardInfo;

  No2({
    super.key,
    required this.cardInfo
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cardInfo["userName"] ?? "",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(cardInfo["phone"] ?? ""),
          Text(cardInfo["email"] ?? ""),
          Divider(thickness: 1, color: Colors.grey.shade300),
          Text(
            cardInfo["companyName"] ?? "",
            style: TextStyle(fontSize: 18),
          ),
          Text(cardInfo["companyAddress"] ?? ""),
          Text(cardInfo["companyFax"] ?? ""),
        ],
      ),
    );
  }
}
