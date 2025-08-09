import 'package:flutter/material.dart';
import 'dart:math';

class FullProfileScreen extends StatelessWidget {
  final String name;
  final String phone;
  final String email;

  const FullProfileScreen({
    required this.name,
    required this.phone, required this.email,
  });

  Color getRandomColor() {
    final random = Random(name.hashCode);
    return Color.fromARGB(
      255,
      100 + random.nextInt(156),
      100 + random.nextInt(156),
      100 + random.nextInt(156),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          CircleAvatar(
            radius: 60,
            backgroundColor: getRandomColor(),
            child: Text(
              initial,
              style: TextStyle(fontSize: 40, color: Colors.white),
            ),
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(height: 8),
          Text(
          "+91 "+  phone,
            style: TextStyle(color: Colors.grey[400]),
          ),
          SizedBox(height: 24),
          Divider(color: Colors.grey[700]),
          ListTile(
            leading: Icon(Icons.call, color: Colors.tealAccent[400]),
            title: Text("Voice Call", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.videocam, color: Colors.tealAccent[400]),
            title: Text("Video Call", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.search, color: Colors.tealAccent[400]),
            title: Text("Search", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.tealAccent[400]),
            title: Text("Mute Notifications", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
