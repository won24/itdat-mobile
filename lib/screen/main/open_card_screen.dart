import 'package:flutter/material.dart';
import 'package:itdat/models/publicCard_model.dart';
import 'package:itdat/screen/card/public_card_detail_screen.dart';
import 'package:itdat/screen/card/template/business/no_1.dart';
import 'package:itdat/screen/card/template/business/no_2.dart';
import 'package:itdat/screen/card/template/business/no_3.dart';
import 'package:itdat/screen/card/template/personal/no_1.dart';
import 'package:itdat/screen/card/template/personal/no_2.dart';
import '../../models/BusinessCard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widget/setting/waitwidget.dart';

class OpenCardScreen extends StatefulWidget {
  const OpenCardScreen({super.key});

  @override
  State<OpenCardScreen> createState() => _OpenCardScreenState();
}

class _OpenCardScreenState extends State<OpenCardScreen> {
  final PublicCardModel _cardModel = PublicCardModel();
  List<BusinessCard> _publicCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllPublicCards();
  }

  // 공개 명함 불러오기
  Future<void> _fetchAllPublicCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _cardModel.getAllPublicCards();
      setState(() {
        // Map<String, dynamic> 데이터를 BusinessCard 객체로 변환
        _publicCards = (cards as List)
            .map((card) => BusinessCard.fromJson(card))
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)!.errorLoadingPublicCards);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 에러 메시지 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 명함 템플릿 생성
  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'No3':
        return No3(cardInfo: cardInfo);
      case 'PersonalNo1':
        return PersonalNo1(cardInfo: cardInfo);
      case 'PersonalNo2':
        return PersonalNo2(cardInfo: cardInfo);
      default:
        return No1(cardInfo: cardInfo); // 기본값
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: WaitAnimationWidget())
          : _publicCards.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)!.noPublicCards))
              : ListView.builder(
                  itemCount: _publicCards.length,
                  itemBuilder: (context, index) {
                    final cardInfo = _publicCards[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PublicCardDetailScreen(cardInfo: cardInfo),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 명함 템플릿
                              buildBusinessCard(cardInfo),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}