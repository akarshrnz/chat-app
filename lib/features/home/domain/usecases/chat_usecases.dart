import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/home/domain/entites/chat_message.dart';

import '../repositories/chat_repository.dart';

class ChatUseCases {
  final ChatRepository repository;

  ChatUseCases(this.repository);
Stream<List<UserEntity>> getUsers() => repository.getUsers();
  Stream<List<ChatMessageEntity>> getMessages(String u1, String u2) =>
      repository.getMessages(u1, u2);

  Future<void> sendMessage(ChatMessageEntity msg) =>
      repository.sendMessage(msg);

  Future<void> uploadImage(String chatId, String senderId, String receiverId, String path) =>
      repository.uploadImage(chatId, senderId, receiverId, path);

  Stream<bool> isUserTyping(String chatId, String userId) =>
      repository.isUserTyping(chatId, userId);

  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) =>
      repository.setTypingStatus(chatId, userId, isTyping);
}
