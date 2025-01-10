import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';
import 'package:itdat/widget/card/portfolio/post_box.dart';
import 'package:itdat/widget/card/portfolio/write_post.dart';

class PortfolioWidget extends StatefulWidget {
  final String currentUserEmail;

  const PortfolioWidget({
    super.key,
    required this.currentUserEmail,
  });

  @override
  State<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends State<PortfolioWidget> {
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() {
      posts = BoardModel().getPosts(widget.currentUserEmail) as List<Map<String, dynamic>>;
    });
  }

  void _goToWritePost() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => WritePost(onPostSaved: _fetchPosts, userEmail: widget.currentUserEmail,),
    //   ),
    // );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: posts.isEmpty
          ? Center(child: Text('새 글을 작성해 주세요.'))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostBox(
            post: post,
            currentUserEmail: widget.currentUserEmail,
            onPostModified: _fetchPosts,
          );
        },
      ),
      floatingActionButton: posts.any((post) => post['userEmail'] == widget.currentUserEmail)
          ? FloatingActionButton(
        onPressed: _goToWritePost,
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}
