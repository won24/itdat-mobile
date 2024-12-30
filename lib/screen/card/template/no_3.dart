import 'package:flutter/material.dart';

class No3 extends StatelessWidget {
  final Map<String, dynamic> cardInfo;

  No3({
    super.key,
    required this.cardInfo
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade800,
                child: Text(
                  cardInfo["userName"]?[0] ?? "",
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardInfo["userName"] ?? "",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    cardInfo["position"] ?? "",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ],
          ),
          Divider(thickness: 1, color: Colors.grey),
          Text(
            cardInfo["companyName"] ?? "",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Text(
            cardInfo["phone"] ?? "",
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            cardInfo["email"] ?? "",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
