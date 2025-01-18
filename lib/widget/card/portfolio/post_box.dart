import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';
import 'package:itdat/utils/HttpClientManager.dart';
import 'package:itdat/widget/card/portfolio/write_post.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../setting/waitwidget.dart';


class PostBox extends StatefulWidget {
  final Map<String, dynamic> post;
  final String currentUserEmail;
  final VoidCallback onPostModified;

  const PostBox({
    super.key,
    required this.currentUserEmail,
    required this.onPostModified,
    required this.post,
  });

  @override
  _PostBoxState createState() => _PostBoxState();
}

class _PostBoxState extends State<PostBox> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.post['fileUrl'] != null &&
        widget.post['fileUrl'].endsWith('.mp4')) {
      _initializeVideoPlayer(widget.post['fileUrl']);
    }
  }


  Future<bool> checkFileExists(String url) async {
    final client = await HttpClientManager().createHttpClient();
    try {
      final response = await client.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String getFullImageUrl(String fileUrl) {
    final baseUrl = "${dotenv.env['BASE_URL']}";
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    } else {
      return '$baseUrl$fileUrl';
    }
  }


  String getFullVideoUrl(String fileUrl) {
    final baseUrl = "${dotenv.env['BASE_URL']}";
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    } else {
      print('$baseUrl$fileUrl');
      return '$baseUrl$fileUrl';
    }
  }


  void _initializeVideoPlayer(String videoUrl) async{
    final fullUrl = getFullVideoUrl(videoUrl);

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(fullUrl))
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
        }).catchError((e) {
          print('Error loading video: $e');
        });
    }catch (e){
      print('동영상 로딩 에러 : $e');
    }
  }


  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoController?.pause();
      } else {
        _videoController?.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }


  Widget _buildMediaContent(String fileUrl) {
    if (fileUrl.endsWith('.mp4')) {
      return FutureBuilder<bool>(
        future: checkFileExists(getFullVideoUrl(fileUrl)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: WaitAnimationWidget());
          } else if (snapshot.hasData && snapshot.data == true) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 250,
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
                VideoProgressIndicator(_videoController!, allowScrubbing: true),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40.0,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      );
    } else {
      return FutureBuilder<bool>(
        future: checkFileExists(getFullImageUrl(fileUrl)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: WaitAnimationWidget());
          } else if (snapshot.hasData && snapshot.data == true) {
            return Container(
              width: double.infinity,
              height: 250,
              child: Image.network(
                getFullImageUrl(fileUrl),
                fit: BoxFit.contain,
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      );
    }
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


  void _editPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WritePost(
              onPostSaved: widget.onPostModified,
              post: widget.post,
              userEmail: widget.currentUserEmail,
            ),
      ),
    );
  }


  void _deletePost(BuildContext context) async {
    try {
      await BoardModel().deletePost(widget.post['id']);
      _showSnackBar(context, "게시글 삭제 완료");
      widget.onPostModified();
    } catch (e) {
      _showSnackBar(context, "게시글 삭제 실패. 다시 시도해주세요.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.post['title'], style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
                if (widget.post['userEmail'] == widget.currentUserEmail)
                  Align(
                    alignment: Alignment.topRight,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _editPost(context);
                        if (value == 'delete') _deletePost(context);
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
            if (widget.post['fileUrl'] != null && widget.post['fileUrl'].isNotEmpty)
              _buildMediaContent(widget.post['fileUrl']),
            Text(widget.post['content'] ?? ''),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
