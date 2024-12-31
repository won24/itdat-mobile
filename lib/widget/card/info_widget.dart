import 'package:flutter/material.dart';

class InfoWidget extends StatefulWidget {

  const InfoWidget({
    super.key,
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
            TextField(
            )
          ],
        ),
      )
    );
  }
}
