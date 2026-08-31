import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];

    ids.sort();

    return ids.join('_');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
    String currentUserId,
    String otherUserId,
  ) {
    String chatId = getChatId(currentUserId, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;

    String chatId = getChatId(senderId, receiverId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
  }
}
