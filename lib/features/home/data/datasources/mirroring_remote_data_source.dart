import 'package:firebase_database/firebase_database.dart';

class MirrorRemoteDataSource {
  final FirebaseDatabase database;

  MirrorRemoteDataSource(this.database);

  Future<void> mirrorUser(String fromUserId, String toUserId) async {
    await database.ref('mirror/$toUserId').set(fromUserId);
  }

  Future<void> cancelMirror(String userId) async {
    await database.ref('mirror/$userId').remove();
  }

  Stream<String?> listenToMirror(String userId) {
    return database
        .ref('mirror/$userId')
        .onValue
        .map((event) => event.snapshot.value as String?);
  }

  Future<void> sendScrollOffset(String fromUserId, double offset) async {
    await database.ref('scroll/$fromUserId').set(offset);
  }

  Stream<double> listenToScroll(String userId) {
    return database.ref('scroll/$userId').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return 0.0;
    });
  }
}
