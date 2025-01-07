import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  String? userEmail;
  late Future<List<dynamic>> _businessCards;
  BusinessCard? selectedCardInfo;
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  int _cardIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }
  Future<void> _loadUserEmail() async {
    final storage = FlutterSecureStorage();
    String? email = await storage.read(key: 'email');
    setState(() {
      userEmail = email;
      _businessCards = CardModel().getBusinessCard(userEmail!);
    });
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

  Widget renderCardSlideIcon(List<dynamic> businessCards) {
    return Wrap(
      spacing: 5,
      alignment: WrapAlignment.center,
      children: List.generate(businessCards.length + 1, (index) {
        if (index == businessCards.length) {
          return IconButton(
            icon: Icon(
              Icons.add,
              size: 10,
              color: index == businessCards.length
                  ? const Color.fromRGBO(0, 202, 145, 1)
                  : Theme.of(context).iconTheme.color
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateSelectionScreen(userEmail: userEmail!),
                ),
              );
            },
          );
        } else {
          return IconButton(
            icon: Icon(
              Icons.circle,
              size: 10,
              color: index == _cardIndex
                  ? const Color.fromRGBO(0, 202, 145, 1)
                  : Theme.of(context).iconTheme.color
            ),
            onPressed: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() {
                _cardIndex = index;
              });
            },
          );
        }
      }),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
          flex: 1,
            child: SizedBox(
              height: 230,
              child: FutureBuilder<List<dynamic>>(
                future: _businessCards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('명함을 가져오는 중 오류가 발생했습니다.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemplateSelectionScreen(userEmail: userEmail!),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 64),
                      ),
                    );
                  } else {
                    var businessCards = snapshot.data!;

                    return Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: businessCards.length + 1,
                            onPageChanged: (index) {
                              setState(() {
                                _cardIndex = index;
                                if (index < businessCards.length) {
                                  selectedCardInfo = BusinessCard.fromJson(businessCards[index]);
                                }
                              });
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
                                              TemplateSelectionScreen(userEmail: userEmail!),
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
                                  cardSide: card['cardSide'],
                                  logoPath: card['logoPath'],
                                );

                                selectedCardInfo ??= cardInfo;

                                return Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Flexible(
                                        child: buildBusinessCard(cardInfo),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        renderCardSlideIcon(businessCards),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
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
                  child: _selectedIndex == 0 && selectedCardInfo != null
                      ? InfoWidget(businessCards: selectedCardInfo!)
                      : _selectedIndex == 1
                      ? const PortfolioWidget()
                      : const HistoryWidget(),
                ),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
