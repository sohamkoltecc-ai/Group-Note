import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();

  final ChatService chatService = ChatService();

  // Current Firebase user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // ---------------------------------------------------------
  // SEND MESSAGE
  // ---------------------------------------------------------
  Future<void> sendMessage() async {
    final message = messageController.text.trim();

    if (message.isEmpty) return;

    final user = currentUser;

    // User login nahi hai
    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));

      return;
    }

    // Receiver ID invalid hai
    if (widget.receiverId.trim().isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Receiver not found')));

      return;
    }

    try {
      await chatService.sendMessage(
        senderId: user.uid,
        receiverId: widget.receiverId,
        message: message,
      );

      messageController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Message failed: $e')));
    }
  }

  // ---------------------------------------------------------
  // FORMAT TIME
  // ---------------------------------------------------------
  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    final date = timestamp.toDate();

    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ---------------------------------------------------------
  // INITIAL LETTER
  // ---------------------------------------------------------
  String getReceiverInitial() {
    final name = widget.receiverName.trim();

    if (name.isEmpty) {
      return '?';
    }

    return name.substring(0, 1).toUpperCase();
  }

  // ---------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------
  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    // -------------------------------------------------------
    // USER NOT LOGGED IN
    // -------------------------------------------------------
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(
          child: Text('Please login first', style: TextStyle(fontSize: 16)),
        ),
      );
    }

    // -------------------------------------------------------
    // MAIN CHAT SCREEN
    // -------------------------------------------------------
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,

        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: Text(
                getReceiverInitial(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                widget.receiverName.isEmpty ? 'Chat' : widget.receiverName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // ===================================================
          // MESSAGES
          // ===================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chatService.getMessages(user.uid, widget.receiverId),

              builder: (context, snapshot) {
                // ------------------------------------------------
                // LOADING
                // ------------------------------------------------
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ------------------------------------------------
                // ERROR
                // ------------------------------------------------
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Unable to load messages',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ------------------------------------------------
                // NO DATA
                // ------------------------------------------------
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'Say hello 👋',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!.docs;

                // ------------------------------------------------
                // EMPTY CHAT
                // ------------------------------------------------
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Say hello 👋',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  );
                }

                // ------------------------------------------------
                // MESSAGE LIST
                // ------------------------------------------------
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(15),
                  itemCount: messages.length,

                  itemBuilder: (context, index) {
                    final data = messages[index].data();

                    // --------------------------------------------
                    // SAFE DATA READING
                    // --------------------------------------------

                    final senderId = data['senderId']?.toString() ?? '';

                    final message = data['message']?.toString() ?? '';

                    // Timestamp safely handle karo
                    Timestamp? timestamp;

                    final timestampData = data['timestamp'];

                    if (timestampData is Timestamp) {
                      timestamp = timestampData;
                    }

                    // --------------------------------------------
                    // CHECK CURRENT USER
                    // --------------------------------------------

                    final isMe = senderId == user.uid;

                    // --------------------------------------------
                    // MESSAGE BUBBLE
                    // --------------------------------------------

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,

                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),

                        margin: const EdgeInsets.only(bottom: 10),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[850],

                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,

                          children: [
                            // ----------------------------------
                            // MESSAGE TEXT
                            // ----------------------------------
                            Align(
                              alignment: Alignment.centerLeft,

                              child: Text(
                                message,

                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // ----------------------------------
                            // TIME
                            // ----------------------------------
                            Text(
                              formatTime(timestamp),

                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ===================================================
          // MESSAGE INPUT
          // ===================================================
          SafeArea(
            top: false,

            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),

              child: Row(
                children: [
                  // --------------------------------------------
                  // TEXT FIELD
                  // --------------------------------------------
                  Expanded(
                    child: TextField(
                      controller: messageController,

                      textInputAction: TextInputAction.send,

                      minLines: 1,
                      maxLines: 4,

                      onSubmitted: (_) {
                        sendMessage();
                      },

                      decoration: InputDecoration(
                        hintText: 'Type a message...',

                        filled: true,

                        fillColor: Colors.grey[900],

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),

                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),

                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),

                          borderSide: BorderSide.none,
                        ),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),

                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // --------------------------------------------
                  // SEND BUTTON
                  // --------------------------------------------
                  CircleAvatar(
                    radius: 25,

                    backgroundColor: Colors.blue,

                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),

                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
