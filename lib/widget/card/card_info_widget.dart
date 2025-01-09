import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:url_launcher/url_launcher.dart';

class CardInfoWidget extends StatefulWidget {
  final BusinessCard businessCards;

  const CardInfoWidget({
    super.key,
    required this.businessCards,
  });

  @override
  State<CardInfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<CardInfoWidget> {

  Uri get _telUrl => Uri.parse('tel:${widget.businessCards.phone}');
  Uri get _smsUrl => Uri.parse('sms:${widget.businessCards.phone}');
  Uri get _emailUrl => Uri.parse('mailto:${widget.businessCards.email}');

  Future<void> _openGoogleMaps() async {
    final String address = "${widget.businessCards.companyAddress}";
    final Uri appUrl = Uri.parse("geo:0,0?q=${Uri.encodeComponent(address)}");
    final Uri webUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBarError('구글 맵을 열 수 없습니다.');
    }
  }

  Future<void> _openNaverMap() async {
    final Uri appUrl = Uri.parse("nmap://search?query=${widget.businessCards.companyAddress}");
    final Uri webUrl = Uri.parse("https://map.naver.com/v5/search/${widget.businessCards.companyAddress}");

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBarError("네이버 지도를 열 수 없습니다.");
    }
  }

  Future<void> _openKakaoMap() async {

    final Uri appUrl = Uri.parse("kakaomap://search?q=${widget.businessCards.companyAddress}");
    final Uri webSearchUrl = Uri.parse("https://map.kakao.com/link/search/${widget.businessCards.companyAddress}");


    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webSearchUrl)) {
        await launchUrl(webSearchUrl, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBarError("카카오맵을 열 수 없습니다.");
    }
  }

  void _showSnackBarError(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: '확인',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showMapSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "어플 선택",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _openGoogleMaps();
                  },
                  child: Column(
                    children: [
                      Image.asset('assets/icons/google_map_icon.png', width: 50, height: 50),
                      SizedBox(height: 10),
                      Text('Google'),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _openNaverMap();
                  },
                  child: Column(
                    children: [
                      Image.asset('assets/icons/naver_map_icon.png', width: 50, height: 50),
                      SizedBox(height: 10),
                      Text('Naver'),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _openKakaoMap();
                  },
                  child: Column(
                    children: [
                      Image.asset('assets/icons/kakao_map_icon.png', width: 50, height: 50),
                      SizedBox(height: 10),
                      Text('Kakao'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        )
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
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
              onPressed: (){
                _showMapSelectionBottomSheet();
              },
              icon: Image.asset('assets/icons/location.png', height: 30, width: 30),
            ),
          ),
        ],
        ),

      );
  }
}
