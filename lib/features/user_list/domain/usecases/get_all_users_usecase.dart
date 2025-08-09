import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetAllUsersUseCase {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  Stream<List<UserEntity>> call(String currentUserId) {
    return repository.getAllUsers(currentUserId);
  }
}
