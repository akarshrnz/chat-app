import 'package:chatapp/features/home/data/datasources/mirroring_remote_data_source.dart';
import 'package:chatapp/features/home/domain/repositories/home_repository.dart';
import 'package:chatapp/features/home/domain/entites/chat_message.dart';
import 'package:chatapp/features/home/domain/entites/product_entity.dart';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import '../datasources/chat_remote_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/chat_message_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ChatRemoteDataSource chatDataSource;
  final ProductRemoteDataSource productDataSource;
  final MirrorRemoteDataSource mirrorDataSource;

  HomeRepositoryImpl({
    required this.chatDataSource,
    required this.productDataSource,
    required this.mirrorDataSource,
  });

  @override
  Stream<List<ProductEntity>> getProducts() {
    return productDataSource.getProducts();
  }

  @override
  Stream<List<UserEntity>> getUsers() {
    return chatDataSource.getUsers();
  }

  @override
  Future<void> sendMessage(
      String fromUserId, String toUserId, String message,String chatId) {
    final model = ChatMessageModel(
      id: chatId,
      senderId: fromUserId,
      receiverId: toUserId,
      message: message,
      timestamp: DateTime.now(),
    );
    return chatDataSource.sendMessage(model);
  }

  @override
  Stream<List<ChatMessageEntity>> getMessages(
      String fromUserId, String toUserId) {
    return chatDataSource.getMessages(fromUserId, toUserId);
  }


  @override
  Future<void> mirrorUser(String fromUserId, String toUserId) {
    return mirrorDataSource.mirrorUser(fromUserId, toUserId);
  }

  @override
  Future<void> cancelMirror(String userId) {
    return mirrorDataSource.cancelMirror(userId);
  }

  @override
  Stream<String?> listenToMirror(String userId) {
    return mirrorDataSource.listenToMirror(userId);
  }

  @override
  Future<void> sendScrollOffset(String fromUserId, double offset) {
    return mirrorDataSource.sendScrollOffset(fromUserId, offset);
  }

  @override
  Stream<double> listenToScroll(String userId) {
    return mirrorDataSource.listenToScroll(userId);
  }
}
