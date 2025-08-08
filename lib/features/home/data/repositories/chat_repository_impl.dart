import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/home/domain/entites/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remote;

  ChatRepositoryImpl(this.remote);

  @override
  Stream<List<ChatMessageEntity>> getMessages(String user1, String user2) =>
      remote.getMessages(user1, user2);

 @override
Stream<List<UserEntity>> getUsers() {
  return remote.getUsers();
}

  @override
  Future<void> sendMessage(ChatMessageEntity msg) {
    final model = ChatMessageModel(
      id: msg.id,
      senderId: msg.senderId,
      receiverId: msg.receiverId,
      message: msg.message,
      imageUrl: msg.imageUrl,
      timestamp: msg.timestamp,
      type: msg.type,
    );
    return remote.sendMessage(model);
  }

  @override
  Future<void> uploadImage(String chatId, String senderId, String receiverId, String filePath) =>
      remote.uploadImage(chatId, senderId, receiverId, filePath,);

  @override
  Stream<bool> isUserTyping(String chatId, String userId) =>
      remote.isUserTyping(chatId, userId);

  @override
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) =>
      remote.setTypingStatus(chatId, userId, isTyping);
}
