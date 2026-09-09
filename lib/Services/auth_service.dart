import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(name.trim());

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e, 'Registration failed');
    } on FirebaseException catch (e) {
      if (e.plugin == 'cloud_firestore' &&
          (e.code == 'permission-denied' || e.code == 'failed-precondition')) {
        return 'Firestore is not enabled for this Firebase project. Enable Cloud Firestore in Firebase Console, then try again.';
      }
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'Something went wrong';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return _authError(e, 'Login failed');
    } catch (e) {
      return 'Something went wrong';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _authError(FirebaseAuthException error, String fallback) {
    switch (error.code) {
      case 'configuration-not-found':
      case 'operation-not-allowed':
        return 'Firebase Email/Password sign-in is not enabled. Enable it in Firebase Console > Authentication > Sign-in method.';
      default:
        return error.message ?? fallback;
    }
  }
}
