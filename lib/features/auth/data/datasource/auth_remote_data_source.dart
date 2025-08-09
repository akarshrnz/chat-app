import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource(this._auth, this._firestore);

  Future<User?> register(String email, String password,String name, String phone) async {
    print("name is inside data sourc $name, phone is $phone");
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCred.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'email': email,
        'name': name,
        'phone': phone,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_id', user.uid);
    }
   return user;
  }

  Future<User?> login(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCred.user;

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_id', user.uid);
    }

    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  User? getCurrentUser() => _auth.currentUser;
}
