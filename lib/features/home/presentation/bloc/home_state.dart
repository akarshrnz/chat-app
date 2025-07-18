import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/home/domain/entites/chat_message.dart';
import 'package:chatapp/features/home/domain/entites/product_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class ProductsLoaded extends HomeState {
  final List<ProductEntity> products;
  final String currentUserId;
  ProductsLoaded(this.products, this.currentUserId);
}

class UsersLoaded extends HomeState {
  final List<UserEntity> users;
  final String currentUserId;
  UsersLoaded(this.users, this.currentUserId);
}

class MessagesLoaded extends HomeState {
  final List<ChatMessageEntity> messages;
  MessagesLoaded(this.messages);
}

class MirrorStatusChanged extends HomeState {
  final String? mirroredToUserId;
  MirrorStatusChanged(this.mirroredToUserId);
}

class ScrollOffsetUpdated extends HomeState {
  final double offset;
  ScrollOffsetUpdated(this.offset);
}

class MessageDeleted extends HomeState {}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
