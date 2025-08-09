import 'package:chatapp/features/chat/domain/entites/chat_message.dart';

import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<void> call(ChatMessageEntity message) {
    return repository.sendMessage(message);
  }
}
