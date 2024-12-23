import 'package:flutter/material.dart';

class PortfolioWidget extends StatefulWidget {
  const PortfolioWidget({super.key});

  @override
  State<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends State<PortfolioWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("포트폴리오"),
    );
  }
}
