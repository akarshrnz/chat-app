import 'dart:async';
import 'package:chatapp/features/auth/domain/entities/user_entity.dart';
import 'package:chatapp/features/home/presentation/bloc/home_bloc.dart';
import 'package:chatapp/features/home/presentation/bloc/home_event.dart';
import 'package:chatapp/features/home/presentation/bloc/home_state.dart';
import 'package:chatapp/features/home/presentation/pages/chat_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late HomeBloc _bloc;
  String? _currentMirroringTo;
  StreamSubscription<QuerySnapshot>? _mirrorSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I<HomeBloc>();
    _bloc.add(LoadUsers());
    _listenToMyMirrorStatus();
  }

  void _listenToMyMirrorStatus() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    _mirrorSubscription = FirebaseFirestore.instance
        .collection('mirrors')
        .where('mirroredBy', isEqualTo: currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _currentMirroringTo =
            snapshot.docs.isNotEmpty ? snapshot.docs.first.id : null;
      });
    });
  }

  Future<void> _setMirror(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final existing = await FirebaseFirestore.instance
        .collection('mirrors')
        .where('mirroredBy', isEqualTo: currentUserId)
        .get();

    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    await FirebaseFirestore.instance
        .collection('mirrors')
        .doc(targetUserId)
        .set({'mirroredBy': currentUserId});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mirror started"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.tealAccent[400],
        ),
      );
    }
  }

  Future<void> _cancelMirror() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final query = await FirebaseFirestore.instance
        .collection('mirrors')
        .where('mirroredBy', isEqualTo: currentUserId)
        .get();

    for (var doc in query.docs) {
      await doc.reference.delete();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mirror cancelled"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.redAccent[400],
        ),
      );
    }
  }

  void _showMirrorConfirmationDialog(UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.screen_share,
                size: 50,
                color: Colors.tealAccent,
              ),
              const SizedBox(height: 16),
              Text(
                "Mirror ${user.email}?",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "This will allow the user to see your screen",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _setMirror(user.uid);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Mirror",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mirrorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            "Chat Users",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          elevation: 0,
          actions: [
            if (_currentMirroringTo != null)
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: _cancelMirror,
                tooltip: 'Cancel Mirror',
              ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is UsersLoaded) {
              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
              final users = state.users.where((u) => u.uid != currentUserId).toList();

              if (users.isEmpty) {
                return const Center(
                  child: Text(
                    "No other users available",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isMirroringThisUser = _currentMirroringTo == user.uid;

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.tealAccent.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.tealAccent[400],
                        ),
                      ),
                      title: Text(
                        user.email ?? 'Unnamed User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(otherUser: user,currentUserId: currentUserId??"",),
                        ),
                      ),
                      trailing: Container(
                      //  height: 35,
                        decoration: BoxDecoration(
                          gradient: isMirroringThisUser
                              ? LinearGradient(
                                  colors: [Colors.redAccent[400]!, Colors.red[700]!])
                              : LinearGradient(
                                  colors: [Colors.tealAccent[400]!, Colors.blueAccent[400]!]),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: isMirroringThisUser 
        ? Colors.redAccent[400]
        : Colors.tealAccent[400],
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    elevation: 2,
  ),
  onPressed: () {
    if (isMirroringThisUser) {
      _cancelMirror();
    } else {
      _showMirrorConfirmationDialog(user);
    }
  },
  child: Text(
    isMirroringThisUser ? "STOP MIRROR" : "START MIRROR",
    style: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  ),
),
                    ),
                  ));
                },
              );
            } else if (state is HomeError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.tealAccent,
              ),
            );
          },
        ),
      ),
    );
  }
}