import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WaitAnimationWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const WaitAnimationWidget({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.8,
        child: Lottie.asset(
          'assets/waitAnime.json',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}