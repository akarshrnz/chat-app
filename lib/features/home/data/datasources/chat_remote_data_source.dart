import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ChatRemoteDataSource(this.firestore, this.storage);

  Future<void> sendMessage(ChatMessageModel msg) async {
    final docId = _chatDocId(msg.senderId, msg.receiverId);
    await firestore
        .collection('chats')
        .doc(docId)
        .collection('messages')
        .add(msg.toJson());
  }

  Stream<List<ChatMessageModel>> getMessages(String user1, String user2) {
    final docId = _chatDocId(user1, user2);
    return firestore
        .collection('chats')
        .doc(docId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessageModel.fromJson(doc.data(), doc.id)).toList());
  }

  Future<void> uploadImage(
      String chatId, String senderId, String receiverId, String filePath,) async {
    final fileName = filePath.split('/').last;
    final ref = storage.ref().child('chat_images/$chatId/$fileName');
    final upload = await ref.putFile(File(filePath));
    final imageUrl = await upload.ref.getDownloadURL();

    final message = ChatMessageModel(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      message: '',
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
      type: "image"
    );

    await sendMessage(message);
  }

  Stream<bool> isUserTyping(String chatId, String userId) {
    return firestore.collection('typing').doc(chatId).snapshots().map((doc) {
      return doc.data()?['$userId'] ?? false;
    });
  }

  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    await firestore
        .collection('typing')
        .doc(chatId)
        .set({userId: isTyping}, SetOptions(merge: true));
  }

 Stream<List<UserEntity>> getUsers() {
  return firestore.collection('users').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserEntity(
        uid: data['uid'] ?? '',
        email: data['email'] ?? '',
        userId: data['userId'] ?? '',
      );
    }).toList();
  });
}

  String _chatDocId(String u1, String u2) {
    final sorted = [u1, u2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
