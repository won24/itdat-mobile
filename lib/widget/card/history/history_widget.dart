import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';
import 'package:itdat/widget/card/history/write_post_dialog.dart';

class HistoryWidget extends StatefulWidget {
  final String loginUserEmail;
  final String cardUserEmail;

  const HistoryWidget({
    super.key,
    required this.loginUserEmail,
    required this.cardUserEmail
  });

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  List<Map<String, dynamic>> posts = [];


  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }


  Future<void> _fetchPosts() async {
    final fetchedPosts = await BoardModel().getHistories(widget.cardUserEmail);
    fetchedPosts.sort((a, b) => b['id'].compareTo(a['id']));
    setState(() {
      posts = fetchedPosts;
    });
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
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


  void _editPost(BuildContext context, Map<String, dynamic> post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WritePostDialog(
              post: post,
              userEmail: widget.loginUserEmail,
              onPostModified: _fetchPosts,
            ),
      ),
    );
  }


  void _deletePost(BuildContext context, Map<String, dynamic> post) async {
    try {
      await BoardModel().deleteHistory(post['id']);
      _showSnackBar(context, "히스토리 삭제 완료");
      _fetchPosts();
    } catch (e) {
      _showSnackBar(context, "히스토리 삭제 실패. 다시 시도해주세요.", isError: true);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: posts.isEmpty
          ? widget.cardUserEmail == widget.loginUserEmail
            ? Center(child: Text('간단한 이력사항, 기술 등을 작성할 수 있습니다.'))
            : Center(child: Text('히스토리가 없습니다.'))
          : ListView.builder(
              physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화
              shrinkWrap: true, // 부모 컨테이너 크기에 맞춤
              padding: EdgeInsets.all(8.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(post['title'], style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color:Color.fromRGBO(0, 202, 145, 1)),),
                          if (post['userEmail'] == widget.loginUserEmail)
                            Align(
                              alignment: Alignment.topRight,
                              child: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') _editPost(context, post);
                                  if (value == 'delete') _deletePost(context, post);
                                },
                                itemBuilder: (context) =>
                                [
                                  PopupMenuItem(value: 'edit', child: Text('수정')),
                                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Text(post['content'])
                    ],
                  )
                  );
              },
            ),
          floatingActionButton: widget.cardUserEmail == widget.loginUserEmail
              ? FloatingActionButton(
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return WritePostDialog(userEmail: widget.loginUserEmail, onPostModified: _fetchPosts);
                      },
                    );
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  splashColor: Colors.transparent,
                  highlightElevation: 0,
                  child: Image.asset('assets/icons/addHistory.png', height: 30, width: 30, color: isDarkMode ? Colors.grey[200] : Colors.black,),
                )
              : null,
    );
  }
}

