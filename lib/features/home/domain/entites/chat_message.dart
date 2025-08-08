class ChatMessageEntity {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String type;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.type,
    this.imageUrl,
    required this.timestamp,
    this.isTyping = false,
  });
}
