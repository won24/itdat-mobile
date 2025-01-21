import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/screen/card/expanded_card_screen.dart';
import 'package:itdat/screen/card/template/back_template.dart';
import 'package:itdat/screen/card/template/business/no_1.dart';
import 'package:itdat/screen/card/template/business/no_2.dart';
import 'package:itdat/screen/card/template/personal/no_1.dart';
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
  BusinessCard? backCard;

  @override
  void initState() {
    super.initState();

    if (widget.cardInfo.isEmpty) {
      throw Exception("명함 데이터가 비어 있습니다.");
    }

    for (var card in widget.cardInfo) {
      if (card.cardSide == 'FRONT' || card.cardSide == null) {
        frontCard = card;
      } else if (card.cardSide == 'BACK') {
        backCard = card;
      }
    }
  }


  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'PersonalNo1':
        return PersonalNo1(cardInfo: cardInfo);
      default:
        return No1(cardInfo: cardInfo);
    }
  }


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
    if (frontCard == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("명함 상세 정보")),
        body: Center(
          child: Text(
            "명함 데이터가 없습니다.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("명함 상세 정보")),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      final screenHeight = MediaQuery.of(context).size.height;

                      final cardWidth = screenWidth * 0.9;
                      final cardHeight = screenHeight * 0.3;
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
                                      cardInfo: frontCard!,
                                      backCard: backCard,
                                    ),
                                  ),
                                );
                              },
                              child: _isFlipped
                                  ? BackTemplate(cardInfo: backCard!)
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
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
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
                  child: Text(
                    "연락처",
                    style: TextStyle(
                        fontWeight: _selectedIndex == 0? FontWeight.w900: null,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                    ),
                  ),
                ),
                Text("|"),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Text(
                    "포트폴리오",
                    style: TextStyle(
                        fontWeight: _selectedIndex == 1? FontWeight.w900: null,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                    ),),
                ),
                Text("|"),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: Text(
                    "히스토리",
                    style: TextStyle(
                        fontWeight: _selectedIndex == 2? FontWeight.w900: null,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: _selectedIndex == 0
                  ? CardInfoWidget(businessCards: frontCard, loginEmail: widget.loginUserEmail,)
                  : _selectedIndex == 1
                  ? PortfolioWidget(
                loginUserEmail: widget.loginUserEmail,
                cardUserEmail: frontCard.userEmail,
              )
                  : HistoryWidget(
                loginUserEmail: widget.loginUserEmail,
                cardUserEmail: frontCard.userEmail,
              ),
            ),
          ],
        )
      ),
    );
  }
}
