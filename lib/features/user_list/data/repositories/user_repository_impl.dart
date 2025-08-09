import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Stream<List<UserEntity>> getAllUsers(String currentUserId) {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }
}
