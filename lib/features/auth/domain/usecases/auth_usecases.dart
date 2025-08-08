import 'package:chatapp/features/auth/domain/repositories/auth_repository.dart';

import '../entities/user_entity.dart';

class AuthUseCases {
  final AuthRepositoryInterface repository;

  AuthUseCases(this.repository);

  Future<UserEntity?> register(String email, String password,String name, String phone) {
    return repository.register(email, password,name,phone);
  }

  Future<UserEntity?> login(String email, String password) {
    return repository.login(email, password);
  }

  Future<void> logout() => repository.logout();

  UserEntity? get currentUser => repository.getCurrentUser();
}
