import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itdat/models/mywallet_model.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/providers/auth_provider.dart';
import '../../widget/mycard/folder_detail_screen.dart';

class CardWalletScreen extends StatefulWidget {
  const CardWalletScreen({Key? key}) : super(key: key);

  @override
  State<CardWalletScreen> createState() => _CardWalletScreenState();
}

class _CardWalletScreenState extends State<CardWalletScreen> {
  final MyWalletModel _walletModel = MyWalletModel();
  List<dynamic> _folders = [];
  List<BusinessCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;
    if (userEmail == null) {
      _showErrorSnackBar("로그인이 필요합니다.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.wait([_fetchFolders(userEmail), _fetchCards(userEmail)]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchFolders(String userEmail) async {
    try {
      final folders = await _walletModel.getFolders(userEmail);
      setState(() {
        _folders = folders;
      });
    } catch (e) {
      _showErrorSnackBar("폴더 목록을 가져오는 중 오류가 발생했습니다.");
    }
  }

  Future<void> _fetchCards(String userEmail) async {
    try {
      final cards = await _walletModel.getCards(userEmail);
      setState(() {
        _cards = (cards as List)
            .map((card) => BusinessCard.fromJson(card as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      _showErrorSnackBar("명함 목록을 가져오는 중 오류가 발생했습니다.");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _deleteFolder(String userEmail, String folderName) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("폴더 삭제"),
          content: Text("폴더를 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("삭제"),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _walletModel.deleteFolder(userEmail, folderName);
      await _fetchFolders(userEmail);
      await _fetchCards(userEmail); // 폴더 삭제 시 명함 업데이트
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<AuthProvider>(context).userEmail;

    return Scaffold(
      appBar: AppBar(
        title: Text("내 명함첩"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // 폴더 생성 로직
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return Card(
                  child: ListTile(
                    title: Text(folder['folderName']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // 폴더 수정 로직
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteFolder(userEmail!, folder['folderName']),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FolderDetailScreen(folderName: folder['folderName']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Divider(),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Card(
                  child: ListTile(
                    subtitle: Text("카드 번호: ${card.cardNo}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
