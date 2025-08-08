
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/home/domain/entites/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> getMessages(String user1, String user2);
  Future<void> sendMessage(ChatMessageEntity message);
  Future<void> uploadImage(String chatId, String senderId, String receiverId, String filePath);
  Stream<bool> isUserTyping(String chatId, String userId);
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping);
Stream<List<UserEntity>> getUsers();

}
