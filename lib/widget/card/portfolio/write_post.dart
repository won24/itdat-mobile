import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:itdat/models/board_model.dart';
import 'package:video_player/video_player.dart';

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

  List<File> _newFiles = []; // 새로 추가된 파일
  List<Map<String, dynamic>> _existingFiles = []; // 서버에서 로드된 기존 파일
  List<VideoPlayerController?> _videoControllers = [];

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      titleController.text = widget.post!['title'] ?? '';
      contentController.text = widget.post!['content'] ?? '';
      _loadExistingFiles(); // 서버에서 기존 파일 로드
    }
  }

  @override
  void dispose() {
    // 비디오 컨트롤러 해제
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }


  Future<void> _loadExistingFiles() async {
    final dynamic files = widget.post?['files'];

    if (files is List) {
      // 파일 리스트를 Map<String, dynamic>으로 안전하게 변환
      setState(() {
        _existingFiles = files.map<Map<String, dynamic>>((file) {
          if (file is Map<String, dynamic>) {
            return file; // 파일이 Map<String, dynamic> 타입일 경우 그대로 사용
          } else if (file is String) {
            // 파일이 URL 문자열일 경우 Map 형식으로 변환
            return {'url': file, 'type': 'unknown', 'name': file.split('/').last};
          } else {
            // 예상하지 못한 파일 타입인 경우 예외 처리
            throw Exception("Unexpected file type: ${file.runtimeType}");
          }
        }).toList();

        _videoControllers = _existingFiles.map((file) {
          if (file['type'] == 'video' && file['url'] != null) {
            final controller = VideoPlayerController.networkUrl(Uri.parse(file['url']))
              ..initialize().then((_) {
                setState(() {}); // 비디오 준비 상태 갱신
              });
            return controller;
          }
          return null;
        }).toList();
      });
    } else if (files == null) {
      // files가 null일 경우 빈 리스트로 초기화
      setState(() {
        _existingFiles = [];
        _videoControllers = [];
      });
    } else {
      // files가 List가 아닌 경우 예외 처리
      throw Exception("Expected 'files' to be a List, but got ${files.runtimeType}");
    }
  }


  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _newFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  void _deleteFile({int? existingIndex, int? newIndex}) {
    setState(() {
      if (existingIndex != null) {
        _existingFiles.removeAt(existingIndex);
        _videoControllers[existingIndex]?.dispose();
        _videoControllers.removeAt(existingIndex);
      } else if (newIndex != null) {
        _newFiles.removeAt(newIndex);
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? '새 글 작성' : '게시글 수정: ${widget
            .post!['title']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '제목'),
            ),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: '내용'),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickFiles,
              icon: const Icon(Icons.file_upload),
              label: const Text('파일 추가 (사진/동영상)'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _existingFiles.length + _newFiles.length,
                itemBuilder: (context, index) {
                  final isExistingFile = index < _existingFiles.length;

                  // 타입에 따라 파일 객체를 구분
                  final file = isExistingFile
                      ? _existingFiles[index]
                      : _newFiles[index - _existingFiles.length];

                  // 파일 데이터 확인
                  if (isExistingFile) {
                    final url = file['url'] as String?;
                    final type = file['type'] as String?;

                    if (url == null || type == null) {
                      throw Exception("Invalid existing file data: $file");
                    }
                  }


                  // 이미지/동영상 여부를 파일 타입에 따라 처리
                  final isImage = isExistingFile
                      ? file['type'] == 'image'
                      : file is File &&
                      (file.path.endsWith('.png') ||
                          file.path.endsWith('.jpg') ||
                          file.path.endsWith('.jpeg'));

                  final isVideo = isExistingFile
                      ? file['type'] == 'video' // 기존 파일의 경우
                      : file is File && file.path.endsWith('.mp4'); // 새 파일의 경우

                  final videoController =
                  isExistingFile ? _videoControllers[index] : null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // 이미지 또는 동영상 미리보기
                        if (isImage)
                          isExistingFile
                              ? Image.network(file['url'], height: 100, width: 100, fit: BoxFit.cover)
                              : Image.file(file as File, height: 100, width: 100, fit: BoxFit.cover)
                        else if (isVideo && videoController != null && videoController.value.isInitialized)
                          AspectRatio(
                            aspectRatio: videoController.value.aspectRatio,
                            child: VideoPlayer(videoController),
                          ),
                        const SizedBox(width: 10),
                        // 파일 이름 표시
                        Expanded(
                          child: Text(
                            isExistingFile
                              ? file['name'] // 기존 파일의 경우
                              : (file as File).path.split('/').last, // 새 파일의 경우
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // 삭제 버튼
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                            _deleteFile(
                              existingIndex: isExistingFile ? index : null,
                              newIndex: isExistingFile ? null : index - _existingFiles.length),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final postData = {
                  'userEmail': widget.userEmail,
                  'title': titleController.text,
                  'content': contentController.text,
                  'existingFiles': _existingFiles, // 유지되는 기존 파일
                  'newFiles': _newFiles, // 새로 추가된 파일 경로
                };
                if (widget.post == null) {
                  BoardModel().savePost(
                      postData, newFiles: _newFiles); // 새 글 저장
                } else {
                  BoardModel().editPost(
                      postData, widget.post?['id'], newFiles: _newFiles); // 수정
                }
                widget.onPostSaved();
                Navigator.pop(context);
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}