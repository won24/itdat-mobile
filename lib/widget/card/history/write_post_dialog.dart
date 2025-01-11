import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';

class WritePostDialog extends StatefulWidget {
  final Function(String) onPostSave;
  final Map<String, dynamic>? post;
  final String userEmail;

  const WritePostDialog({
    super.key,
    required this.onPostSave,
    this.post,
    required this.userEmail,
  });

  @override
  State<WritePostDialog> createState() => _WritePostDialogState();
}

class _WritePostDialogState extends State<WritePostDialog> {

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // void _savePost() {
  //   String title = _titleController.text;
  //   String content = _contentController.text;
  //   if (title.isNotEmpty && content.isNotEmpty) {
  //     // widget.onPostSave(title + "\n" + content);
  //     Navigator.pop(context);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('제목과 내용을 모두 입력해 주세요.')));
  //   }
  // }

  void _showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      action: SnackBarAction(
        label: '확인',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  // 저장
  void _savePost(BuildContext context, postData) async {
    try {
      await BoardModel().savePost(postData);
      _showSnackBar("히스토리 추가 완료");
      widget.onPostSave;
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("히스토리 추가 실패. 다시 시도해주세요.", isError: true);
    }
  }

  // 수정
  void _editPost(BuildContext context, postData) async {
    try {
      await BoardModel().editPost(postData, widget.post?['id']);
      widget.onPostSave;
      Navigator.pop(context);
      _showSnackBar("게시글 수정 완료");
    } catch (e) {
      _showSnackBar("게시글 수정 실패. 다시 시도해주세요.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.post == null ? '히스토리 추가' : '히스토리 수정: ${widget.post!['title']}'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: '제목'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: '내용'),
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () {
            final postData = {
              'userEmail': widget.userEmail,
              'title': _titleController.text,
              'content': _contentController.text,
            };
            widget.post == null
                ? _savePost(context, postData)
                : _editPost(context, postData);
          },
          child: widget.post == null ? const Text('저장') : const Text('수정'),
        ),
      ],
    );
  }
}
