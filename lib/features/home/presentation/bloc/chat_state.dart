import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/domain/entites/chat_message.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class UsersLoadedState extends ChatState {
  final List<UserEntity> users;

  UsersLoadedState({required this.users});

  @override
  List<Object?> get props => [users];
}

class MessagesLoadedState extends ChatState {
  final List<ChatMessageEntity> messages;

  MessagesLoadedState({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class TypingStatusChangedState extends ChatState {
  final bool isTyping;

  TypingStatusChangedState({required this.isTyping});

  @override
  List<Object?> get props => [isTyping];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
