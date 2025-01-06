import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'dart:io';

class No1Back extends StatefulWidget {
  final BusinessCard cardInfo;
  final File? image;

  const No1Back({
    super.key,
    required this.cardInfo,
    required this.image,
  });

  @override
  State<No1Back> createState() => _No1BackState();
}

class _No1BackState extends State<No1Back> {

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Image.file(
              widget.image!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            Text(
              widget.cardInfo.companyName ?? "",
              style: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight:FontWeight.w600),
            )
          ],
        )
    );
  }
}
