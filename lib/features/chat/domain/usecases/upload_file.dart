import '../repositories/chat_repository.dart';

class UploadFile {
  final ChatRepository repository;
  UploadFile(this.repository);

  Future<void> call({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    required String chatId,
    required String senderId,
    required String receiverId,
    required String fileType,
  }) {
    return repository.uploadFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      fileType: fileType,
    );
  }
}
