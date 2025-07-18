import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSource(
    this.firestore,
  );

  Future<
    void
  >
  sendMessage(
    ChatMessageModel message,
  ) async {
    await firestore
        .collection(
          'chats',
        )
        .doc(
          message.id,
        )
        .collection(
          'messages',
        )
        .add(
          {
            'text': message.message,
            'senderId': message.senderId,
            'timestamp': FieldValue.serverTimestamp(),
            'read': false,
          },
        );
  }

  Stream<
    List<
      ChatMessageModel
    >
  >
  getMessages(
    String user1,
    String user2,
  ) {
    final docId = _chatDocId(
      user1,
      user2,
    );
    return firestore
        .collection(
          'chats',
        )
        .doc(
          docId,
        )
        .collection(
          'messages',
        )
        .orderBy(
          'timestamp',
        )
        .snapshots()
        .map(
          (
            snapshot,
          ) => snapshot.docs
              .map(
                (
                  doc,
                ) => ChatMessageModel.fromJson(
                  doc.data(),
                  doc.id,
                ),
              )
              .toList(),
        );
  }

  Future<
    void
  >
  deleteMessage(
    String user1,
    String user2,
    String messageId,
  ) async {
    final docId = _chatDocId(
      user1,
      user2,
    );
    await firestore
        .collection(
          'chats',
        )
        .doc(
          docId,
        )
        .collection(
          'messages',
        )
        .doc(
          messageId,
        )
        .delete();
  }

  Stream<
    List<
      UserEntity
    >
  >
  getUsers() {
    return firestore
        .collection(
          'users',
        )
        .snapshots()
        .map(
          (
            snapshot,
          ) {
            return snapshot.docs.map(
              (
                doc,
              ) {
                final data = doc.data();
                return UserEntity(
                  userId: doc.id,
                  uid: doc.id,
                  email:
                      data['email'] ??
                      '',
                );
              },
            ).toList();
          },
        );
  }

  String _chatDocId(
    String user1,
    String user2,
  ) {
    final ids = [
      user1,
      user2,
    ]..sort();
    return ids.join(
      '_',
    );
  }
}
