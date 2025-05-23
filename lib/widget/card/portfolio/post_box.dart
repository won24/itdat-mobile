import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';
import 'package:itdat/utils/HttpClientManager.dart';
import 'package:itdat/widget/card/portfolio/PDFViewer.dart';
import 'package:itdat/widget/card/portfolio/TextFileViewr.dart';
import 'package:itdat/widget/card/portfolio/downloadAndSaveFile.dart';
import 'package:itdat/widget/card/portfolio/write_post.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../setting/waitwidget.dart';
import 'package:url_launcher/url_launcher.dart';

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


  // 이미지 렌더링
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

  // 문서 전체 주소
  String getFullDocumentUrl(String fileUrl) {
    final baseUrl = "${dotenv.env['BASE_URL']}";
    if (fileUrl.startsWith('http://') || fileUrl.startsWith('https://')) {
      return fileUrl;
    } else {
      return '$baseUrl$fileUrl';
    }
  }


  // 문서 렌더링
  Widget _buildFileViewer(String fileUrl) {
    final fileExtension = fileUrl.split('.').last;
    String fullUrl = getFullDocumentUrl(fileUrl);
    print("fullUrl: $fullUrl");
    switch (fileExtension) {
      case 'pdf':
        return FutureBuilder<String?>(
          future: downloadAndSaveFile(fullUrl),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFViewer(documentUrl: snapshot.data!),
                      ),
                    );
                  },
                  child: Text(
                    "PDF 파일 보기",
                    // style( TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))
                  )
              );
            } else {
              return Text("PDF를 불러오는 데 실패했습니다.");
            }
          },
        );
      case 'txt':
        return TextFileViewer(textFileUrl: fullUrl);
      case 'gif':
        return _buildMediaContent(fullUrl);
      default:
        return Row(
          children: [
            Text("지원되지 않는 파일 형식입니다."),
            SizedBox(width: 10,),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                color: Colors.grey.shade200,
                width: 1.0,
                ),
                borderRadius: BorderRadius.circular(25),
                ),
                child:IconButton(
                  onPressed: () async {
                    if (await canLaunchUrl(Uri.parse(fileUrl))) {
                      await launchUrl(Uri.parse(fileUrl));
                    } else {
                      _showSnackBar(context, "파일 열기 실패", isError: true);
                    }
                  },
                  icon: Icon(Icons.folder_open_sharp,color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                )
            ),
          ],
        );
    }
  }





  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                Text(
                    widget.post['title'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    )),
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
            // 이미지 렌더링
            if (widget.post['fileUrl'] != null && widget.post['fileUrl'].isNotEmpty)
              _buildMediaContent(widget.post['fileUrl']),

            Text(widget.post['content'] ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),),
            SizedBox(height: 10),

            // 링크 렌더링
            if (widget.post['linkUrl'] != null && widget.post['linkUrl'].isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "링크: ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (await canLaunchUrl(Uri.parse('https:${widget.post['linkUrl']}'))) {
                        await launchUrl(Uri.parse('https:${widget.post['linkUrl']}'));
                      } else {
                        _showSnackBar(context, "링크 연결 불가", isError: true);
                      }
                    },
                    child: Text(
                      widget.post['linkUrl']!,
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 15
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            if (widget.post['documentUrl'] != null && widget.post['documentUrl'].isNotEmpty)
              _buildFileViewer(widget.post['documentUrl']),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
