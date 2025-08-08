import 'package:chatapp/features/auth/data/datasource/auth_remote_data_source.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepository implements AuthRepositoryInterface {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository(this._remoteDataSource);

  @override
  Future<UserEntity?> register(String email, String password,String name, String phone) async {
    final user = await _remoteDataSource.register(email, password,name,phone);
    if (user != null) {
      return UserEntity(uid: user.uid, email: email, userId: user.uid);
    }
    return null;
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    final user = await _remoteDataSource.login(email, password);
    if (user != null) {
      final data = await _remoteDataSource.getUserData(user.uid);
      return UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        userId: data?['userId'] ?? user.uid,
      );
    }
    return null;
  }

  @override
  Future<void> logout() async => _remoteDataSource.logout();

  @override
  UserEntity? getCurrentUser() {
    final user = _remoteDataSource.getCurrentUser();
    if (user != null) {
      return UserEntity(uid: user.uid, email: user.email ?? '', userId: user.uid);
    }
    return null;
  }
}
