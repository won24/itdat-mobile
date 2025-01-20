import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/expanded_card_screen.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/screen/card/template_selection_screen.dart';
import 'package:itdat/widget/card/card_info_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/widget/card/portfolio/portfolio_widget.dart';
import 'package:itdat/widget/card/history/history_widget.dart';

import '../../widget/setting/waitwidget.dart';

class MyCardScreen extends StatefulWidget {
  const MyCardScreen({super.key});

  @override
  State<MyCardScreen> createState() => _MyCardWidgetState();
}

class _MyCardWidgetState extends State<MyCardScreen> {

  late String _loginEmail = "";
  late Future<List<dynamic>>? _businessCards;
  BusinessCard? selectedCardInfo;
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  int _cardIndex = 0;
  late BusinessCard emptyCardInfo = BusinessCard(appTemplate: "", userName: "", phone: "", email: "", companyName: "", companyNumber: "", companyAddress: "", companyFax: "", department: "", position: "", userEmail: "", cardNo: 0, cardSide: "");

  @override
  void initState() {
    super.initState();
    _businessCards = null;
    _loadEmail();
  }

  void _setInitialCard(List<dynamic> filteredCards) {
    if (filteredCards.isNotEmpty && selectedCardInfo == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          selectedCardInfo = filteredCards[0];
        });
      });
    }
  }


  Future<void> _loadEmail() async {
    final storage = FlutterSecureStorage();
    final userEmail = await storage.read(key: 'user_email');

    if (userEmail != null) {
      setState(() {
        _loginEmail = userEmail;
        _businessCards = CardModel().getBusinessCard(_loginEmail);
        emptyCardInfo.userEmail = _loginEmail;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Widget buildBusinessCard(BusinessCard cardInfo, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Transform.scale(
        scale: 0.9,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: _getTemplateWidget(cardInfo),
        ),
      )
    );
  }

  Widget _getTemplateWidget(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo,);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'No3':
        return No3(cardInfo: cardInfo);
      default:
        return No1(cardInfo: cardInfo);
    }
  }

  Widget renderCardSlideIcon(List<dynamic> filteredCards) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(filteredCards.length + 1, (index) {
        if (index == filteredCards.length) {
          return IconButton(
            icon: Icon(
              Icons.add,
              size: 15,
              color: Theme.of(context).iconTheme.color
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TemplateSelectionScreen(userEmail: _loginEmail),
                ),
              ).then((_) => _reloadBusinessCards());
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

  void _reloadBusinessCards() {
    setState(() {
      _businessCards = CardModel().getBusinessCard(_loginEmail);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: FutureBuilder<List<dynamic>>(
                  future: _businessCards,
                  builder: (context, snapshot) {
                    if (_businessCards == null) {
                      return const Center(child: WaitAnimationWidget());
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: WaitAnimationWidget());
                    } else if (snapshot.hasError) {
                      return  Center(child: Text(AppLocalizations.of(context)!.errorFetchingCards));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TemplateSelectionScreen(userEmail: _loginEmail),
                              ),
                            ).then((_) => _reloadBusinessCards());
                          },
                          icon: const Icon(Icons.add, size: 64),
                        ),
                      );
                    } else {
                      var businessCards = snapshot.data!
                          .map((data) => BusinessCard.fromJson(data)).toList()
                        ..sort((a, b) => b.cardNo!.compareTo(a.cardNo!));

                      var filteredCards = businessCards
                          .where((card) => card.cardSide == 'FRONT' && card.userEmail == _loginEmail)
                          .toList();

                      _setInitialCard(filteredCards);

                      return Column(
                        children: [
                          Flexible(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: filteredCards.length + 1,
                              onPageChanged: (index) {
                                setState(() {
                                  _cardIndex = index;
                                  if (index < filteredCards.length) {
                                    selectedCardInfo = filteredCards[index];
                                  }
                                });
                              },
                              itemBuilder: (context, index) {
                                if (index == filteredCards.length) {
                                  return Center(
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TemplateSelectionScreen(userEmail: _loginEmail),
                                          ),
                                        ).then((_) => _reloadBusinessCards());
                                      },
                                      icon: const Icon(Icons.add, size: 64),
                                    ),
                                  );
                                } else {
                                  var cardInfo = filteredCards[index];

                                  return GestureDetector(
                                    onTap: (){
                                      BusinessCard? backCard;
                                      for (var businessCard in businessCards) {
                                        if (businessCard.cardNo == cardInfo.cardNo && businessCard.cardSide == 'BACK') {
                                          backCard = businessCard;
                                          break;
                                        }
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ExpandedCardScreen(
                                            cardInfo: cardInfo,
                                            backCard: backCard,
                                          ),
                                        ),
                                      ).then((value) {
                                        if (value == true) {
                                          _reloadBusinessCards();
                                        }
                                      });
                                    },
                                    child: Container(
                                      child: buildBusinessCard(cardInfo, context),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          renderCardSlideIcon(filteredCards),
                        ],
                      );
                    }
                  },
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
                    AppLocalizations.of(context)!.contact,
                      style: TextStyle(
                        fontWeight: _selectedIndex == 0? FontWeight.w900: null,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                      ),
                  ),
                ),
                Text(
                  "|",
                  style: TextStyle(color:Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.portfolio,
                    style: TextStyle(
                      fontWeight: _selectedIndex == 1? FontWeight.w900: null,
                      color:Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                    ),
                  ),
                ),
                Text(
                  "|",
                  style: TextStyle(color:Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.history,
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
                  ? CardInfoWidget(businessCards: selectedCardInfo ?? emptyCardInfo, loginEmail: _loginEmail)
                  : _selectedIndex == 1
                  ? PortfolioWidget(loginUserEmail: _loginEmail, cardUserEmail: _loginEmail)
                  : HistoryWidget(loginUserEmail: _loginEmail, cardUserEmail: _loginEmail),
            )
          ],
        ),
      ),
    );
  }
}