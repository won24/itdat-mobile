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

    // 명함 데이터가 없는 경우 예외 처리
    if (widget.cardInfo.isEmpty) {
      throw Exception("명함 데이터가 비어 있습니다.");
    }

    // 앞면/뒷면 정보 초기화
    for (var card in widget.cardInfo) {
      if (card.cardSide == 'FRONT' || card.cardSide == null) {
        frontCard = card; // `null`일 경우 기본적으로 `frontCard`로 설정
      } else if (card.cardSide == 'BACK') {
        backCard = card;
      }
    }

    // 기본값 설정 (frontCard가 없을 경우)
    frontCard ??= BusinessCard(
      appTemplate: 'Default',
      userName: '이름 없음',
      phone: '전화번호 없음',
      email: '이메일 없음',
      companyName: '회사 없음',
      companyNumber: '사업자 번호 없음',
      companyAddress: '주소 없음',
      companyFax: '팩스 없음',
      department: '부서 없음',
      position: '직급 없음',
      userEmail: widget.loginUserEmail,
      cardNo: 0,
      cardSide: 'FRONT',
      logoUrl: '',
      isPublic: false,
    );
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
      body: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
                                cardInfo: frontCard!,
                                backCard: backCard,
                              ),
                            ),
                          );
                        },
                        child: _isFlipped
                            ? buildBackCardWithLogo(backCard!)
                            : buildBusinessCard(frontCard!),
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
          const SizedBox(height: 16),
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
                ? CardInfoWidget(businessCards: frontCard!, loginEmail: widget.loginUserEmail,)
                : _selectedIndex == 1
                ? PortfolioWidget(
              loginUserEmail: widget.loginUserEmail,
              cardUserEmail: frontCard!.userEmail,
            )
                : HistoryWidget(
              loginUserEmail: widget.loginUserEmail,
              cardUserEmail: frontCard!.userEmail,
            ),
          ),
        ],
      ),
    );
  }
}
