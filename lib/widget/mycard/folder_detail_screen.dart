import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:itdat/models/mywallet_model.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screen/card/card_wallet_card_detail_screen.dart';
import '../../screen/card/template/no_1.dart';
import '../../screen/card/template/no_2.dart';
import '../../screen/card/template/no_3.dart';

class FolderDetailScreen extends StatefulWidget {
  final String folderName;

   FolderDetailScreen({Key? key, required this.folderName}) : super(key: key);

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final MyWalletModel _walletModel = MyWalletModel();
  List<BusinessCard> _cards = [];
  bool _isLoading = true;
  bool _isEditMode = false;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = Provider.of<AuthProvider>(context, listen: false).userEmail;
      if (email != null) {
        setState(() {
          userEmail = email;
        });
        _fetchFolderCards(email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.loginRequired)),
        );
      }
    });
  }

  Future<void> _fetchFolderCards(String email) async {
    setState(() => _isLoading = true);

    try {
      final folderData = await _walletModel.getCardsByFolder(email, widget.folderName);
      setState(() {
        _cards = folderData.map<BusinessCard>((cardData) {
          final businessCard = cardData['businessCard'] ?? {};
          return BusinessCard(
            appTemplate: businessCard['appTemplate'],
            userName: businessCard['userName'] ?? AppLocalizations.of(context)!.noName,
            phone: businessCard['phone'],
            email: businessCard['email'],
            companyName: businessCard['companyName'] ?? AppLocalizations.of(context)!.notfound,
            companyNumber: businessCard['companyNumber'],
            companyAddress: businessCard['companyAddress'],
            companyFax: businessCard['companyFax'],
            department: businessCard['department'],
            position: businessCard['position'],
            userEmail: businessCard['userEmail'],
            cardNo: businessCard['cardNo'],
            cardSide: businessCard['cardSide'],
            logoUrl: businessCard['logoUrl'],
          );
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fetchCardsError)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeCardFromFolder(BusinessCard card) async {
    try {
      final originalIndex = _cards.indexOf(card);

      final success = await _walletModel.moveCardToFolder(
        userEmail,
        card.userEmail,
        "", // 폴더에서 제거 시 빈 문자열 전달
      );

      if (success) {
        setState(() {
          _cards.removeWhere((c) => c.userEmail == card.userEmail);
        });

        Navigator.pop(context, {'card': card, 'index': originalIndex});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cardRemoved(card.userName ?? AppLocalizations.of(context)!.noName))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.removeCardFailed)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.removeCardError)),
      );
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
        return No2(cardInfo: cardInfo); // 기본값
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("폴더: ${widget.folderName}"),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cards.isEmpty
          ? Center(child: Text(AppLocalizations.of(context)!.folderinnotcard))
          : GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // 한 줄에 명함 하나씩
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 4 / 3, // 명함 비율
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardWalletCardDetailScreen(
                        cardInfo: [card],
                        loginUserEmail: userEmail,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildBusinessCard(card), // 명함 템플릿 렌더링
                  ),
                ),
              ),
              if (_isEditMode)
                Positioned(
                  top: -10,
                  right: -5,
                  child: IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeCardFromFolder(card),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
