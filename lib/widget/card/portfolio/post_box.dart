import 'package:flutter/material.dart';
import 'package:itdat/widget/card/portfolio/write_post.dart';

class PostBox extends StatelessWidget {
  final Map<String, dynamic> post;
  final String currentUserEmail;
  final VoidCallback onPostModified;

  const PostBox({
    super.key,
    required this.currentUserEmail,
    required this.onPostModified,
    required this.post
  });


  // 수정
  void _editPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WritePost(
          onPostSaved: onPostModified,
          post: post,
          userEmail: currentUserEmail
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post['fileUrl'] != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(post['fileUrl'], fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(post['content'] ?? ''),
              ],
            ),
          ),
          if (post['userEmail'] == currentUserEmail)
            Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _editPost(context);
                  if (value == 'delete') onPostModified();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text('수정')),
                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

