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
  bool _isEditMode = false; // 편집 모드 상태 추가
  late String userEmail;


  @override
  void initState() {
    super.initState();
    _fetchFolderCards();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = Provider.of<AuthProvider>(context, listen: false).userEmail;
      if (email != null) {
        setState(() {
          userEmail = email;
        });
      } else {
        // 예외 처리: 이메일이 없으면 경고 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("로그인이 필요합니다.")),
        );
      }
    });
  }

  Future<void> _fetchFolderCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cards = await _walletModel.getFolderCards(widget.folderName);
      setState(() {
        _cards = (cards as List)
            .map((card) => BusinessCard.fromJson(card as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("명함을 가져오는 중 오류가 발생했습니다.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 명함을 폴더에서 제외하는 메서드
  Future<void> _removeCardFromFolder(String folderName, BusinessCard card) async {
    try {
      debugPrint("명함 제거 요청 시작: ${card.userEmail}");

      final userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;

      if (userEmail == null) {
        throw Exception("사용자 이메일을 가져올 수 없습니다.");
      }

      final success = await _walletModel.moveCardToFolder(
        userEmail,
        card.userEmail!,
        folderName.isEmpty ? "" : folderName, // 폴더 이름 처리
      );

      if (success) {
        setState(() {
          _cards.removeWhere((c) => c.userEmail == card.userEmail);
        });
        debugPrint("명함 제거 성공: ${card.userName}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${card.userName} 명함이 전체 명함으로 이동되었습니다.")),
        );
      } else {
        debugPrint("명함 제거 실패");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("명함 제외에 실패했습니다.")),
        );
      }
    } catch (e) {
      debugPrint("명함 제거 중 오류: $e");
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
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
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
          crossAxisCount: 2, // 한 행에 2개의 카드
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 4 / 3, // 카드의 가로 세로 비율
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
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.userName ?? '이름 없음',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        "${card.companyName ?? '정보 없음'}",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        "${card.userEmail ?? '이메일 없음'}",
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
                  top: -13,
                  right: -3,
                  child: IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      _removeCardFromFolder(widget.folderName, card);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
