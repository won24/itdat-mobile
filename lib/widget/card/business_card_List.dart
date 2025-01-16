import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/widget/nfc/nfcWrite.dart';

import '../setting/waitwidget.dart'; // NfcWritePage import 추가

class BusinessCardList extends StatefulWidget {
  final String userEmail;

  const BusinessCardList({
    super.key,
    required this.userEmail
  });

  @override
  State<BusinessCardList> createState() => _BusinessCardWidgetState();
}

class _BusinessCardWidgetState extends State<BusinessCardList> {
  late Future<dynamic> _businessCards;

  @override
  void initState() {
    super.initState();
    _businessCards = CardModel().getBusinessCard(widget.userEmail);
  }

  // 명함 템플릿
  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'No3':
        return No3(cardInfo: cardInfo);
      default:
        return No1(cardInfo: cardInfo); // 기본값
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _businessCards,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: WaitAnimationWidget());
        } else if (snapshot.hasError) {
          return  Center(child: Text(AppLocalizations.of(context)!.errorFetchingCards));
        } else if (!snapshot.hasData || snapshot.data.isEmpty) {
          return  Center(child: Text(AppLocalizations.of(context)!.noCards));
        } else {
          var businessCards = snapshot.data;

          return ListView.builder(
            itemCount: businessCards.length,
            itemBuilder: (context, index) {
              var card = businessCards[index];
              BusinessCard cardInfo = BusinessCard(
                 //cardId: card['cardId'],
                  appTemplate: card['appTemplate'],
                  userName: card['userName'],
                  phone: card['phone'],
                  email: card['email'],
                  companyName: card['companyName'],
                  companyNumber: card['companyNumber'],
                  companyAddress: card['companyAddress'],
                  companyFax: card['companyFax'],
                  department: card['department'],
                  position: card['position'],
                  userEmail: card['userEmail'],
                  cardNo: card['cardNo'],
                  cardSide: card['cardSide'],
                  logoUrl: card['logoUrl'],
                  isPublic: card['isPublic'],
              );
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NfcWritePage(cardInfo: cardInfo.toJson()),
                    ),
                  );
                },
                child: Transform.scale(
                  scale: 0.9,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: buildBusinessCard(cardInfo),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}