import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class InfoWidget extends StatefulWidget {
  final BusinessCard businessCards;

  const InfoWidget({
    super.key,
    required this.businessCards,
  });

  @override
  State<InfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text("휴대전화", style: TextStyle(color: Colors.grey),),
                Text('${widget.businessCards.phone}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),)
              ],
            )
          ],
        ),
      )
    );
  }
}
