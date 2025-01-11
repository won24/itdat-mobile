import 'package:flutter/material.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/widget/card/card_info_widget.dart';
import 'package:itdat/widget/card/portfolio/portfolio_widget.dart';
import 'package:itdat/widget/card/history/history_widget.dart';
import 'package:itdat/widget/reportUser/reportUserWidget.dart';

class PublicCardDetailScreen extends StatefulWidget {
  final BusinessCard cardInfo;

  const PublicCardDetailScreen({Key? key, required this.cardInfo}) : super(key: key);

  @override
  State<PublicCardDetailScreen> createState() => _PublicCardDetailScreenState();
}

class _PublicCardDetailScreenState extends State<PublicCardDetailScreen> {
  int _selectedIndex = 0;

  // 명함 템플릿 렌더링
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
  // commit 확인용.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("명함 세부 정보"),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert), // "..." 버튼 아이콘
            onSelected: (value) {
              if (value == 'report') {
                // _showReportDialog(); // 신고 다이얼로그 표시

                showDialog(
                    context: context,
                    builder: (context) => Reportuserwidget(
                        userEmail: widget.cardInfo.userEmail ?? "알 수 없는 이메일" // 신고 대상의 이메일
                    ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Text("신고"),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildBusinessCard(widget.cardInfo),
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
          // 선택된 섹션 렌더링
          Expanded(
            child: _selectedIndex == 0
                ? CardInfoWidget(businessCards: widget.cardInfo)
                : _selectedIndex == 1
                ? PortfolioWidget(currentUserEmail: widget.cardInfo.userEmail ?? "이메일 없음", cardUserEmail:widget.cardInfo.userEmail ?? "이메일 없음" ,)
                : HistoryWidget(currentUserEmail: widget.cardInfo.userEmail ?? "이메일 없음", cardUserEmail:widget.cardInfo.userEmail ?? "이메일 없음" ,),
          ),
        ],
      ),
    );
  }
}
