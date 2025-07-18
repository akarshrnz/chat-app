import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/home/domain/entites/chat_message.dart';

abstract class HomeEvent {}

class LoadProducts extends HomeEvent {}

class LoadUsers extends HomeEvent {}

class SendMessage extends HomeEvent {
  final String fromUserId;
  final String toUserId;
  final String message;
  final String id;

  SendMessage(this.fromUserId, this.toUserId, this.message,this.id);
}

class GetMessages extends HomeEvent {
  final String fromUserId;
  final String toUserId;

  GetMessages(this.fromUserId, this.toUserId);
}

class MirrorUser extends HomeEvent {
  final String fromUserId;
  final String toUserId;

  MirrorUser(this.fromUserId, this.toUserId);
}

class CancelMirror extends HomeEvent {
  final String userId;

  CancelMirror(this.userId);
}

class SendScrollOffset extends HomeEvent {
  final String fromUserId;
  final double offset;

  SendScrollOffset(this.fromUserId, this.offset);
}

class ListenToScroll extends HomeEvent {
  final String userId;

  ListenToScroll(this.userId);
}

class ListenToMirror extends HomeEvent {
  final String userId;

  ListenToMirror(this.userId);
}

class DeleteMessage extends HomeEvent {
  final String messageId;

  DeleteMessage(this.messageId);
}
