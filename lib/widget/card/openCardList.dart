import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/business/no_1.dart';
import 'package:itdat/screen/card/template/business/no_2.dart';
import 'package:itdat/screen/card/template/personal/no_1.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../setting/waitwidget.dart';

class OpenBusinessCardList extends StatefulWidget {
  OpenBusinessCardList({Key? key}) : super(key: key);

  @override
  State<OpenBusinessCardList> createState() => _OpenBusinessCardListState();
}

class _OpenBusinessCardListState extends State<OpenBusinessCardList> {
  final CardModel _cardModel = CardModel();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<dynamic>? _businessCards;
  bool _isEditMode = false;
  List<BusinessCard> _selectedCards = [];
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initializeData();
    print(_businessCards);
  }

  Future<void> _initializeData() async {
    _userEmail = await _storage.read(key: 'user_email');
    if (_userEmail != null) {
      setState(() {
        _businessCards = _cardModel.getBusinessCard(_userEmail!);
      });
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

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      _selectedCards.clear();
    });
  }

  void _toggleCardSelection(BusinessCard card) {
    setState(() {
      if (_selectedCards.contains(card)) {
        _selectedCards.remove(card);
      } else {
        _selectedCards.add(card);
      }
    });
  }

  void _updateSelectedCardsVisibility(bool makePublic) async {
    List<BusinessCard> cardsToUpdate = [];
    List<BusinessCard> alreadyPublicCards = [];

    for (var card in _selectedCards) {
      bool isCurrentlyPublic = card.isPublic == true;
      if (makePublic && isCurrentlyPublic) {
        alreadyPublicCards.add(card);
      } else {
        cardsToUpdate.add(card);
      }
    }

    if (alreadyPublicCards.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.alreadyPublicCards(alreadyPublicCards.length)),
          duration: Duration(seconds: 2),
        ),
      );
    }

    if (cardsToUpdate.isEmpty) {
      _toggleEditMode();
      return;
    }

    try {
      List<Map<String, dynamic>> selectedCardData = cardsToUpdate.map((card) {
        return {
          'userEmail': card.userEmail,
          'cardNo': card.cardNo,
          'isPublic': makePublic,
        };
      }).toList();

      await _cardModel.updateCardsPublicStatus(selectedCardData);

      setState(() {
        cardsToUpdate.forEach((card) {
          card.isPublic = makePublic;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              makePublic
                  ? AppLocalizations.of(context)!.cardsSetPublic(cardsToUpdate.length)
                  : AppLocalizations.of(context)!.cardsSetPrivate(cardsToUpdate.length)),
          duration: Duration(seconds: 2),
        ),
      );
      await _reloadBusinessCards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorChangingCardStatus),
          duration: Duration(seconds: 2),
        ),
      );
    }

    _toggleEditMode();
  }

  Future<void> _reloadBusinessCards() async {
    if (_userEmail != null) {
      setState(() {
        _businessCards = _cardModel.getBusinessCard(_userEmail!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.businessCardList),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: _businessCards == null
          ? Center(child: WaitAnimationWidget())
          : FutureBuilder<dynamic>(
        future: _businessCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: WaitAnimationWidget());
          } else if (snapshot.hasError) {
            return Center(child: Text(AppLocalizations.of(context)!.errorFetchingCards));
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noCards));
          } else {
            var businessCards = snapshot.data;

            return ListView.builder(
              itemCount: businessCards.length,
              itemBuilder: (context, index) {
                var card = businessCards[index];
                BusinessCard cardInfo = BusinessCard(
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
                  backgroundColor: card['backgroundColor'],
                  fontFamily: card['fontFamily'],
                  textColor: card['textColor'],

                );
                print("Card ${cardInfo.cardNo} isPublic: ${cardInfo.isPublic}");
                return GestureDetector(
                  onTap: _isEditMode
                      ? () {
                    setState(() {
                      _toggleCardSelection(cardInfo);
                    });
                  }
                      : null,
                  child: Transform.scale(
                    scale: 0.9,
                    child: Stack(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: buildBusinessCard(cardInfo),
                        ),
                        if (_isEditMode)
                          Positioned(
                            top: 15,
                            right: 20,
                            child: Icon(
                              _selectedCards.contains(cardInfo)
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: _selectedCards.contains(cardInfo)
                                  ? Colors.blue
                                  : Colors.grey,
                              size: 30,
                            ),
                          )
                        else
                          Positioned(
                            top: 15,
                            right: 20,
                            child: Icon(
                              cardInfo.isPublic == true ? Icons.public : Icons.public_off,
                              color: cardInfo.isPublic == true ? Colors.green : Colors.red,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: _isEditMode
          ? BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _updateSelectedCardsVisibility(true),
              child: Text(AppLocalizations.of(context)!.setPublic),
            ),
            ElevatedButton(
              onPressed: () => _updateSelectedCardsVisibility(false),
              child: Text(AppLocalizations.of(context)!.setPrivate),
            ),
          ],
        ),
      )
          : null,
    );
  }
}