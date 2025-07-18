import 'package:chatapp/features/home/domain/entites/chat_message.dart';
import 'package:chatapp/features/home/domain/entites/product_entity.dart';

import '../repositories/home_repository.dart';

import '../../../auth/domain/entities/user_entity.dart';

class HomeUseCases {
  final HomeRepository repository;

  HomeUseCases(this.repository);

  Stream<List<ProductEntity>> getProducts() => repository.getProducts();
  Stream<List<UserEntity>> getUsers() => repository.getUsers();
  Future<void> sendMessage(String fromUserId, String toUserId, String message,String id) =>
      repository.sendMessage(fromUserId, toUserId, message,id);
  Stream<List<ChatMessageEntity>> getMessages(String fromUserId, String toUserId) =>
      repository.getMessages(fromUserId, toUserId);
  Future<void> mirrorUser(String fromUserId, String toUserId) =>
      repository.mirrorUser(fromUserId, toUserId);
  Future<void> cancelMirror(String userId) => repository.cancelMirror(userId);
  Stream<String?> listenToMirror(String userId) =>
      repository.listenToMirror(userId);
  Future<void> sendScrollOffset(String fromUserId, double offset) =>
      repository.sendScrollOffset(fromUserId, offset);
  Stream<double> listenToScroll(String userId) =>
      repository.listenToScroll(userId);
}
