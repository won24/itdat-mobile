import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';

class WritePostDialog extends StatefulWidget {
  final Map<String, dynamic>? post;
  final String userEmail;
  final VoidCallback onPostModified;

  const WritePostDialog({
    super.key,
    this.post,
    required this.userEmail,
    required this.onPostModified
  });

  @override
  State<WritePostDialog> createState() => _WritePostDialogState();
}

class _WritePostDialogState extends State<WritePostDialog> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();


  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _titleController.text = widget.post!['title'] ?? '';
      _contentController.text = widget.post!['content'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }


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


  void _savePost(BuildContext context, postData) async {
    try {
      await BoardModel().saveHistory(postData);
      _showSnackBar("히스토리 추가 완료");
      widget.onPostModified();
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("히스토리 추가 실패. 다시 시도해주세요.", isError: true);
    }
  }


  void _editPost(BuildContext context, postData) async {
    try {
      await BoardModel().editHistory(postData, widget.post?['id']);
      Navigator.pop(context);
      widget.onPostModified();
      _showSnackBar("히스토리 수정 완료");
    } catch (e) {
      _showSnackBar("히스토리 수정 실패. 다시 시도해주세요.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Dialog(
        child: SingleChildScrollView(
          child: Container(
            width: 350,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.post == null ? '히스토리 추가' : '히스토리 수정: ${widget.post!['title']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: '제목',
                    labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(202, 202, 202, 1.0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(202, 202, 202, 1.0)),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: '내용',
                    labelStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  maxLines: 3,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('취소', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),),
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
                      child: widget.post == null
                          ? Text('저장', style: TextStyle(color: Color.fromRGBO(0, 202, 145, 1), fontWeight: FontWeight.bold),)
                          : Text('수정', style: TextStyle(color: Color.fromRGBO(0, 202, 145, 1), fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
