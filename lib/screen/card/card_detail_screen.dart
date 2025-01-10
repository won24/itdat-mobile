import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_1_back.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_2_back.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template/no_3_back.dart';
import 'package:itdat/widget/card/card_info_widget.dart';
import 'package:itdat/widget/card/history/history_widget.dart';
import 'package:itdat/widget/card/portfolio/portfolio_widget.dart';


class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {

  late String _userEmail;
  late Future<List<dynamic>> _businessCards;
  BusinessCard? cardInfo;
  int _selectedIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  // 로그인 이메일로 명함 데이터 가져오기
  Future<void> _loadEmail() async {
    final storage = FlutterSecureStorage();
    String? userEmail = await storage.read(key: 'email');

    if(userEmail != null){
      setState(() {
        _userEmail = userEmail;
        _businessCards = CardModel().getBusinessCard(_userEmail);
      });
    }else{
      setState(() {
        Navigator.pushReplacementNamed(context, '/');
      });
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
  Widget buildBusinessCardBack(BusinessCard cardInfo, List<BusinessCard> businessCards) {
    // "FRONT"일 경우 "BACK" 데이터를 찾아서 넘겨줌
    if (cardInfo.logoUrl == null) {
      var backCard = businessCards.firstWhere(
            (card) => card.cardNo == cardInfo.cardNo && card.cardSide == 'BACK',
      );
      print("-----------로고 주소1: ${cardInfo.logoUrl}");
      cardInfo.logoUrl = backCard.logoUrl;
      print("-----------로고 주소2: ${cardInfo.logoUrl}");
    }

    // "BACK"일 경우는 그 자체를 반환
    cardInfo.logoUrl = cardInfo.logoUrl;
    print("-----------로고 주소3: ${cardInfo.logoUrl}");

    return _buildBackCardWithLogo(cardInfo);
  }

  Widget _buildBackCardWithLogo(BusinessCard cardInfo) {
    if (cardInfo.logoUrl == null) {
      print("로고 경로가 없습니다.");
      cardInfo.logoUrl = "/assets/logoblack.png";
      switch (cardInfo.appTemplate) {
        case 'No1':
          return No1Back(cardInfo: cardInfo, image: File(cardInfo.logoUrl!));
        case 'No2':
          return No2Back(cardInfo: cardInfo, image: File(cardInfo.logoUrl!));
        case 'No3':
          return No3Back(cardInfo: cardInfo, image: File(cardInfo.logoUrl!));
        default:
          return No2Back(cardInfo: cardInfo, image: File(cardInfo.logoUrl!)); // 기본값
      }
    }

    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1Back(cardInfo: cardInfo, image: File(cardInfo.logoUrl!));
      case 'No2':
        return No2Back(cardInfo: cardInfo, image: File(cardInfo.logoUrl!));
      case 'No3':
        return No3Back(cardInfo: cardInfo, image: File(cardInfo.logoUrl!));
      default:
        return No2Back(cardInfo: cardInfo, image: File(cardInfo.logoUrl!)); // 기본값
    }
  }


  // 명함이 뒷면이 있다면 버튼을 눌러 보여짐
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

  bool canFlip(int cardNo, List<BusinessCard> businessCards) {
    bool hasBack = businessCards.any((card) => card.cardNo == cardNo && card.cardSide == 'BACK');
    return hasBack;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _businessCards,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('명함을 가져오는 중 오류가 발생했습니다.'));
                } else {
                  var businessCards = snapshot.data!
                      .map((data) => BusinessCard.fromJson(data)).toList();

                  // 명함 앞면만 렌더링 / 뒷면은 버튼 클릭 시 렌더링
                  var filteredCard = businessCards
                      .where((card) => card.cardSide == 'FRONT' && card.userEmail == _userEmail)
                      .toList() as BusinessCard;
                  cardInfo ??= filteredCard;

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: LayoutBuilder( // 부모의 크기를 알 수 있도록 LayoutBuilder 사용
                      builder: (context, constraints) {
                        // constraints.maxHeight를 사용하여 높이를 제한
                        double cardHeight = constraints.maxHeight; // 부모 높이에 맞게 설정

                        return SingleChildScrollView(
                          child: Container(
                            height: cardHeight, // 높이를 명시적으로 설정
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _isFlipped
                                    ? buildBusinessCardBack(filteredCard, businessCards)
                                    : buildBusinessCard(filteredCard),
                                if (canFlip(filteredCard.cardNo!, businessCards))
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: renderFlipButton(),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
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
                        ? CardInfoWidget(businessCards: cardInfo!)
                        : _selectedIndex == 1
                        ? PortfolioWidget(currentUserEmail: _userEmail,cardUserEmail: cardInfo!.userEmail,)
                        : HistoryWidget(),
                  ),
                ]
            ),
          ),
        ],
      ),
    );
  }
}
