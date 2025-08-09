import '../repositories/chat_repository.dart';

class MarkMessagesRead {
  final ChatRepository repository;
  MarkMessagesRead(this.repository);

  Future<void> call(String chatId, String currentUserId) {
    return repository.markMessagesAsRead(chatId, currentUserId);
  }
}
