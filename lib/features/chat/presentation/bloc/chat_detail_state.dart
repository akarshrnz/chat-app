import 'package:chatapp/features/chat/domain/entites/chat_message.dart';
import 'package:equatable/equatable.dart';

class ChatDetailState extends Equatable {
  final bool isLoading;
  final List<ChatMessageEntity> messages;
  final bool showEmoji;
  final bool otherUserOnline;

  const ChatDetailState({
    this.isLoading = false,
    this.messages = const [],
    this.showEmoji = false,
    this.otherUserOnline = false,
  });

  ChatDetailState copyWith({
    bool? isLoading,
    List<ChatMessageEntity>? messages,
    bool? showEmoji,
    bool? otherUserOnline,
  }) {
    return ChatDetailState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      showEmoji: showEmoji ?? this.showEmoji,
      otherUserOnline: otherUserOnline ?? this.otherUserOnline,
    );
  }

  @override
  List<Object?> get props => [isLoading, messages, showEmoji, otherUserOnline];
}
