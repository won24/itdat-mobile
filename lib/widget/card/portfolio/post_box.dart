import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';
import 'package:itdat/widget/card/portfolio/write_post.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('fileUrl: ${widget.post['fileUrl']}');
    if (widget.post['fileUrl'] != null &&
        widget.post['fileUrl'].endsWith('.mp4')) {
      _initializeVideoPlayer(widget.post['fileUrl']);
    }
  }

  // 파일이 있는 지 확인
  Future<bool> checkFileExists(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }


  // 이미지 가져오기
  String getFullImageUrl(String fileUrl) {
    const baseUrl = 'http://112.221.66.174:8001';
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    } else {
      return '$baseUrl$fileUrl';
    }
  }

  // 동영상 가져오기
  String getFullVideoUrl(String fileUrl) {
    const baseUrl = 'http://112.221.66.174:8001';
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    } else {
      return '$baseUrl$fileUrl';
    }
  }

  // 동영상 컨트롤러 초기화
  void _initializeVideoPlayer(String videoUrl) {
    final fullUrl = getFullVideoUrl(videoUrl);
    _videoController = VideoPlayerController.networkUrl(Uri.parse(fullUrl))
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((e) {
        setState(() {
          _isLoading = false;
        });
        print('Error loading video: $e');
      });
  }

  // 동영상 재생/일시정지
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
    _videoController?.dispose(); // 컨트롤러 해제
    super.dispose();
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

  // 수정
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

  // 삭제
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
              FutureBuilder<bool>(
                future: checkFileExists(getFullImageUrl(widget.post['fileUrl'])),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData && snapshot.data == true) {
                    if (widget.post['fileUrl'].endsWith('.mp4') &&
                        _videoController != null &&
                        _videoController!.value.isInitialized) {
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
                          VideoProgressIndicator(
                              _videoController!, allowScrubbing: true),
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
                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 250,
                            child: Image.network(
                              getFullImageUrl(widget.post['fileUrl']),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      );
                    }
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            Text(widget.post['content'] ?? ''),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
