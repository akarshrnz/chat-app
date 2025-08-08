import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/domain/entites/chat_message.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String currentUserId;
  final String otherUserId;

  LoadMessagesEvent(this.currentUserId, this.otherUserId);

  @override
  List<Object?> get props => [currentUserId, otherUserId];
}

class SendMessageEvent extends ChatEvent {
  final ChatMessageEntity message;

  SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class UploadImageEvent extends ChatEvent {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String imagePath;

  UploadImageEvent(this.chatId, this.senderId, this.receiverId, this.imagePath);

  @override
  List<Object?> get props => [chatId, senderId, receiverId, imagePath];
}

class SetTypingStatusEvent extends ChatEvent {
  final String chatId;
  final String userId;
  final bool isTyping;

  SetTypingStatusEvent(this.chatId, this.userId, this.isTyping);

  @override
  List<Object?> get props => [chatId, userId, isTyping];
}

class StartTypingListenerEvent extends ChatEvent {
  final String chatId;
  final String userId;

  StartTypingListenerEvent(this.chatId, this.userId);

  @override
  List<Object?> get props => [chatId, userId];
}
