import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:url_launcher/url_launcher.dart';


class CardInfoWidget extends StatefulWidget {
  final BusinessCard businessCards;
  final String loginEmail;

  CardInfoWidget({
    super.key,
    required this.businessCards,
    required this.loginEmail
  });

  @override
  State<CardInfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<CardInfoWidget> {

  final TextEditingController _memoController = TextEditingController();

  Uri get _telUrl => Uri.parse('tel:${widget.businessCards.phone}');
  Uri get _smsUrl => Uri.parse('sms:${widget.businessCards.phone}');
  Uri get _emailUrl => Uri.parse('mailto:${widget.businessCards.email}');

  @override
  void initState() {
    super.initState();
    if (widget.businessCards != null) {
      _memoController.text = widget.businessCards.description?? '';
      _loadMemo();
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _openMaps() async {
    final String address = "${widget.businessCards.companyAddress}";
    final Uri appUrl = Uri.parse("geo:0,0?q=${Uri.encodeComponent(address)}");
    final Uri webUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}");

    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      _showSnackBar('맵을 열 수 없습니다.', isError: true);
    }
  }
  Future<void> _loadMemo() async {
    try {
      final card = {
        'cardNo': widget.businessCards.cardNo,
        'myEmail': widget.loginEmail,
        'userEmail': widget.businessCards.userEmail,
      };

      final memo = await CardModel().loadMemo(card);
      setState(() {
        _memoController.text = memo ?? '';
        widget.businessCards.description = memo;
      });
    } catch (e) {
      _showSnackBar("메모를 불러오는데 실패했습니다.", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      action: SnackBarAction(
        label: '확인',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // 메모 저장
  void _saveMemo(memo) async {

    print("memo: $memo");
    final card = {
      'cardNo': widget.businessCards.cardNo,
      'description': memo,
      'myEmail': widget.loginEmail,
      'userEmail': widget.businessCards.userEmail,
    };

    try {
      await CardModel().saveMemo(card);
      _showSnackBar("메모가 저장 되었습니다.");
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("메모 저장 실패. 다시 시도해주세요.", isError: true);
    }
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
                      _showSnackBar("전화를 걸 수 없습니다. 다시 시도해주세요.", isError: true);
                    }
                  },
                  icon: Image.asset('assets/icons/call.png', height: 30, width: 30,),
                ),
                IconButton(
                  onPressed: () async {
                    if (await canLaunchUrl(_smsUrl)) {
                      await launchUrl(_smsUrl);
                    } else {
                      _showSnackBar("문자를 보낼 수 없습니다. 다시 시도해주세요.", isError: true);
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
                  _showSnackBar("이메일을 실행할 수 없습니다. 다시 시도해주세요.", isError: true);
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
                // _showMapSelectionBottomSheet();
                _openMaps();
              },
              icon: Image.asset('assets/icons/location.png', height: 30, width: 30),
            ),
          ),
          widget.businessCards.userEmail != widget.loginEmail
              ? ListTile(
            title: Text('${widget.businessCards.description}', style: TextStyle(fontWeight: FontWeight.w600),),
            subtitle: Text("메모", style: TextStyle(color: Colors.grey),),
            trailing: IconButton(
              onPressed: (){
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Dialog(
                    child: SingleChildScrollView(
                      child: Container(
                        width: 350,
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('메모',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                            SizedBox(height: 10),
                            TextField(
                              controller: _memoController,
                              decoration: const InputDecoration(labelText: '메모'),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _saveMemo(_memoController.text);
                                  },
                                  child: widget.businessCards.description == null ? const Text('저장') : const Text('수정'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              icon: Image.asset('assets/icons/memo.png', height: 30, width: 30),
            ),
          )
              : SizedBox.shrink()
        ],
      ),

    );
  }
}
