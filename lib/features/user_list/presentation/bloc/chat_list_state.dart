part of 'chat_list_bloc.dart';



abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<UserEntity> users;
  ChatListLoaded(this.users);
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);
}
