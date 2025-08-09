import 'package:chatapp/features/chat/domain/entites/chat_message.dart';

import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;

  ChatRepositoryImpl({required this.remote});

  @override
  Stream<List<ChatMessageEntity>> getMessages(String chatId) => remote.getMessages(chatId);

  @override
  Future<void> sendMessage(ChatMessageEntity message) => remote.sendMessage(message);

  @override
  Future<void> uploadFile({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    required String chatId,
    required String senderId,
    required String receiverId,
    required String fileType,
  }) => remote.uploadFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
      );

  @override
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) =>
      remote.setTypingStatus(chatId, userId, isTyping);

  @override
  Stream<bool> getOnlineStatus(String userId) => remote.getOnlineStatus(userId);

  @override
  Future<void> markMessagesAsRead(String chatId, String currentUserId) =>
      remote.markMessagesAsRead(chatId, currentUserId);
}
