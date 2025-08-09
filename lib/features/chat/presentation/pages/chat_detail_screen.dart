import 'dart:io';
import 'dart:typed_data';
import 'package:chatapp/features/auth/presentation/pages/widgets/dot_loader.dart';
import 'package:chatapp/features/chat/presentation/pages/full_profile_screen.dart';
import 'package:chatapp/features/chat/presentation/pages/widgets/video_player.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_detail_bloc.dart';
import '../bloc/chat_detail_event.dart';
import '../bloc/chat_detail_state.dart';


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
    required this.otherEmail,
    this.otherPhone,
    required this.otherName,
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
  final FocusNode _msgFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    List<String> ids = [
      widget.currentUserId,
      widget.otherUserId,
    ];
    ids.sort();
    chatId = ids.join("_");

    context.read<ChatDetailBloc>().add(ChatInitialized(
      currentUserId: widget.currentUserId,
      otherUserId: widget.otherUserId,
    ));

    _setTyping(false);
    context.read<ChatDetailBloc>().add(MarkRead(chatId: chatId, currentUserId: widget.currentUserId));
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _msgFocusNode.unfocus();
  });
}

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  void _setTyping(bool isTyping) {
    context.read<ChatDetailBloc>().add(SetTyping(chatId: chatId, userId: widget.currentUserId, isTyping: isTyping));
  }

  Future<void> _sendMessage(String content, String type) async {
    if (content.trim().isEmpty) return;
    context.read<ChatDetailBloc>().add(SendTextMessage(
          content: content,
          chatId: chatId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUserId,
        ));
    msgController.clear();
    _setTyping(false);

    await Future.delayed(const Duration(milliseconds: 100));
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'mp4', 'mov'],
    );
    if (result == null) return;

    final file = result.files.first;
    final mimeType = lookupMimeType(file.name) ?? 'application/octet-stream';
    final ext = file.extension?.toLowerCase() ?? '';
    final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
    final isVideo = ['mp4', 'mov'].contains(ext);
    final fileType = isImage ? 'image' : isVideo ? 'video' : 'file';

    // call upload usecase via bloc
    context.read<ChatDetailBloc>().add(UploadAndSendFile(
          fileName: file.name,
          bytes: file.bytes!.toList(),
          mimeType: mimeType,
          chatId: chatId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUserId,
          fileType: fileType,
        ));
  }

  void _showFullScreenImage(String imageUrl) {
      _msgFocusNode.unfocus(); 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
      _msgFocusNode.unfocus(); 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                  _msgFocusNode.unfocus(); 
                Navigator.pop(context);
              },
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
          content: const Text('Downloading file...',style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.black,
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
          style: const TextStyle(color: Colors.white),
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
                child: const Center(
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
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
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
            padding: const EdgeInsets.all(12),
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
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
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
                              phone: widget.otherPhone ?? "",
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
                          BlocBuilder<ChatDetailBloc, ChatDetailState>(
                            builder: (context, state) {
                              return state.otherUserOnline
                                  ? Positioned(
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
                                    )
                                  : const SizedBox();
                            },
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
                            widget.otherName,
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
                              if (!snap.hasData) return const SizedBox();
                              final data = snap.data!.data() as Map<String, dynamic>?;
                              final typing = data?[widget.otherUserId] ?? false;
                              return typing
                                  ? const Padding(
                                      padding: EdgeInsets.only(right: 12),
                                      child: Text(
                                        "Typing...",
                                        style: TextStyle(
                                          color: Colors.tealAccent,
                                        ),
                                      ),
                                    )
                                  : SizedBox();
                                  // BlocBuilder<ChatDetailBloc, ChatDetailState>(
                                  //     builder: (context, state) {
                                  //       return Text(
                                  //         "",
                                  //        // state.otherUserOnline ? "Online" : "Offline",
                                  //         style: TextStyle(
                                  //           color: state.otherUserOnline ? Colors.green : Colors.grey,
                                  //           fontSize: 12,
                                  //         ),
                                  //       );
                                  //     },
                                  //   );
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
                  child: BlocBuilder<ChatDetailBloc, ChatDetailState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: DotLoader(height: 10));
                      }

                      final docs = state.messages;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (scrollController.hasClients) {
                          scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: docs.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (ctx, i) {
                          final msg = docs[i];
                          final isMe = msg.senderId == widget.currentUserId;
                          final content = msg.content;
                          final type = msg.type;
                          final isRead = msg.isRead;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: isMe ? 55 : 8,
                                right: !isMe ? 55 : 8,
                                bottom: 8,
                                top: 8,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.teal[800] : Colors.grey[800],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  _buildMessageContent(type, content, isMe),
                                  if (isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatTimestamp(msg.timestamp),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 10,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            isRead ? Icons.done_all : Icons.done,
                                            size: 14,
                                            color: isRead ? Colors.blue : Colors.white70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (!isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _formatTimestamp(msg.timestamp),
                                        style: const TextStyle(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
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
                        child: TextField(  focusNode: _msgFocusNode,

                          controller: msgController,
                          onChanged: (val) => _setTyping(val.isNotEmpty),
                          style:  TextStyle(color: Colors.black),
                          cursorColor: Colors.grey[800],
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
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
}

