import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:itdat/widget/card/card_info_widget.dart';
import 'package:itdat/widget/card/portfolio/portfolio_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  late String _loginEmail = "";

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final storage = FlutterSecureStorage();
    final userEmail = await storage.read(key: 'user_email');

    if (userEmail != null) {
      setState(() {
        _loginEmail = userEmail;
      });
    }
  }

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
        return No1(cardInfo: cardInfo);
    }
  }
  // commit 확인용.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)!.carddetailinfo),
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
               PopupMenuItem(
                value: 'report',
                child: Text(AppLocalizations.of(context)!.report),
              ),
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                child: Card(
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
                    "연락처",
                    style: TextStyle(
                        fontWeight: _selectedIndex == 0? FontWeight.w900: null,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                    ),
                  ),
                ),
                Text("|"),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Text(
                    "포트폴리오",
                    style: TextStyle(
                        fontWeight: _selectedIndex == 1? FontWeight.w900: null,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
                    ),),
                ),
                Text("|"),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: Text(
                    "히스토리",
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
                  ? CardInfoWidget(businessCards: widget.cardInfo, loginEmail: _loginEmail)
                  : _selectedIndex == 1
                  ? PortfolioWidget(loginUserEmail: _loginEmail, cardUserEmail: widget.cardInfo.userEmail,)
                  : HistoryWidget(loginUserEmail: _loginEmail, cardUserEmail: widget.cardInfo.userEmail,),
            ),
          ],
        )
      ),
    );
  }
}
