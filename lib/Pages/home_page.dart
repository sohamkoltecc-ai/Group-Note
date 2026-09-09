import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'chat_page.dart';

class ChatsHomePage extends StatelessWidget {
  const ChatsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
            },
          ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final users = snapshot.data?.docs ?? [];

          final otherUsers = users.where((doc) {
            return doc.id != currentUser?.uid;
          }).toList();

          if (otherUsers.isEmpty) {
            return const Center(
              child: Text(
                'No other users found',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),

            itemCount: otherUsers.length,

            itemBuilder: (context, index) {
              final data = otherUsers[index].data() as Map<String, dynamic>;

              final name = data['name'] ?? 'User';
              final email = data['email'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),

                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),

                  leading: CircleAvatar(
                    radius: 27,
                    child: Text(
                      name.toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(email),

                  trailing: const Icon(Icons.arrow_forward_ios, size: 17),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          receiverId: data['uid'],
                          receiverName: name,
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
