import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addMember(String notebookId, String userId) async {
  await FirebaseFirestore.instance
      .collection('notebooks')
      .doc(notebookId)
      .update({
        'members': FieldValue.arrayUnion([userId]),
      });
}
