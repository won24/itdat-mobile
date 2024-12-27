import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PreviewScreen extends StatelessWidget {
  final String svgUrl;
  const PreviewScreen({
    super.key,
    required this.svgUrl  
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.network(svgUrl),
      ),
    );
  }
}
