import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template_selection_screen.dart';

class BusinessCardWidget extends StatefulWidget {
  final Future<dynamic> businessCards;

  const BusinessCardWidget({
    super.key,
    required this.businessCards,
  });

  @override
  State<BusinessCardWidget> createState() => _BusinessCardWidgetState();
}

class _BusinessCardWidgetState extends State<BusinessCardWidget> {
  late BusinessCard _cardInfo;


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
      future: widget.businessCards,
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
                    builder: (context) => TemplateSelectionScreen(userEmail: snapshot.data['userEmail']),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 64),
            ),
          );
        } else {
          var businessCards = snapshot.data;

          return SafeArea(
              child: Column(
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
                                    builder: (context) => TemplateSelectionScreen(userEmail: snapshot.data['userEmail']),
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
                              userName: card['userName'],
                              phone: card['phone'],
                              email: card['email'],
                              companyName: card['companyName'],
                              companyNumber: card['companyNumber'],
                              companyAddress: card['companyAddress'],
                              companyFax: card['companyFax'],
                              department: card['department'],
                              position: card['position'],
                              userEmail: card['userEmail']
                          );

                          return Container(
                            width: 380,
                            height: 230,
                            child: SingleChildScrollView(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: buildBusinessCard(_cardInfo),
                              ),
                            )
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
          );
        }
      },
    );
  }
}