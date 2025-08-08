
import 'package:chatapp/features/home/domain/entites/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel extends ChatMessageEntity {
  ChatMessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.message,
    required super.type,
    required super.timestamp,
    super.imageUrl,
    super.isTyping,
  });

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'imageUrl': imageUrl,
    'timestamp': timestamp,
    'isTyping': isTyping,
    'type': type,
  };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatMessageModel(
      id: id,
      senderId: json['senderId'],
      type: json['type'],
      receiverId: json['receiverId'],
      message: json['message'],
      imageUrl: json['imageUrl'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isTyping: json['isTyping'] ?? false,
    );
  }
}
