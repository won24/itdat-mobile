import 'package:flutter/material.dart';

import '../../models/BusinessCard.dart';
import '../../models/card_model.dart'; // CardModel import

class CardDeleteWidget extends StatelessWidget {
  final BusinessCard cardInfo;
  final Function onDeleteSuccess;

  const CardDeleteWidget({
    Key? key,
    required this.cardInfo,
    required this.onDeleteSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () => _showDeleteConfirmationDialog(context),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('명함 삭제'),
          content: Text('정말로 이 명함을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteCard(context);
    }
  }

  Future<void> _deleteCard(BuildContext context) async {
    try {
      final cardModel = CardModel();
      await cardModel.deleteCard(cardInfo.cardNo!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('명함이 성공적으로 삭제되었습니다.')),
      );
      
      onDeleteSuccess();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('명함 삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }
}