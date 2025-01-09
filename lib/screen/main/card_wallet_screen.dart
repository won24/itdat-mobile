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
  List<BusinessCard> _allCards = [];
  Map<String, List<BusinessCard>> _folderCards = {};
  bool _isLoading = true;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void updateAllCards(BusinessCard card) {
    setState(() {
      _allCards.add(card);
    });
  }

  Future<void> refreshAllCards() async {
    final userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;

    if (userEmail != null) {
      try {
        // 전체 명함 목록 다시 로드
        final allCardsResponse = await _walletModel.getAllCards(userEmail);
        setState(() {
          _allCards = (allCardsResponse as List)
              .map((card) => BusinessCard.fromJson(card as Map<String, dynamic>))
              .toList();
        });
      } catch (e) {
        debugPrint("명함 새로고침 중 오류: $e");
      }
    }
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

    try {
      // 전체 명함과 폴더 목록 동시 로드
      final allCardsResponse = await _walletModel.getAllCards(userEmail);
      final foldersResponse = await _walletModel.getFolders(userEmail);

      // debugPrint("전체 명함 응답: $allCardsResponse");
      // debugPrint("폴더 응답: $foldersResponse");

      // 전체 명함 로드
      setState(() {
        _allCards = (allCardsResponse as List)
            .map((card) => BusinessCard.fromJson(card as Map<String, dynamic>))
            .toList();
      });

      // 폴더 목록 로드
      setState(() {
        _folders = foldersResponse;
      });

      // 폴더별 명함 로드
      for (var folder in _folders) {
        final folderName = folder['folderName'];
        final folderCardsResponse = await _walletModel.getFolderCards(folderName);

        // debugPrint("폴더 '$folderName'의 명함 응답: $folderCardsResponse");

        setState(() {
          _folderCards[folderName] = (folderCardsResponse as List)
              .map((card) => BusinessCard.fromJson(card as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("데이터 로드 중 오류: $e");
      _showErrorSnackBar("데이터를 가져오는 중 오류가 발생했습니다.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  Future<void> _moveCardToFolder(String userEmail, String folderName, BusinessCard card) async {
    try {
      final success = await _walletModel.moveCardToFolder(userEmail, card.userEmail!, folderName);

      if (success) {
        setState(() {
          // 전체 명함에서 제거
          _allCards.removeWhere((c) => c.userEmail == card.userEmail);

          // 폴더에 추가
          if (!_folderCards.containsKey(folderName)) {
            _folderCards[folderName] = [];
          }
          _folderCards[folderName]?.add(card);
        });
      }
    } catch (e) {
      _showErrorSnackBar("명함 이동 중 오류가 발생했습니다.");
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 30.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.0,
              ),
              itemCount: _folders.length,
              itemBuilder: (context, index) {
                final folder = _folders[index];
                return Stack(
                  children: [
                    DragTarget<BusinessCard>(
                      onAccept: (card) {
                        debugPrint("드롭된 명함 데이터: ${card.userName}, ${card.userEmail}");
                        final userEmail = Provider.of<AuthProvider>(context, listen: false).userEmail;
                        if (userEmail != null) {
                          _moveCardToFolder(userEmail, folder['folderName'], card);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return InkWell(
                          onTap: () {
                            if (_isEditMode) {
                              _editFolderDialog(userEmail, folder['folderName']);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FolderDetailScreen(
                                    folderName: folder['folderName'],
                                  ),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  refreshAllCards();
                                }
                              });
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder, size: 64.0, color: Colors.grey),
                              const SizedBox(height: 8.0),
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
                        );
                      },
                    ),
                    if (_isEditMode)
                      Positioned(
                        top: -10,
                        right: 12,
                        child: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            _deleteFolder(userEmail, folder['folderName']);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Divider(),
          Expanded(
            flex: 6,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 5 / 3,
              ),
              itemCount: _allCards.length, // 전체 명함 개수
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemBuilder: (context, index) {
                final card = _allCards[index];

                return Draggable<BusinessCard>(
                  data: card, // 드래그 시 전달할 데이터
                  feedback: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      width: 150,
                      color: Colors.grey[300],
                      child: Text(
                        card.userName ?? '이름 없음',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5, // 드래그 중일 때 원본 아이템의 투명도
                    child: Card(
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  ),
                  child: Card(
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
