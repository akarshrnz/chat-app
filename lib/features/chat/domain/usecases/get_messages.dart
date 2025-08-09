import 'package:chatapp/features/chat/domain/entites/chat_message.dart';

import '../repositories/chat_repository.dart';

class GetMessages {
  final ChatRepository repository;
  GetMessages(this.repository);

  Stream<List<ChatMessageEntity>> call(String chatId) {
    return repository.getMessages(chatId);
  }
}
