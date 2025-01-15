import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/nfc_model.dart';

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
      _memoController.text = widget.businessCards.description ?? '';
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
      _showSnackBar(AppLocalizations.of(context)!.cannotOpenMap, isError: true);
    }
  }

  Future<void> _loadMemo() async {
    try {
      final card = {
        'cardNo': widget.businessCards.cardNo,
        'myEmail': widget.loginEmail,
        'userEmail': widget.businessCards.userEmail,
      };

      final memo = await NfcModel().loadMemo(card);
      setState(() {
        _memoController.text = memo ?? '';
        widget.businessCards.description = memo;
      });
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.failedToLoadMemo, isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.confirm,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _saveMemo(memo) async {
    final card = {
      'cardNo': widget.businessCards.cardNo,
      'description': memo,
      'myEmail': widget.loginEmail,
      'userEmail':  widget.businessCards.userEmail,
    };

    try {
      await NfcModel().saveMemo(card);
      _showSnackBar(AppLocalizations.of(context)!.memoSaved);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar(AppLocalizations.of(context)!.failedToSaveMemo, isError: true);
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
            subtitle: Text(AppLocalizations.of(context)!.mobilePhone, style: TextStyle(color: Colors.grey),),
            trailing: Wrap(
              spacing: 1.0,
              children: [
                IconButton(
                  onPressed: () async {
                    if (await canLaunchUrl(_telUrl)) {
                      await launchUrl(_telUrl);
                    } else {
                      _showSnackBar(AppLocalizations.of(context)!.cannotMakeCall, isError: true);
                    }
                  },
                  icon: Image.asset('assets/icons/call.png', height: 30, width: 30),
                ),
                IconButton(
                  onPressed: () async {
                    if (await canLaunchUrl(_smsUrl)) {
                      await launchUrl(_smsUrl);
                    } else {
                      _showSnackBar(AppLocalizations.of(context)!.cannotSendSMS, isError: true);
                    }
                  },
                  icon: Image.asset('assets/icons/sms.png', height: 30, width: 30),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('${widget.businessCards.email}', style: TextStyle(fontWeight: FontWeight.w600),),
            subtitle: Text(AppLocalizations.of(context)!.email, style: TextStyle(color: Colors.grey),),
            trailing: IconButton(
              onPressed: () async {
                if (await canLaunchUrl(_emailUrl)) {
                  await launchUrl(_emailUrl);
                } else {
                  _showSnackBar(AppLocalizations.of(context)!.cannotOpenEmail, isError: true);
                }
              },
              icon: Image.asset('assets/icons/mail.png', height: 30, width: 30),
            ),
          ),
          ListTile(
            title: Text('${widget.businessCards.companyAddress}', style: TextStyle(fontWeight: FontWeight.w600),),
            subtitle: Text(AppLocalizations.of(context)!.address, style: TextStyle(color: Colors.grey),),
            trailing: IconButton(
              onPressed: _openMaps,
              icon: Image.asset('assets/icons/location.png', height: 30, width: 30),
            ),
          ),
          widget.businessCards.userEmail != widget.loginEmail
              ? ListTile(
            title: Text('${widget.businessCards.description}', style: TextStyle(fontWeight: FontWeight.w600),),
            subtitle: Text(AppLocalizations.of(context)!.memo, style: TextStyle(color: Colors.grey),),
            trailing: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: SingleChildScrollView(
                        child: Container(
                          width: 350,
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of(context)!.memo,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              TextField(
                                controller: _memoController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: AppLocalizations.of(context)!.enterMemo,
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                child: Text(AppLocalizations.of(context)!.save),
                                onPressed: () {
                                  _saveMemo(_memoController.text);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              icon: Image.asset('assets/icons/memo.png', height: 30, width: 30),
            ),
          )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}