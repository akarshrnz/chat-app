
import 'package:chatapp/features/home/domain/entites/chat_message.dart';
import 'package:chatapp/features/home/domain/entites/product_entity.dart';

import '../../../auth/domain/entities/user_entity.dart';

abstract class HomeRepository {
  Stream<List<ProductEntity>> getProducts();
  Stream<List<UserEntity>> getUsers();
  Future<void> sendMessage(String fromUserId, String toUserId, String message,String chatID);
  Stream<List<ChatMessageEntity>> getMessages(String fromUserId, String toUserId);
  Future<void> mirrorUser(String fromUserId, String toUserId);
  Future<void> cancelMirror(String userId);
  Stream<String?> listenToMirror(String userId);
  Future<void> sendScrollOffset(String fromUserId, double offset);
  Stream<double> listenToScroll(String userId);
}
