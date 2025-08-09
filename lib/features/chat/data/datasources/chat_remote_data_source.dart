import 'dart:typed_data';
import 'package:chatapp/features/chat/domain/entites/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
  import 'package:uuid/uuid.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final SupabaseClient supabase;

  ChatRemoteDataSource({
    required this.firestore,
    required this.supabase,
  });

  Stream<List<ChatMessageEntity>> getMessages(String chatId) {
    return firestore
        .collection('chats/$chatId/messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChatMessageEntity.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> sendMessage(ChatMessageEntity message) async {
    final chatId = _getChatId(message.senderId, message.receiverId);
    await firestore.collection('chats/$chatId/messages').add(message.toMap());
  }


Future<void> uploadFile({
  required String fileName,
  required List<int> bytes,
  required String chatId,
  required String senderId,
  required String receiverId,
  String? mimeType,
}) async {
  final storage = supabase.storage.from('uploads');
  final detectedMime = mimeType ?? lookupMimeType(fileName) ?? 'application/octet-stream';

  final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}_$fileName';

  await storage.uploadBinary(
    uniqueName,
    Uint8List.fromList(bytes),
    fileOptions: FileOptions(contentType: detectedMime),
  );

  final url = storage.getPublicUrl(uniqueName);

  String fileType;
  final ext = fileName.split('.').last.toLowerCase();
  if (['jpg', 'jpeg', 'png'].contains(ext)) {
    fileType = 'image';
  } else if (['mp4', 'mov'].contains(ext)) {
    fileType = 'video';
  } else {
    fileType = 'file';
  }

  final message = ChatMessageEntity(
    id: '',
    senderId: senderId,
    receiverId: receiverId,
    content: url,
    type: fileType,
    timestamp: Timestamp.now(),
    isRead: false,
  );
  await sendMessage(message);
}


  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    await firestore.collection('typing').doc(chatId).set(
      {userId: isTyping},
      SetOptions(merge: true),
    );
  }

  Stream<bool> getOnlineStatus(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map((doc) {
      return doc.data()?['isOnline'] ?? false;
    });
  }

  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    final messages = await firestore
        .collection('chats/$chatId/messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  String _getChatId(String u1, String u2) {
    final ids = [u1, u2]..sort();
    return ids.join('_');
  }
}
