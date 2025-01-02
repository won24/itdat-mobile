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
      body: ListView(
          children: [
            Padding(padding: EdgeInsets.only(left: 20)),
            ListTile(
              title: Text('${widget.businessCards.phone}', style: TextStyle(fontWeight: FontWeight.w600),),
              subtitle: Text("휴대전화", style: TextStyle(color: Colors.grey),),
              trailing: Wrap(
                spacing: 1.0,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset('assets/icons/call.png', height: 30, width: 30),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset('assets/icons/sms.png', height: 30, width: 30),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('${widget.businessCards.email}', style: TextStyle(fontWeight: FontWeight.w600),),
              subtitle: Text("이메일", style: TextStyle(color: Colors.grey),),
              trailing: IconButton(
                onPressed: () {},
                icon: Image.asset('assets/icons/mail.png', height: 30, width: 30),
              ),
            ),
            ListTile(
              title: Text('${widget.businessCards.companyAddress}', style: TextStyle(fontWeight: FontWeight.w600),),
              subtitle: Text("주소", style: TextStyle(color: Colors.grey),),
              trailing: IconButton(
                onPressed: () {},
                icon: Image.asset('assets/icons/location.png', height: 30, width: 30),
              ),
            ),
          ],
        ),

      );
  }
}
