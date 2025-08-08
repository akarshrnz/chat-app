import 'dart:io';
import 'dart:typed_data';
import 'package:chatapp/features/auth/presentation/pages/widgets/dot_loader.dart';
import 'package:chatapp/features/home/presentation/pages/full_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';

class ChatDetailScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherEmail;
  final String? otherPhone;
  final String otherName;

  const ChatDetailScreen({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherEmail, this.otherPhone, required this.otherName,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final msgController = TextEditingController();
  final scrollController = ScrollController();
  bool showEmoji = false;
  late String chatId;
  final Dio _dio = Dio();
  bool _isOtherUserOnline = false;

  @override
  void initState() {
    super.initState();
    List<String> ids = [
      widget.currentUserId,
      widget.otherUserId,
    ];
    ids.sort();
    chatId = ids.join("_");
    _setTyping(false);
    _setupOnlineStatusListener();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  void _setupOnlineStatusListener() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _isOtherUserOnline = snapshot.data()?['isOnline'] ?? false;
        });
      }
    });
  }

  void _markMessagesAsRead() async {
    final messages = await FirebaseFirestore.instance
        .collection('chats/$chatId/messages')
        .where('receiverId', isEqualTo: widget.currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  void _setTyping(bool isTyping) {
    FirebaseFirestore.instance
        .collection('typing')
        .doc(chatId)
        .set(
          {
            widget.currentUserId: isTyping,
          },
          SetOptions(merge: true),
        );
  }

  Future<void> _sendMessage(String content, String type) async {
    if (content.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('chats/$chatId/messages')
        .add({
          'senderId': widget.currentUserId,
          'receiverId': widget.otherUserId,
          'content': content,
          'type': type,
          'timestamp': Timestamp.now(),
          'isRead': false,
        });
    msgController.clear();
    _setTyping(false);

    await Future.delayed(Duration(milliseconds: 100));
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 60,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'mp4', 'mov'],
    );
    if (result == null) return;

    final file = result.files.first;
    final storage = Supabase.instance.client.storage.from('uploads');
    final mimeType = lookupMimeType(file.name);

    await storage.uploadBinary(
      file.name,
      file.bytes!,
      fileOptions: FileOptions(
        contentType: mimeType ?? 'application/octet-stream',
      ),
    );

    final url = storage.getPublicUrl(file.name);
    final isImage = ['jpg', 'jpeg', 'png'].contains(file.extension?.toLowerCase());
    final isVideo = ['mp4', 'mov'].contains(file.extension?.toLowerCase());

    _sendMessage(
      url,
      isImage ? 'image' : isVideo ? 'video' : 'file',
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  void _showVideoPlayer(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: VideoPlayerScreen(videoUrl: videoUrl),
          ),
        ),
      ),
    );
  }

  Future<void> _openFile(String url, String fileName) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      final directory = await getExternalStorageDirectory();
      final savePath = '${directory?.path}/$fileName';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading file...'),
          backgroundColor: Colors.tealAccent[400],
        ),
      );

      try {
        await _dio.download(url, savePath);

        final result = await OpenFile.open(savePath);

        if (result.type != ResultType.done) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file: ${result.message}'),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file: ${e.toString()}'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isVisible) {
        if (!isVisible) _setTyping(false);

        return Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.grey[900],
            flexibleSpace: SafeArea(
              child: Container(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullProfileScreen(
                              name: widget.otherName,
                              phone: widget.otherPhone??"",
                              email: widget.otherEmail,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.tealAccent.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              color: Colors.tealAccent[400],
                            ),
                          ),
                          if (_isOtherUserOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey[900]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.otherName ?? "",
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              
                            ),
                          ),
                          const SizedBox(height: 2),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('typing')
                                .doc(chatId)
                                .snapshots(),
                            builder: (_, snap) {
                              if (!snap.hasData) return SizedBox();
                              final data = snap.data!.data() as Map<String, dynamic>?;
                              final typing = data?[widget.otherUserId] ?? false;
                              return typing
                                  ? Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Text(
                                        "Typing...",
                                        style: TextStyle(
                                          color: Colors.tealAccent[400],
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _isOtherUserOnline ? "Online" : "Offline",
                                      style: TextStyle(
                                        color: _isOtherUserOnline
                                            ? Colors.green
                                            : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white70),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.grey[850]!,
                        Colors.grey[900]!,
                      ],
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats/$chatId/messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (ctx, snap) {
                      if (!snap.hasData) {
                        return Center(
                          child: DotLoader(
                            height: 10,
                          
                          ),
                        );
                      }

                      final docs = snap.data!.docs;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (scrollController.hasClients) {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: docs.length,
                        padding: EdgeInsets.all(8),
                        itemBuilder: (ctx, i) {
                          final msg = docs[i].data() as Map<String, dynamic>;
                          final isMe = msg['senderId'] == widget.currentUserId;
                          final content = msg['content'] ?? '';
                          final type = msg['type'] ?? 'text';
                          final isRead = msg['isRead'] ?? false;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: isMe ? 55 : 8,
                                right: !isMe ? 55 : 8,
                                bottom: 8,
                                top: 8,
                              ),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.teal[800]
                                    : Colors.grey[800],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                  bottomLeft: isMe
                                      ? Radius.circular(12)
                                      : Radius.circular(4),
                                  bottomRight: isMe
                                      ? Radius.circular(4)
                                      : Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  _buildMessageContent(type, content, isMe),
                                  if (isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatTimestamp(msg['timestamp']),
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            isRead
                                                ? Icons.done_all
                                                : Icons.done,
                                            size: 14,
                                            color: isRead
                                                ? Colors.blue
                                                : Colors.white70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (!isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _formatTimestamp(msg['timestamp']),
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              if (showEmoji)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      msgController.text += emoji.emoji;
                    },
                  ),
                ),
              Container(
                color: Colors.grey[850],
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                child: Row(
                  children: [
                    InkWell(
                      child: Icon(
                        Icons.emoji_emotions,
                        color: Colors.tealAccent[400],
                      ),
                      onTap: () => setState(() => showEmoji = !showEmoji),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_file,
                        color: Colors.tealAccent[400],
                      ),
                      onPressed: _pickFile,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: msgController,
                          onChanged: (val) => _setTyping(val.isNotEmpty),
                          style: TextStyle(color: Colors.grey[800]),
                          cursorColor: Colors.grey[800],
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.tealAccent[400],
                      ),
                      onPressed: () => _sendMessage(msgController.text, 'text'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
    }
  }

  Widget _buildMessageContent(String type, String content, bool isMe) {
    switch (type) {
      case 'text':
        return Text(
          content,
          style: TextStyle(color: Colors.white),
        );
      case 'image':
        return GestureDetector(
          onTap: () => _showFullScreenImage(content),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              content,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[800],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.tealAccent[400]!,
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[800],
                child: Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      case 'video':
        return GestureDetector(
          onTap: () => _showVideoPlayer(content),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                color: Colors.grey[800],
                child: Icon(
                  Icons.play_circle_filled,
                  size: 50,
                  color: Colors.tealAccent[400]!.withOpacity(0.8),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'file':
      default:
        final fileName = content.split('/').last;
        final isPdf = fileName.toLowerCase().endsWith('.pdf');
        final isDoc = fileName.toLowerCase().endsWith('.doc') ||
            fileName.toLowerCase().endsWith('.docx');

        return GestureDetector(
          onTap: () => _openFile(content, fileName),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPdf
                      ? Icons.picture_as_pdf
                      : isDoc
                          ? Icons.description
                          : Icons.insert_drive_file,
                  color: Colors.tealAccent[400],
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isPdf ? 'Tap to download and view' : 'Tap to open',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, 
    required this.videoUrl,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                if (!_isPlaying)
                  IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      size: 50,
                      color: Colors.tealAccent[400],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPlaying = true;
                        _controller.play();
                      });
                    },
                  ),
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.tealAccent[400]!,
              ),
            ),
          );
  }
}