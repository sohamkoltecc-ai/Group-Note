import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser!.uid;

  // ============================================================
  // SEARCH USER BY EMAIL
  // ============================================================

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findUserByEmail(
    String email,
  ) async {
    final result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    return result.docs.first;
  }

  // ============================================================
  // CHECK ALREADY FRIEND
  // ============================================================

  Future<bool> isFriend(String friendUid) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(friendUid)
        .get();

    return doc.exists;
  }

  // ============================================================
  // ADD FRIEND
  // ============================================================

  Future<void> addFriend({
    required String friendUid,
    required String friendName,
    required String friendEmail,
  }) async {
    if (friendUid == currentUid) {
      throw Exception("You cannot add yourself.");
    }

    final alreadyFriend = await isFriend(friendUid);

    if (alreadyFriend) {
      throw Exception("This user is already your friend.");
    }

    final currentUserDoc = await _firestore
        .collection('users')
        .doc(currentUid)
        .get();

    final currentUserData = currentUserDoc.data() ?? {};

    final currentName =
        currentUserData['name']?.toString() ??
        _auth.currentUser?.displayName ??
        'User';

    final currentEmail =
        currentUserData['email']?.toString() ?? _auth.currentUser?.email ?? '';

    final batch = _firestore.batch();

    // Current user -> Friend
    final myFriendRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(friendUid);

    batch.set(myFriendRef, {
      'uid': friendUid,
      'name': friendName,
      'email': friendEmail.toLowerCase(),
      'addedAt': FieldValue.serverTimestamp(),
    });

    // Friend -> Current user
    final friendRef = _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(currentUid);

    batch.set(friendRef, {
      'uid': currentUid,
      'name': currentName,
      'email': currentEmail.toLowerCase(),
      'addedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ============================================================
  // REMOVE FRIEND
  // ============================================================

  Future<void> removeFriend(String friendUid) async {
    final batch = _firestore.batch();

    final myFriendRef = _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(friendUid);

    final otherFriendRef = _firestore
        .collection('users')
        .doc(friendUid)
        .collection('friends')
        .doc(currentUid);

    batch.delete(myFriendRef);
    batch.delete(otherFriendRef);

    await batch.commit();
  }

  // ============================================================
  // GET MY FRIENDS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getFriends() {
    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}
