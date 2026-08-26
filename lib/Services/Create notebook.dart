import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createNotebook(String title, String userId) async {
  await FirebaseFirestore.instance.collection('notebooks').add({
    'title': title,
    'ownerId': userId,
    'members': [userId],
    'createdAt': FieldValue.serverTimestamp(),
  });
}
