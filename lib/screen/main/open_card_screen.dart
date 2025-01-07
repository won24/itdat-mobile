import 'package:flutter/material.dart';
import 'package:itdat/models/publicCard_model.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';

import '../../models/BusinessCard.dart';

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
      _showErrorSnackBar("공개 명함을 불러오는 중 오류가 발생했습니다.");
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
      default:
        return No2(cardInfo: cardInfo); // 기본값
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("공개 명함"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _publicCards.isEmpty
          ? const Center(child: Text("공개된 명함이 없습니다."))
          : ListView.builder(
        itemCount: _publicCards.length,
        itemBuilder: (context, index) {
          final cardInfo = _publicCards[index];
          return Card(
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
          );
        },
      ),
    );
  }
}
