import 'dart:io';

import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';

class No3Back extends StatelessWidget {
  final BusinessCard cardInfo;
  final File? image;

  No3Back({
    super.key,
    required this.cardInfo,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
