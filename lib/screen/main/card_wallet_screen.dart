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
  bool _isEditMode = false;

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

    await Future.wait([_fetchFolders(userEmail), _fetchBusinessCards(userEmail)]);

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

  Future<void> _fetchBusinessCards(String userEmail) async {
    try {
      final cards = await _walletModel.getAllCards(userEmail);
      setState(() {
        _cards = cards.map((card) => BusinessCard.fromJson(card)).toList();
      });
    } catch (e) {
      _showErrorSnackBar("명함 목록을 가져오는 중 오류가 발생했습니다.");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createFolder(String userEmail) async {
    final folderNameController = TextEditingController();

    final folderName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("폴더 생성"),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: "폴더 이름 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                final folderName = folderNameController.text.trim();
                Navigator.pop(context, folderName);
              },
              child: Text("생성"),
            ),
          ],
        );
      },
    );

    if (folderName != null && folderName.isNotEmpty) {
      try {
        final success = await _walletModel.createFolder(userEmail, folderName);
        if (success) {
          _showErrorSnackBar("폴더가 성공적으로 생성되었습니다.");
          await _fetchFolders(userEmail);
        } else {
          _showErrorSnackBar("폴더 생성에 실패했습니다.");
        }
      } catch (e) {
        _showErrorSnackBar("폴더 생성 중 오류가 발생했습니다.");
      }
    }
  }

  Future<void> _editFolderDialog(String userEmail, String oldFolderName) async {
    final TextEditingController folderNameController =
    TextEditingController(text: oldFolderName);

    final newFolderName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("폴더 이름 수정"),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: "새로운 폴더 이름 입력"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                final newName = folderNameController.text.trim();
                Navigator.pop(context, newName);
              },
              child: Text("수정"),
            ),
          ],
        );
      },
    );

    if (newFolderName != null && newFolderName.isNotEmpty && newFolderName != oldFolderName) {
      await _editFolder(userEmail, oldFolderName, newFolderName);
    }
  }

  Future<void> _editFolder(String userEmail, String oldFolderName, String newFolderName) async {
    try {
      final success = await _walletModel.updateFolderName(userEmail, oldFolderName, newFolderName);
      if (success) {
        setState(() {
          final folderIndex = _folders.indexWhere((folder) => folder['folderName'] == oldFolderName);
          if (folderIndex != -1) {
            _folders[folderIndex]['folderName'] = newFolderName;
          }
        });
        _showErrorSnackBar("폴더 이름이 성공적으로 수정되었습니다.");
      } else {
        _showErrorSnackBar("폴더 이름 수정에 실패했습니다.");
      }
    } catch (e) {
      _showErrorSnackBar("폴더 이름 수정 중 오류가 발생했습니다.");
    }
  }

  Future<void> _deleteFolder(String userEmail, String folderName) async {
    try {
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
        final success = await _walletModel.deleteFolder(userEmail, folderName);
        if (success) {
          setState(() {
            _folders.removeWhere((folder) => folder['folderName'] == folderName);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("폴더가 삭제되었습니다.")));
        } else {
          _showErrorSnackBar("폴더 삭제에 실패했습니다.");
        }
      }
    } catch (e) {
      _showErrorSnackBar("폴더 삭제 중 오류가 발생했습니다.");
    }
  }


  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<AuthProvider>(context).userEmail ?? "unknown";

    return Scaffold(
      appBar: AppBar(
        title: Text("내 명함첩"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createFolder(userEmail),
          ),
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
          : Column(
        children: [
          Expanded(
            flex: 2,
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        if (_isEditMode) {
                          _editFolderDialog(userEmail, folder['folderName']);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FolderDetailScreen(folderName: folder['folderName']),
                            ),
                          );
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder,
                            size: 64.0,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            folder['folderName'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (_isEditMode)
                      Positioned(
                        top: 0,
                        right: 25,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () =>
                              _deleteFolder(userEmail!, folder['folderName']),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Divider(),
          Expanded(
            flex: 3,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 5 / 3,
              ),
              itemCount: _cards.length,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
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
                          "회사: ${card.companyName ?? '정보 없음'}",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          "이메일: ${card.userEmail ?? '이메일 없음'}",
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
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
