import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:chatapp/features/chat/domain/entites/chat_message.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class ChatInitialized extends ChatDetailEvent {
  final String currentUserId;
  final String otherUserId;

  const ChatInitialized({required this.currentUserId, required this.otherUserId});

  @override
  List<Object?> get props => [currentUserId, otherUserId];
}

class MessagesUpdated extends ChatDetailEvent {
  final List<ChatMessageEntity> messages;

  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SendTextMessage extends ChatDetailEvent {
  final String content;
  final String chatId;
  final String senderId;
  final String receiverId;

  const SendTextMessage({
    required this.content,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
  });

  @override
  List<Object?> get props => [content, chatId, senderId, receiverId];
}

class UploadAndSendFile extends ChatDetailEvent {
  final String fileName;
  final List<int> bytes;
  final String mimeType;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String fileType;

  const UploadAndSendFile({
    required this.fileName,
    required this.bytes,
    required this.mimeType,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.fileType,
  });

  @override
  List<Object?> get props => [fileName, bytes, mimeType, chatId, senderId, receiverId, fileType];
}

class SetTyping extends ChatDetailEvent {
  final String chatId;
  final String userId;
  final bool isTyping;

  const SetTyping({required this.chatId, required this.userId, required this.isTyping});

  @override
  List<Object?> get props => [chatId, userId, isTyping];
}

class MarkRead extends ChatDetailEvent {
  final String chatId;
  final String currentUserId;

  const MarkRead({required this.chatId, required this.currentUserId});

  @override
  List<Object?> get props => [chatId, currentUserId];
}
