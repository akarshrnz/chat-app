import '../repositories/chat_repository.dart';

class SetTypingStatus {
  final ChatRepository repository;
  SetTypingStatus(this.repository);

  Future<void> call(String chatId, String userId, bool isTyping) {
    return repository.setTypingStatus(chatId, userId, isTyping);
  }
}
