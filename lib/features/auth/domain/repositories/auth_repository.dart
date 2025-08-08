import '../entities/user_entity.dart';

abstract class AuthRepositoryInterface {
  Future<UserEntity?> register(String email, String password,String name, String phone );
  Future<UserEntity?> login(String email, String password);
  Future<void> logout();
  UserEntity? getCurrentUser();
}
