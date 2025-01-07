import 'package:flutter/material.dart';
import 'package:itdat/models/mywallet_model.dart';
import 'package:itdat/models/BusinessCard.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchFolderCards();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("폴더: ${widget.folderName}"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _cards.isEmpty
          ? Center(child: Text("폴더에 명함이 없습니다."))
          : ListView.builder(
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
    );
  }
}
