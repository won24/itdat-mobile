import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/business/no_1.dart';
import 'package:itdat/screen/card/template/back_template.dart';
import 'package:itdat/screen/card/template/business/no_2.dart';
import 'package:itdat/screen/card/template/business/no_3.dart';
import 'package:itdat/screen/card/template/personal/no_1.dart';
import 'package:itdat/screen/card/template/personal/no_2.dart';

import 'edit_from-screen.dart';

class ExpandedCardScreen extends StatefulWidget {
  final BusinessCard cardInfo;
  final BusinessCard? backCard;

  ExpandedCardScreen({
    Key? key,
    required this.cardInfo,
    required this.backCard,
  }) : super(key: key);

  @override
  _ExpandedCardScreenState createState() => _ExpandedCardScreenState();
}

class _ExpandedCardScreenState extends State<ExpandedCardScreen> {
  late BusinessCard cardInfo;
  late BusinessCard? backCard;
  final CardModel cardModel = CardModel();

  @override
  void initState() {
    super.initState();
    cardInfo = widget.cardInfo;
    backCard = widget.backCard;
  }

  // 앞면 렌더링
  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'No3':
        return No3(cardInfo: cardInfo);
      case 'PersonalNo1':
        return PersonalNo1(cardInfo: cardInfo);
      case 'PersonalNo2' :
        return PersonalNo2(cardInfo: cardInfo);
      default:
        return No1(cardInfo: cardInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userBusinessCard(cardInfo.userName.toString())),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditFormScreen(cardInfo: cardInfo),
                ),
              );
              if (result != null && result is BusinessCard) {
                setState(() {
                  cardInfo = result;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: InteractiveViewer(
        minScale: 1.0,
        maxScale: 3.0,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildBusinessCard(cardInfo),
              if (backCard != null) ...[
                const SizedBox(height: 20),
                BackTemplate(cardInfo: backCard!, frontSideTemplate: cardInfo.appTemplate!)
              ],
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteBusinessCard),
          content: Text(AppLocalizations.of(context)!.confirmDeleteBusinessCard),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () => _deleteCard(context),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCard(BuildContext context) async {
    try {
      bool result = await cardModel.deleteCard(cardInfo.cardNo!);
      if (result) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(true);
      } else {
        _showErrorSnackBar(context, AppLocalizations.of(context)!.failedToDeleteBusinessCard);
      }
    } catch (e) {
      print("Error deleting card: $e");
      _showErrorSnackBar(context, AppLocalizations.of(context)!.errorOccurred(e.toString()));
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}