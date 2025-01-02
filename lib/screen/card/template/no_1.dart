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
          const SizedBox(height: 10,),
          Text(
            cardInfo.userName ?? "",
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10,),
          Text(
            cardInfo.companyName ?? "",
            style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight:FontWeight.w600),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${cardInfo.department ?? ""}  ',
                style: const TextStyle(color: Colors.black87),
              ),
              Text(
                cardInfo.position ?? "",
                style: const TextStyle(color: Colors.black87),
              ),
            ],
          ),
          Text(
            cardInfo.companyAddress ?? "",
            style: const TextStyle(color: Colors.black87),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            if(cardInfo.phone != null && cardInfo.phone!.isNotEmpty)
              ...[
                const Text("M.  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),),
                Text(
                  cardInfo.phone ?? "",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
              if(cardInfo.email != null && cardInfo.email!.isNotEmpty)
              ...[
                const SizedBox(width: 10,),
                const Text("E.  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),),
                Text(cardInfo.email ?? "",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            if(cardInfo.email != null && cardInfo.email!.isNotEmpty)
              ...[
                const Text("T.  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),),
                Text(
                  cardInfo.companyNumber ?? "",
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(width: 10,),
              ],
            if(cardInfo.email != null && cardInfo.email!.isNotEmpty)
            ...[
              const Text("F.  ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),),
              Text(
                cardInfo.companyFax ?? "",
                style: const TextStyle(color: Colors.black87),
              ),
            ]
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
