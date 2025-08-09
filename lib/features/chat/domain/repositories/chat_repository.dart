
import 'package:chatapp/features/chat/domain/entites/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> getMessages(String chatId);
  Future<void> sendMessage(ChatMessageEntity message);
  Future<void> uploadFile({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    required String chatId,
    required String senderId,
    required String receiverId,
    required String fileType, 
  });
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping);
  Stream<bool> getOnlineStatus(String userId);
  Future<void> markMessagesAsRead(String chatId, String currentUserId);
}
