import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template_selection_screen.dart';
import 'package:itdat/widget/card/info_widget.dart';
import 'package:itdat/widget/card/portfolio_widget.dart';
import 'package:itdat/widget/card/history_widget.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardScreen> {

  final userEmail = "sksksk4502@naver.com";
  late Future<dynamic> _businessCards;
  BusinessCard? selectedCardInfo;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _businessCards = CardModel().getBusinessCard(userEmail);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 380,
            height: 238,
            child: FutureBuilder<dynamic>(
              future: _businessCards,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('명함을 가져오는 중 오류가 발생했습니다.'));
                } else if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return Center(
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TemplateSelectionScreen(userEmail: userEmail),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, size: 64),
                    ),
                  );
                } else {
                  var businessCards = snapshot.data;

                  return PageView.builder(
                    itemCount: businessCards.length + 1,
                    onPageChanged: (index) {
                      if (index < businessCards.length) {
                        setState(() {
                          var card = businessCards[index];
                          selectedCardInfo = BusinessCard(
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
                          );
                        });
                      }
                    },
                    itemBuilder: (context, index) {
                      if (index == businessCards.length) {
                        return Center(
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TemplateSelectionScreen(userEmail: userEmail),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 64),
                          ),
                        );
                      } else {
                        var card = businessCards[index];
                        var cardInfo = BusinessCard(
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
                          cardSide: card['cardSide']
                        );

                        if (selectedCardInfo == null) {
                          selectedCardInfo = cardInfo;
                        }

                        return Transform.scale(
                          scale: 0.95,
                          child: Container(
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: buildBusinessCard(cardInfo),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),

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
            child: _selectedIndex == 0 && selectedCardInfo != null
                ? InfoWidget(businessCards: selectedCardInfo!)
                : _selectedIndex == 1
                ? const PortfolioWidget()
                : const HistoryWidget(),
          ),
        ],
      ),
    );
  }
}
