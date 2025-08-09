part of 'chat_list_bloc.dart';

abstract class ChatListEvent {}

class LoadUsersEvent extends ChatListEvent {
  final String currentUserId;
  LoadUsersEvent(this.currentUserId);
}

class UsersUpdatedEvent extends ChatListEvent {
  final List<UserEntity> users;
  UsersUpdatedEvent(this.users);
}
