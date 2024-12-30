import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template_selection_screen.dart';

class BusinessCardWidget extends StatefulWidget {
  final String userId;

  const BusinessCardWidget({
    super.key,
    required this.userId
  });

  @override
  State<BusinessCardWidget> createState() => _BusinessCardWidgetState();
}

class _BusinessCardWidgetState extends State<BusinessCardWidget> {
  late Future<dynamic> _businessCards;
  late BusinessCard _cardInfo;

  @override
  void initState() {
    super.initState();
    _businessCards = CardModel().getBusinessCard(widget.userId);
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
    return FutureBuilder<dynamic>(
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
                    builder: (context) => TemplateSelectionScreen(userId: widget.userId),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 64),
            ),
          );
        } else {
          var businessCards = snapshot.data;

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: businessCards.length + 1,
                  itemBuilder: (context, index) {
                    // 항상 마지막에 명함 추가 버튼
                    if (index == businessCards.length) {
                      return Center(
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TemplateSelectionScreen(userId: widget.userId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, size: 64),
                        ),
                      );
                    } else {
                      var card = businessCards[index];
                      _cardInfo = BusinessCard(
                          appTemplate: card['appTemplate'],
                          email: card['email'],
                          companyName: card['companyName'],
                          companyNumber: card['companyNumber'],
                          companyAddress: card['companyAddress'],
                          companyFax: card['companyFax'],
                          department: card['department'],
                          position: card['position'],
                          userId: card['userId']
                      );

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Container(
                                  width: double.infinity,
                                  child: buildBusinessCard(_cardInfo),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}