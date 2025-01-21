import 'dart:io';
import 'package:flutter/material.dart';
import 'package:itdat/models/board_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../setting/waitwidget.dart';
import 'package:file_picker/file_picker.dart';


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
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _fileUrlController = TextEditingController();
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _linkUrlController = TextEditingController();

  File? _selectedFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  String? _linkUrl;
  File? _selectedDocument;
  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _titleController.text = widget.post!['title'] ?? '';
      _contentController.text = widget.post!['content'] ?? '';
      _linkUrlController.text = widget.post!['linkUrl'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _fileUrlController.dispose();
    _videoController?.dispose();
    super.dispose();
  }


  // 사진, 동영상
  Future<void> _pickMedia({required bool isVideo}) async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('갤러리 권한이 필요합니다.')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
        _isVideo = isVideo;
        _fileUrlController.text = pickedFile.path;

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

  Future<bool> requestStoragePermission() async {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        var status = await Permission.manageExternalStorage.request();
        if (status.isGranted) {
          return true;
        } else {
          print('권한 거부됨: ${status.toString()}');
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


  // 링크
  void _showLinkInput(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String link = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            top: 16.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "링크 추가",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "링크를 입력해주세요.",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "링크를 입력해주세요.";
                    }
                    final validUri = Uri.tryParse(value.startsWith('http') ? value : 'https://$value');
                    if (validUri == null || !validUri.isAbsolute) {
                      return "올바른 주소로 입력해 주세요.";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    link = value;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                      child: Text("취소", style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _linkUrl = link;
                            _linkUrlController.text = link;
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text("추가",style: TextStyle(color: Color.fromRGBO(0, 202, 145, 1), fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // 문서
  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      setState(() {
        _selectedDocument = File(result.files.single.path!);
        _documentController.text = result.files.single.path!;
      });
    } else {
      _showSnackBar("문서 선택이 취소되었습니다.", isError: true);
    }
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
        title: Text(widget.post == null ? '새 글 작성' : '포트폴리오 수정: ${widget.post!['title']}'),
        actions: [
          TextButton(
            onPressed: () {
              final postData = {
                'userEmail': widget.userEmail,
                'title': _titleController.text,
                'content': _contentController.text,
                'fileUrl': _fileUrlController.text,
                'linkUrl' : _linkUrlController.text,
                'documentUrl': _documentController.text
              };
              widget.post == null
                  ? _savePost(context, postData)
                  : _editPost(context, postData);
            },
            child: widget.post == null
                ? Text('저장', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 202, 145, 1)))
                : Text('수정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 202, 145, 1))),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: '제목',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(202, 202, 202, 1.0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(0, 202, 145, 1)),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: "내용을 입력하세요.",
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(202, 202, 202, 1.0)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(0, 202, 145, 1)),
                    ),
                  ),
                  style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                  maxLines: 20,
                ),
                const SizedBox(height: 16),

                IconButton(
                  style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.black87,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.image),
                                title: Text('이미지'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickMedia(isVideo: false);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.description),
                                title: Text('문서'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickDocument();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.link),
                                title: Text('링크'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showLinkInput(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.add, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,),
                ),
                
                const SizedBox(height: 16),
                if (_selectedFile != null)
                  _isVideo
                    ? _videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                      )
                      : const WaitAnimationWidget()
                    : Image.file(
                        _selectedFile!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                   ),

                if (_linkUrl != null && _linkUrl!.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "링크: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse('https:$_linkUrl'))) {
                            await launchUrl(Uri.parse('https:$_linkUrl'));
                          } else {
                            _showSnackBar("링크 연결 불가", isError: true);
                          }
                        },
                        child: Text(
                          _linkUrl!,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 15
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel_rounded),
                        onPressed: () {
                          setState(() {
                            _linkUrl = null;
                            _linkUrlController.clear();
                          });
                        },
                      ),
                    ],
                  ),

                if (_selectedDocument != null)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "선택된 문서: ${_documentController.text}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.cancel_rounded),
                        onPressed: () {
                          setState(() {
                            _selectedDocument = null;
                            _documentController.clear();
                          });
                        },
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