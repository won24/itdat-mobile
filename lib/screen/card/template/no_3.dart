import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No3 extends StatelessWidget {
  final BusinessCard cardInfo;

  No3({
    super.key,
    required this.cardInfo
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade800,
                  child: Text(
                    cardInfo.userName?? "",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          cardInfo.userName ?? "",
                          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          cardInfo.position ?? "",
                          style: const TextStyle(fontSize: 7, color: Colors.white,),
                        ),
                      ]
                    ),
                    Text(
                      cardInfo.department ?? "",
                      style: const TextStyle(fontSize: 8, color: Colors.white54),
                    ),
                    Text(
                      cardInfo.phone ?? "",
                      style: const TextStyle(fontSize: 8, color: Colors.white54),
                    ),
                    Text(
                      cardInfo.email ?? "",
                      style: const TextStyle(fontSize: 8, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.grey),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  cardInfo.companyName ?? "",
                  style: const TextStyle(fontSize: 10, color: Colors.white,fontWeight: FontWeight.bold),
                ),
                Text(
                  cardInfo.companyAddress ?? "",
                  style: const TextStyle(fontSize: 8, color: Colors.white70),
                ),
                Text(
                  cardInfo.companyNumber ?? "",
                  style: const TextStyle(fontSize: 8, color: Colors.white70),
                ),
                Text(
                  cardInfo.companyFax ?? "",
                  style: const TextStyle(fontSize: 8, color: Colors.white70),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
