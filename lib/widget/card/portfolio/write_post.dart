import 'dart:io';
import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';

class WritePost extends StatefulWidget {
  final Function onPostSaved;
  final Map<String, dynamic>? post;
  final String userEmail;

  const WritePost({
    super.key,
    required this.onPostSaved,
    this.post,
    required this.userEmail,
  });

  @override
  State<WritePost> createState() => _WritePostState();
}

class _WritePostState extends State<WritePost> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController fileUrlController = TextEditingController();

  File? _selectedFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      titleController.text = widget.post!['title'] ?? '';
      contentController.text = widget.post!['content'] ?? '';
      fileUrlController.text = '';
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia({required bool isVideo}) async {
    // 갤러리 권한 확인 및 요청
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리 권한이 필요합니다.')),
      );
      return;
    }

    // 미디어 선택 로직
    final picker = ImagePicker();
    final pickedFile = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
        _isVideo = isVideo;
        fileUrlController.text = pickedFile.path;

        if (_isVideo) {
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(_selectedFile!)
            ..initialize().then((_) {
              setState(() {});
              _videoController!.play();
            });
        }
      });
    }
  }


  // 갤러리 권한 받기
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status; // 권한 상태 확인
    if (status.isGranted) {
      return true; // 이미 권한이 허용된 경우
    } else {
      var result = await Permission.storage.request(); // 권한 요청
      if (result.isGranted) {
        return true; // 권한 허용된 경우
      } else {
        // 권한 거부된 경우 처리
        print('갤러리 권한이 거부되었습니다.');
        return false;
      }
    }
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


  // 저장
  void _savePost(BuildContext context, postData) async {
    try {
      await BoardModel().savePost(postData);
      _showSnackBar("게시글 저장 완료");
      widget.onPostSaved();
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar("게시글 저장 실패. 다시 시도해주세요.", isError: true);
    }
  }

  // 수정
  void _editPost(BuildContext context, postData) async {
    try {
      await BoardModel().editPost(postData, widget.post?['id']);
      widget.onPostSaved();
      Navigator.pop(context);
      _showSnackBar("게시글 수정 완료");
    } catch (e) {
      _showSnackBar("게시글 수정 실패. 다시 시도해주세요.", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? '새 글 작성' : '게시글 수정: ${widget.post!['title']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '제목'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: 10,
              ),
              TextField(
                controller: fileUrlController,
                decoration: const InputDecoration(labelText: '파일 URL (선택)'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickMedia(isVideo: false),
                    icon: const Icon(Icons.photo),
                    label: const Text('이미지 선택'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickMedia(isVideo: true),
                    icon: const Icon(Icons.videocam),
                    label: const Text('동영상 선택'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_selectedFile != null)
                _isVideo
                    ? _videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                )
                    : const CircularProgressIndicator()
                    : Image.file(
                  _selectedFile!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final postData = {
                    'userEmail': widget.userEmail,
                    'title': titleController.text,
                    'content': contentController.text,
                    'fileUrl': fileUrlController.text,
                  };
                  widget.post == null
                      ? _savePost(context, postData)
                      : _editPost(context, postData);
                },
                child: widget.post == null ? const Text('저장') : const Text('수정'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}