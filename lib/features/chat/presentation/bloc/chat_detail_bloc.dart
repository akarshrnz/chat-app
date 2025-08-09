import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chatapp/features/chat/domain/entites/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/upload_file.dart';
import '../../domain/usecases/set_typing_status.dart';
import '../../domain/usecases/get_online_status.dart';
import '../../domain/usecases/mark_messages_read.dart';
import 'chat_detail_event.dart';
import 'chat_detail_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final UploadFile uploadFile;
  final SetTypingStatus setTypingStatus;
  final GetOnlineStatus getOnlineStatus;
  final MarkMessagesRead markMessagesRead;

  StreamSubscription<List<ChatMessageEntity>>? _messagesSub;
  StreamSubscription<bool>? _onlineSub;

  ChatDetailBloc({
    required this.getMessages,
    required this.sendMessage,
    required this.uploadFile,
    required this.setTypingStatus,
    required this.getOnlineStatus,
    required this.markMessagesRead,
  }) : super(const ChatDetailState()) {
    on<ChatInitialized>(_onInitialized);
    // use the public event type here
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendTextMessage>(_onSendTextMessage);
    on<UploadAndSendFile>(_onUploadAndSendFile);
    on<SetTyping>(_onSetTyping);
    on<MarkRead>(_onMarkRead);
  }

  Future<void> _onInitialized(ChatInitialized event, Emitter<ChatDetailState> emit) async {
    final ids = [event.currentUserId, event.otherUserId]..sort();
    final chatId = ids.join('_');

    emit(state.copyWith(isLoading: true));

    await _messagesSub?.cancel();
    _messagesSub = getMessages(chatId).listen((messages) {
      add(MessagesUpdated(messages));
    });

    await _onlineSub?.cancel();
    _onlineSub = getOnlineStatus(event.otherUserId).listen((isOnline) {
      emit(state.copyWith(otherUserOnline: isOnline));
    });

    await markMessagesRead(chatId, event.currentUserId);

    emit(state.copyWith(isLoading: false));
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatDetailState> emit) {
    emit(state.copyWith(messages: event.messages));
  }

  Future<void> _onSendTextMessage(SendTextMessage event, Emitter<ChatDetailState> emit) async {
    if (event.content.trim().isEmpty) return;
    final message = ChatMessageEntity(
      id: '',
      senderId: event.senderId,
      receiverId: event.receiverId,
      content: event.content,
      type: 'text',
      timestamp: Timestamp.now(),
      isRead: false,
    );
    await sendMessage(message);
  }

  Future<void> _onUploadAndSendFile(UploadAndSendFile event, Emitter<ChatDetailState> emit) async {
    await uploadFile.call(
      fileName: event.fileName,
      bytes: event.bytes,
      mimeType: event.mimeType,
      chatId: event.chatId,
      senderId: event.senderId,
      receiverId: event.receiverId,
      fileType: event.fileType,
    );
  }

  Future<void> _onSetTyping(SetTyping event, Emitter<ChatDetailState> emit) async {
    await setTypingStatus.call(event.chatId, event.userId, event.isTyping);
  }

  Future<void> _onMarkRead(MarkRead event, Emitter<ChatDetailState> emit) async {
    await markMessagesRead.call(event.chatId, event.currentUserId);
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    _onlineSub?.cancel();
    return super.close();
  }
}
