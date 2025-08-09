import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String type;
  final Timestamp timestamp;
  final bool isRead;

  ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  factory ChatMessageEntity.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessageEntity(
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
}
