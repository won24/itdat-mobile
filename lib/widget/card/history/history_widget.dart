import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';

class HistoryWidget extends StatefulWidget {
  final String currentUserEmail;
  final String cardUserEmail;

  const HistoryWidget({
    super.key,
    required this.currentUserEmail,
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
    final fetchedPosts = await BoardModel().getPosts(widget.cardUserEmail);
    fetchedPosts.sort((a, b) => b['id'].compareTo(a['id']));
    setState(() {
      posts = fetchedPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: posts.isEmpty
          ? widget.cardUserEmail == widget.currentUserEmail? Center(child: Text('간단한 이력사항, 기술 등을 작성할 수 있습니다.')) : Center(child: Text('히스토리가 없습니다.'))
          : ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children: [
                Text(post['title'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color.fromRGBO(0, 202, 145, 1)),),
                Text(post['content'])
              ],
            )
            );
        },
      ),
      floatingActionButton: widget.cardUserEmail == widget.currentUserEmail
          ? FloatingActionButton(
        onPressed: showDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(Icons.playlist_add_sharp),
      )
          : null,
    );
  }
}
