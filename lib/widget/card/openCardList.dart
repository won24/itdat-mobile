import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/models/card_model.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';

class OpenBusinessCardList extends StatefulWidget {
  OpenBusinessCardList({Key? key}) : super(key: key);

  @override
  State<OpenBusinessCardList> createState() => _OpenBusinessCardListState();
}

class _OpenBusinessCardListState extends State<OpenBusinessCardList> {
  final CardModel _cardModel = CardModel();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<dynamic>? _businessCards; // nullable로 변경
  bool _isEditMode = false;
  List<BusinessCard> _selectedCards = [];
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initializeData();
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
      case 'No3':
        return No3(cardInfo: cardInfo);
      default:
        return No2(cardInfo: cardInfo);
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
          content: Text('${alreadyPublicCards.length}개의 명함은 이미 공개 상태입니다.'),
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
              makePublic ? '${cardsToUpdate.length}개의 명함이 공개되었습니다.' : '${cardsToUpdate.length}개의 명함이 비공개로 설정되었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      await _reloadBusinessCards();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('명함 공개 상태 변경 중 오류가 발생했습니다.'),
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
        title: Text('명함 목록'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.edit),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: _businessCards == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<dynamic>(
        future: _businessCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('명함을 가져오는 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(child: Text('명함이 없습니다.'));
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
                  isPublic: card['public'],
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
                            top: 10,
                            right: 10,
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
                            top: 10,
                            right: 10,
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
                    child: Text('공개로 설정'),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateSelectedCardsVisibility(false),
                    child: Text('비공개로 설정'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}