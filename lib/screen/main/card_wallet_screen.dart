import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:itdat/models/mywallet_model.dart';
import 'package:itdat/models/BusinessCard.dart';
import 'package:itdat/providers/auth_provider.dart';
import '../../widget/mycard/folder_detail_screen.dart';
import '../../widget/setting/waitwidget.dart';
import '../card/card_wallet_card_detail_screen.dart';
import '../card/template/business/no_1.dart';
import '../card/template/business/no_2.dart';
import '../card/template/personal/no_1.dart';

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
      _showErrorSnackBar(AppLocalizations.of(context)!.loginRequired);
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
      // debugPrint("API 응답 데이터: $allCardsResponse");

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
      _showErrorSnackBar(AppLocalizations.of(context)!.dataLoadError);
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
      _showErrorSnackBar(AppLocalizations.of(context)!.fetchFoldersError);
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
          title: Text(AppLocalizations.of(context)!.createFolderTitle),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.createFolderTitle,
              hintStyle: TextStyle(color: Colors.grey[400]),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(202, 202, 202, 1.0)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(0, 202, 145, 1)),
              ),
            ),

          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
            ),
            TextButton(
              onPressed: () {
                final folderName = folderNameController.text.trim();
                Navigator.pop(context, folderName);
              },
              child: Text(AppLocalizations.of(context)!.create,
                style: TextStyle(color: Color.fromRGBO(0, 202, 145, 1), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (folderName != null && folderName.isNotEmpty) {
      try {
        final success = await _walletModel.createFolder(userEmail, folderName);
        if (success) {
          _showErrorSnackBar(AppLocalizations.of(context)!.folderCreatedSuccess);
          await _fetchFolders(userEmail);
        } else {
          _showErrorSnackBar(AppLocalizations.of(context)!.folderCreationFailed);
        }
      } catch (e) {
        _showErrorSnackBar(AppLocalizations.of(context)!.folderCreationError);
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
          title: Text(AppLocalizations.of(context)!.editFolderTitle),
          content: TextField(
            controller: folderNameController,
            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.enterNewFolderNameHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                final newName = folderNameController.text.trim();
                Navigator.pop(context, newName);
              },
              child: Text(AppLocalizations.of(context)!.edit),
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
        _showErrorSnackBar(AppLocalizations.of(context)!.folderEditSuccess);
      } else {
        _showErrorSnackBar(AppLocalizations.of(context)!.folderEditFailed);
      }
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)!.folderEditError);
    }
  }

  Future<void> _deleteFolder(String userEmail, String folderName) async {
    try {
      final confirmed = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.deleteFolderTitle),
            content: Text(AppLocalizations.of(context)!.deleteFolderConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.delete),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.folderDeleteSuccess)));
        } else {
          _showErrorSnackBar(AppLocalizations.of(context)!.folderDeleteFailed);
        }
      }
    } catch (e) {
      _showErrorSnackBar(AppLocalizations.of(context)!.folderDeleteError);
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
      _showErrorSnackBar(AppLocalizations.of(context)!.dragerror);
    }
  }

  Widget buildBusinessCard(BusinessCard cardInfo) {
    switch (cardInfo.appTemplate) {
      case 'No1':
        return No1(cardInfo: cardInfo);
      case 'No2':
        return No2(cardInfo: cardInfo);
      case 'PersonalNo1':
        return PersonalNo1(cardInfo: cardInfo);
      default:
        return No1(cardInfo: cardInfo); // 기본값
    }
  }


  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<AuthProvider>(context).userEmail ?? "unknown";

    return Scaffold(
      appBar: AppBar(
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
          ? Center(child: WaitAnimationWidget())
          : Column(
        children: [
          // 폴더 섹션
          Expanded(
            flex: 2,
            child: _folders.isEmpty
                ? Center(
              child: Text(
                  AppLocalizations.of(context)!.noFolder,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : GridView.builder(
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
                        // debugPrint("드롭된 명함 데이터: ${card.userName}, ${card.userEmail}");
                        final userEmail =
                            Provider.of<AuthProvider>(context, listen: false).userEmail;
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
                                if (result != null && result is Map<String, dynamic>) {
                                  final removedCard = result['card'] as BusinessCard;
                                  final index = result['index'] as int;

                                  setState(() {
                                    _allCards.insert(index, removedCard);
                                  });
                                } else if (result == true) {
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
          // 명함 섹션
          Expanded(
            flex: 6,
            child: _allCards.isEmpty
                ? Center(
              child: Text(
                AppLocalizations.of(context)!.noCards,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 4 / 3,
              ),
              itemCount: _allCards.length,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemBuilder: (context, index) {
                final card = _allCards[index];

                return LongPressDraggable<BusinessCard>(
                  data: card,
                  feedback: Transform.scale(
                    scale: 0.4,
                    child: Material(
                      color: Colors.transparent,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildBusinessCard(card), // 명함 템플릿 렌더링
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.5,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildBusinessCard(card), // 명함 템플릿 렌더링
                          ],
                        ),
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardWalletCardDetailScreen(
                            cardInfo: [card],
                            loginUserEmail: Provider.of<AuthProvider>(context, listen: false).userEmail!,
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            buildBusinessCard(card), // 명함 템플릿 렌더링
                          ],
                        ),
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