import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No2 extends StatelessWidget {
  final BusinessCard cardInfo;

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
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  cardInfo.companyName ?? "",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold,),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(top: 10)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(cardInfo.position ?? "",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      cardInfo.userName ?? "",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(thickness: 1, color: Colors.grey),
                Row(
                  children: [
                    Text(cardInfo.phone ?? ""),
                    Text(cardInfo.email ?? ""),
                  ],
                ),
                Row(
                  children: [
                    Text(cardInfo.companyNumber ?? ""),
                     Text(cardInfo.companyFax?? ""),
                  ],
                ),
                Text(cardInfo.companyAddress ?? ""),
              ],
            )
          ],
        ),
      ),
    );
  }
}
