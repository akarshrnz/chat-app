import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entites/chat_message.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({
    required String id,
    required String senderId,
    required String receiverId,
    required String content,
    required String type,
    required Timestamp timestamp,
    required bool isRead,
  }) : super(
          id: id,
          senderId: senderId,
          receiverId: receiverId,
          content: content,
          type: type,
          timestamp: timestamp,
          isRead: isRead,
        );

  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessageModel(
      id: id,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      content: map['content'] as String,
      type: map['type'] as String? ?? 'text',
      timestamp: map['timestamp'] as Timestamp,
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      content: entity.content,
      type: entity.type,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
    );
  }

  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: type,
      timestamp: timestamp,
      isRead: isRead,
    );
  }
}
