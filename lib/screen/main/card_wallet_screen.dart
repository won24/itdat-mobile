import 'package:flutter/material.dart';
import 'package:itdat/models/mywallet_model.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/screen/card/template/no_1.dart';
import 'package:itdat/screen/card/template/no_2.dart';
import 'package:itdat/screen/card/template/no_3.dart';
import 'package:provider/provider.dart';
import 'package:itdat/providers/auth_provider.dart';

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
  String? _selectedFolder;

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

  void _createFolder() async {
    final userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;
    if (userEmail == null) return;

    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("새 폴더 생성"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "폴더명"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                await _walletModel.createFolder(userEmail, controller.text);
                Navigator.pop(context);
                _fetchFolders(userEmail);
              },
              child: Text("생성"),
            ),
          ],
        );
      },
    );
  }

  void _editFolder(String oldFolderName) async {
    final userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;
    if (userEmail == null) return;

    TextEditingController controller = TextEditingController(text: oldFolderName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("폴더 이름 수정"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: "새 폴더명"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  _showErrorSnackBar("폴더 이름을 입력해주세요.");
                  return;
                }

                try {
                  final success = await _walletModel.updateFolderName(
                    userEmail,
                    oldFolderName,
                    controller.text.trim(),
                  );

                  if (success) {
                    Navigator.pop(context);
                    _fetchFolders(userEmail);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("폴더 이름이 성공적으로 수정되었습니다.")),
                    );
                  } else {
                    _showErrorSnackBar("폴더 이름을 업데이트하는 데 실패했습니다.");
                  }
                } catch (e) {
                  _showErrorSnackBar("오류가 발생했습니다: $e");
                }
              },
              child: Text("수정"),
            ),

          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<AuthProvider>(context).userEmail;

    return Scaffold(
      appBar: AppBar(
        title: Text("내 명함첩"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _createFolder,
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
                            _editFolder(folder['folderName']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            await _walletModel.deleteFolder(
                                userEmail!, folder['folderName']);
                            _fetchFolders(userEmail);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        _selectedFolder = folder['folderName'];
                      });
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
                return Draggable<BusinessCard>(
                  data: card,
                  feedback: Material(
                    child: buildBusinessCard(card),
                  ),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: buildBusinessCard(card),
                    ),
                  ),
                  onDragEnd: (details) {
                    // 폴더 드롭 로직 추가
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
