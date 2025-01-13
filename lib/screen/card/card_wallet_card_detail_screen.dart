import 'dart:io';
import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/screen/card/expanded_card_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_1_back.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_2_back.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template/no_3_back.dart';
import 'package:itdat/widget/card/card_info_widget.dart';
import 'package:itdat/widget/card/history/history_widget.dart';
import 'package:itdat/widget/card/portfolio/portfolio_widget.dart';


class CardWalletCardDetailScreen extends StatefulWidget {
  final List<dynamic> cardInfo;
  final String loginUserEmail;

  const CardWalletCardDetailScreen({
    super.key,
    required this.cardInfo,
    required this.loginUserEmail,
  });

  @override
  State<CardWalletCardDetailScreen> createState() => _CardWalletCardDetailScreenState();
}

class _CardWalletCardDetailScreenState extends State<CardWalletCardDetailScreen> {

  int _selectedIndex = 0;
  bool _isFlipped = false;
  BusinessCard? cardInfo;
  late BusinessCard frontCard;
  BusinessCard? backCard; // 있을 수도 없을 수도

  @override
  void initState() {
    super.initState();

    // 앞면/뒷면 정보 따로 할당
    for (var card in widget.cardInfo) {
      if (card.cardSide == 'FRONT') {
        frontCard = card;
      } else if (card.cardSide == 'BACK') {
        backCard = card;
      }
    }
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
        return No2(cardInfo: cardInfo); // 기본값
    }
  }

  // 명함 뒷장 템플릿
  Widget buildBackCardWithLogo(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1Back(cardInfo: cardInfo, image: File(""));
      case 'No2':
        return No2Back(cardInfo: cardInfo, image: File(""));
      case 'No3':
        return No3Back(cardInfo: cardInfo, image: File(""));
      default:
        return No2Back(cardInfo: cardInfo, image: File("")); // 기본값
    }
  }


  // 명함이 뒷면이 있다면 버튼을 눌러서 보기
  Widget renderFlipButton() {
    return IconButton(
      icon: Icon(Icons.change_circle_rounded, size: 32, color: Theme.of(context).iconTheme.color),
      onPressed: () {
        setState(() {
          _isFlipped = !_isFlipped;
        });
      },
    );
  }

  bool canFlip() {
    return backCard != null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;

                  final cardWidth = screenWidth * 0.9; // 화면 너비의 90%
                  final cardHeight = screenHeight * 0.3; // 화면 높이의 30%

                  return Container(
                    width: cardWidth,
                    height: cardHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExpandedCardScreen(
                                  cardInfo: frontCard,
                                  backCard: backCard,
                                ),
                              ),
                            );
                          },
                          child: _isFlipped
                              ? buildBackCardWithLogo(backCard!)
                              : buildBusinessCard(frontCard),
                        ),
                        if (canFlip())
                          Positioned(
                            top: 10,
                            right: 10,
                            child: renderFlipButton(),
                          ),
                      ],
                    ),
                  );
                }
              )
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                        child: const Text("연락처"),
                      ),
                      const Text("|"),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 1;
                          });
                        },
                        child: const Text("포트폴리오"),
                      ),
                      const Text("|"),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 2;
                          });
                        },
                        child: const Text("히스토리"),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _selectedIndex == 0
                        ? CardInfoWidget(businessCards: frontCard)
                        : _selectedIndex == 1
                        ? PortfolioWidget(loginUserEmail: widget.loginUserEmail,cardUserEmail: frontCard.userEmail)
                        : HistoryWidget(loginUserEmail: widget.loginUserEmail,cardUserEmail: frontCard.userEmail),
                  ),
                ]
              ),
            ),
          ],
        ),
      )
    );
  }
}
