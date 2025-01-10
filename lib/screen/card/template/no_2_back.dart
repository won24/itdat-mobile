import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No2Back extends StatelessWidget {
  final BusinessCard cardInfo;
  final File? image;

  No2Back({
    super.key,
    required this.cardInfo,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}