import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../home/domain/entites/chat_message.dart';
import '../../domain/usecases/chat_usecases.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUseCases useCases;

  ChatBloc(this.useCases) : super(ChatInitial()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<UploadImageEvent>(_onUploadImage);
    on<SetTypingStatusEvent>(_onSetTypingStatus);
    on<StartTypingListenerEvent>(_onStartTypingListener);
  }

  void _onLoadUsers(LoadUsersEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    await emit.forEach<List<UserEntity>>(
      useCases.repository.getUsers(),
      onData: (users) => UsersLoadedState(users: users),
      onError: (_, __) => ChatError("Failed to load users"),
    );
  }

  void _onLoadMessages(LoadMessagesEvent event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    await emit.forEach<List<ChatMessageEntity>>(
      useCases.getMessages(event.currentUserId, event.otherUserId),
      onData: (messages) => MessagesLoadedState(messages: messages),
      onError: (_, __) => ChatError("Failed to load messages"),
    );
  }

  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    await useCases.sendMessage(event.message);
  }

  void _onUploadImage(UploadImageEvent event, Emitter<ChatState> emit) async {
    await useCases.uploadImage(event.chatId, event.senderId, event.receiverId, event.imagePath);
  }

  void _onSetTypingStatus(SetTypingStatusEvent event, Emitter<ChatState> emit) async {
    await useCases.setTypingStatus(event.chatId, event.userId, event.isTyping);
  }

  void _onStartTypingListener(StartTypingListenerEvent event, Emitter<ChatState> emit) async {
    await emit.forEach<bool>(
      useCases.isUserTyping(event.chatId, event.userId),
      onData: (isTyping) => TypingStatusChangedState(isTyping: isTyping),
      onError: (_, __) => ChatError("Typing status failed"),
    );
  }
}
