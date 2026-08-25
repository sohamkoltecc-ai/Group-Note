import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createPoll(String question, List<String> options) async {
  await FirebaseFirestore.instance.collection('polls').add({
    'question': question,
    'options': options,
    'votes': List.filled(options.length, 0),
    'createdAt': FieldValue.serverTimestamp(),
  });
}
