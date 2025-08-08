import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_screen.dart';
import 'full_profile_screen.dart';

class ChatListScreen extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser;

  ChatListScreen({super.key});

  void _showProfileDetails(BuildContext context, String email, bool isOnline, String phone, String name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.tealAccent.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.tealAccent[400],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "+91 $phone",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isOnline ? Colors.green.withOpacity(0.2) : Colors.grey[800],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 10, color: isOnline ? Colors.green : Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      color: isOnline ? Colors.tealAccent[400] : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey[700]),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.tealAccent[400]),
              title: const Text("View full profile", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullProfileScreen(email: email, name: name, phone: phone),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message_outlined, color: Colors.tealAccent[400]),
              title: const Text("Send message", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Chat Users", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.tealAccent[400]),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent[400]!),
              ),
            );
          }

          if (snap.hasError) {
            return const Center(
              child: Text("Error loading users", style: TextStyle(color: Colors.white)),
            );
          }

          final users = snap.data!.docs.where((d) => d.id != currentUser!.uid).toList();

          if (users.isEmpty) {
            return const Center(
              child: Text("No users found", style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (ctx, i) {
              final user = users[i];
              final userData = user.data() as Map<String, dynamic>? ?? {};
              final isOnline = userData['isOnline'] ?? false;
              final email = userData['email'] ?? '';
              final phone = userData['phone'] ?? '';
              final name = userData['name'] ?? '';

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: GestureDetector(
                    onTap: () => _showProfileDetails(context, email, isOnline, phone, name),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.tealAccent.withOpacity(0.15),
                          child: Icon(Icons.person, color: Colors.tealAccent[400]),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey[850]!,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      color: isOnline ? Colors.tealAccent[400] : Colors.grey[500],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          otherName: name,
                          otherPhone: phone,
                          currentUserId: currentUser!.uid,
                          otherUserId: user.id,
                          otherEmail: email,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
