import '../repositories/chat_repository.dart';

class GetOnlineStatus {
  final ChatRepository repository;
  GetOnlineStatus(this.repository);

  Stream<bool> call(String userId) {
    return repository.getOnlineStatus(userId);
  }
}
