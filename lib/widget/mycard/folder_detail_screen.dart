import 'package:flutter/material.dart';
import 'package:itdat/models/mywallet_model.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class FolderDetailScreen extends StatefulWidget {
  final String folderName;

  const FolderDetailScreen({Key? key, required this.folderName}) : super(key: key);

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
          SnackBar(content: Text("로그인이 필요합니다.")),
        );
      }
    });
  }

  Future<void> _fetchFolderCards(String email) async {
    setState(() => _isLoading = true);

    try {
      final folderData = await _walletModel.getCardsByFolder(email, widget.folderName);
      debugPrint("폴더 내부 명함 데이터: $folderData");

      // 데이터 변환: businessCard 필드를 평탄화
      setState(() {
        _cards = folderData.map<BusinessCard>((cardData) {
          final businessCard = cardData['businessCard'] ?? {}; // 중첩된 필드
          return BusinessCard(
            appTemplate: businessCard['appTemplate'],
            userName: businessCard['userName'] ?? '이름 없음',
            phone: businessCard['phone'],
            email: businessCard['email'],
            companyName: businessCard['companyName'] ?? '정보 없음',
            companyNumber: businessCard['companyNumber'],
            companyAddress: businessCard['companyAddress'],
            companyFax: businessCard['companyFax'],
            department: businessCard['department'],
            position: businessCard['position'],
            userEmail: businessCard['userEmail'],
            cardNo: businessCard['cardNo'],
            cardSide: businessCard['cardSide'],
            logoPath: businessCard['logoPath'],
          );
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("명함을 가져오는 중 오류가 발생했습니다.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _removeCardFromFolder(BusinessCard card) async {
    try {
      final success = await _walletModel.moveCardToFolder(
        userEmail,
        card.userEmail!,
        "", // 폴더에서 제거 시 null 전달
      );

      if (success) {
        setState(() {
          _cards.removeWhere((c) => c.userEmail == card.userEmail);
        });

        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${card.userName} 명함이 전체 명함으로 이동되었습니다.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("명함 제외에 실패했습니다.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("명함 제외 중 오류가 발생했습니다.")),
      );
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
          ? Center(child: Text("폴더에 명함이 없습니다."))
          : GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 4 / 3,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return Stack(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.userName ?? '이름 없음',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        card.companyName ?? '정보 없음',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        card.userEmail ?? '이메일 없음',
                        style: TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              if (_isEditMode)
                Positioned(
                  top: -10,
                  right: 15,
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
