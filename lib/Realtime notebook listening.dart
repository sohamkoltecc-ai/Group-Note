import 'package:cloud_firestore/cloud_firestore.dart';

Stream<QuerySnapshot> getNotebooks(String userId) {
  return FirebaseFirestore.instance
      .collection('notebooks')
      .where('members', arrayContains: userId)
      .snapshots();
}
