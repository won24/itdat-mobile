import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Uri get _telUrl => Uri.parse('tel:${widget.businessCards.phone}');
  Uri get _smsUrl => Uri.parse('sms:${widget.businessCards.phone}');
  Uri get _emailUrl => Uri.parse('mailto:${widget.businessCards.email}');

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
                    onPressed: () async {
                      if (await canLaunchUrl(_telUrl)) {
                        await launchUrl(_telUrl);
                      } else {
                        throw '전화 실행 불가 $_telUrl';
                      }
                    },
                    icon: Image.asset('assets/icons/call.png', height: 30, width: 30),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (await canLaunchUrl(_smsUrl)) {
                        await launchUrl(_smsUrl);
                      } else {
                        throw '문자 실행 불가 $_smsUrl';
                      }
                    },
                    icon: Image.asset('assets/icons/sms.png', height: 30, width: 30),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('${widget.businessCards.email}', style: TextStyle(fontWeight: FontWeight.w600),),
              subtitle: Text("이메일", style: TextStyle(color: Colors.grey),),
              trailing: IconButton(
                onPressed: () async {
                  if (await canLaunchUrl(_emailUrl)) {
                    await launchUrl(_emailUrl);
                  } else {
                    throw '이메일 실행 불가 $_emailUrl';
                  }
                },
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
