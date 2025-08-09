import 'package:chatapp/features/chat/presentation/pages/chat_detail_screen.dart';
import 'package:chatapp/features/chat/presentation/pages/full_profile_screen.dart';
import 'package:chatapp/injection_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/chat_list_bloc.dart';


class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatListBloc>()..add(LoadUsersEvent(currentUser.uid)),
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          leading: SizedBox(),
          centerTitle: true,
          title: const Text("Chat App...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.grey[900],
          iconTheme: IconThemeData(color: Colors.tealAccent[400]),
          elevation: 0,
        ),
        body: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatListError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
            }

            if (state is ChatListLoaded) {
              if (state.users.isEmpty) {
                return const Center(child: SizedBox());
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: state.users.length,
                itemBuilder: (ctx, i) {
                  final user = state.users[i];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: InkWell(
                        onTap: () {
                           _showProfileDetails(context, user);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.tealAccent.withOpacity(0.15),
                          child: Icon(Icons.person, color: Colors.tealAccent[400]),
                        ),
                      ),
                      title: Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        user.email,
                        style: TextStyle(color: user.isOnline ? Colors.tealAccent[400] : Colors.grey[500]),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            currentUserId: currentUser.uid,
                            otherUserId: user.id,
                            otherName: user.name,
                            otherPhone: user.phone,
                            otherEmail: user.email,
                          ),
                        ),
                      ),
                      onLongPress: () => _showProfileDetails(context, user),
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showProfileDetails(BuildContext context, UserEntity user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50, color: Colors.tealAccent[400])),
            const SizedBox(height: 18),
            Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("+91 ${user.phone}", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
            const SizedBox(height: 12),
            Text(user.isOnline ? "Online" : "Offline", style: TextStyle(color: user.isOnline ? Colors.tealAccent[400] : Colors.grey[500])),
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
                    builder: (_) => FullProfileScreen(email: user.email, name: user.name, phone: user.phone),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message_outlined, color: Colors.tealAccent[400]),
              title: const Text("Send message", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            currentUserId: currentUser.uid,
                            otherUserId: user.id,
                            otherName: user.name,
                            otherPhone: user.phone,
                            otherEmail: user.email,
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
