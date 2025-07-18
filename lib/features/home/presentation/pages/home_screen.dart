import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/features/home/presentation/pages/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  late String currentUserId;
  String? _mirroredByUserId;
  String? _mirroredToUserId;
  bool _isActivelyMirroring = false;
  late final Stream<DocumentSnapshot> _mirrorStream;

  // Sample product data with images, names and descriptions
    final List<Map<String, dynamic>> products = [
    {
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8aGVhZHBob25lc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
      'name': 'Sony Headphones',
      'description': 'Noise-cancelling with 40hr battery life',
      'price': '₹199.99'
    },
    {
      'image': 'https://images.unsplash.com/photo-1512054502232-10a0a035d672?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGhvbmV8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60',
      'name': 'Iphone 14',
      'description': '6.7" AMOLED, 256GB storage',
      'price': '₹899.99'
    },
    {
      'image': 'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bGFwdG9wfGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60',
      'name': 'Laptop',
      'description': '14" 4K display, 16GB RAM',
      'price': '₹1,299.99'
    },
    {
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8d2F0Y2h8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60',
      'name': 'Cosmic Smartwatch',
      'description': 'Health tracking, 7-day battery',
      'price': '₹349.99'
    },
    {
      'image': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Y2FtZXJhfGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60',
      'name': 'Galaxy Camera 7',
      'description': '24MP, 4K video recording',
      'price': '₹599.99'
    },
    {
      'image': 'https://images.unsplash.com/photo-1579829366248-204fe8413f31?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8ZHJvbmV8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60',
      'name': 'Indian Drone',
      'description': '4K camera, 30min flight time',
      'price': '₹499.99'
    },
     {
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8aGVhZHBob25lc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
      'name': 'Boat Headphones 5',
      'description': 'Noise-cancelling with 40hr battery life',
      'price': '₹199.99'
    },
    {
      'image': 'https://images.unsplash.com/photo-1512054502232-10a0a035d672?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cGhvbmV8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=500&q=60',
      'name': 'Realmi Phone 6',
      'description': '6.7" AMOLED, 256GB storage',
      'price': '₹899.99'
    },
  ];


  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _initializeMirroring();
    _fetchMyMirrorStatus();
  }

 

  void _initializeMirroring() {
    _mirrorStream = FirebaseFirestore.instance
        .collection('mirrors')
        .doc(currentUserId)
        .snapshots();

    _mirrorStream.listen((doc) {
      if (!mounted) return;

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final mirroredBy = data['mirroredBy'] as String?;
        final scrollOffset = data['scrollOffset'] as double?;

        if (mirroredBy != null && mirroredBy != currentUserId) {
          setState(() {
            _mirroredByUserId = mirroredBy;
          });

          if (_scrollController.hasClients && scrollOffset != null) {
            _scrollController.animateTo(
              scrollOffset,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          setState(() {
            _mirroredByUserId = null;
          });
        }
      } else {
        setState(() {
          _mirroredByUserId = null;
        });
      }
    });

    _scrollController.addListener(() {
      if (_isActivelyMirroring && _mirroredToUserId != null) {
        FirebaseFirestore.instance
            .collection('mirrors')
            .doc(_mirroredToUserId)
            .set({
          'mirroredBy': currentUserId,
          'scrollOffset': _scrollController.offset,
        }, SetOptions(merge: true));
      }
    });
  }

  Future<void> _fetchMyMirrorStatus() async {
    final mirrorDoc = await FirebaseFirestore.instance
        .collection('mirrors')
        .where('mirroredBy', isEqualTo: currentUserId)
        .get();

    if (mirrorDoc.docs.isNotEmpty) {
      setState(() {
        _isActivelyMirroring = true;
        _mirroredToUserId = mirrorDoc.docs.first.id;
      });
    }
  }

  Future<void> _cancelMirror() async {
    if (_mirroredToUserId != null) {
      await FirebaseFirestore.instance
          .collection('mirrors')
          .doc(_mirroredToUserId!)
          .delete();

      setState(() {
        _mirroredToUserId = null;
        _isActivelyMirroring = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isMirroring = _isActivelyMirroring && _mirroredToUserId != null;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 0,
        title: const Text(
          "Tech Marketplace",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (isMirroring)
            IconButton(
              icon: Icon(Icons.cancel, color: Colors.tealAccent[400]),
              tooltip: 'Cancel Mirroring',
              onPressed: _cancelMirror,
            ),
          IconButton(
            icon: Icon(Icons.chat, color: Colors.tealAccent[400]),
            tooltip: "Go to Chat List",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              );
              _fetchMyMirrorStatus();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_mirroredByUserId != null)
            Container(
              color: Colors.tealAccent.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              child: Text(
                "You are being mirrored by $_mirroredByUserId",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.tealAccent[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product['image'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Container(
                                height: 180,
                                color: Colors.grey[700],
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product['description'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    product['price'],
                                    style: TextStyle(
                                      color: Colors.tealAccent[400],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Icon(
                                    Icons.favorite_border,
                                    color: Colors.tealAccent[400],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}

