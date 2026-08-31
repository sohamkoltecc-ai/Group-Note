import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // STATES
  // ============================================================

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message, {bool success = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: success
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> registerUser() async {
    if (isLoading) return;

    final name = nameController.text.trim();
    final username = usernameController.text.trim().toLowerCase();
    final email = emailController.text.trim().toLowerCase();
    final college = collegeController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (name.isEmpty) {
      showMessage('Please enter your name.');
      return;
    }

    if (username.isEmpty) {
      showMessage('Please enter a username.');
      return;
    }

    if (username.length < 3) {
      showMessage('Username must contain at least 3 characters.');
      return;
    }

    // Only letters, numbers, underscore and dot
    final usernameRegex = RegExp(r'^[a-z0-9_.]+$');

    if (!usernameRegex.hasMatch(username)) {
      showMessage('Username can contain only letters, numbers, _ and .');
      return;
    }

    if (email.isEmpty) {
      showMessage('Please enter your email.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      showMessage('Please enter a valid email.');
      return;
    }

    if (college.isEmpty) {
      showMessage('Please enter your college.');
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter a password.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must contain at least 6 characters.');
      return;
    }

    if (confirmPassword.isEmpty) {
      showMessage('Please confirm your password.');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    UserCredential? credential;

    try {
      // ========================================================
      // CHECK USERNAME
      // ========================================================

      final usernameResult = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (usernameResult.docs.isNotEmpty) {
        showMessage('Username @$username is already taken.');

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        return;
      }

      // ========================================================
      // CREATE FIREBASE AUTH ACCOUNT
      // ========================================================

      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception('Account could not be created.');
      }

      // ========================================================
      // UPDATE FIREBASE DISPLAY NAME
      // ========================================================

      await user.updateDisplayName(name);

      // ========================================================
      // CREATE FIRESTORE USER DOCUMENT
      // ========================================================

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'username': username,
        'email': email,
        'college': college,
        'friends': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ========================================================
      // SUCCESS
      // ========================================================

      if (!mounted) return;

      showMessage('Account created successfully!', success: true);

      // Small delay so user can see success message
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      /*
       FirebaseAuth automatically changes authState.

       main.dart AuthGate will detect the logged-in user
       and open NavigationHub.

       Therefore we don't need to manually push Home here.
      */

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // ========================================================
      // FIREBASE AUTH ERROR
      // ========================================================

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;

        case 'operation-not-allowed':
          message = 'Email/password authentication is not enabled in Firebase.';
          break;

        case 'network-request-failed':
          message = 'Network error. Check your internet connection.';
          break;

        case 'too-many-requests':
          message = 'Too many requests. Please try again later.';
          break;

        default:
          message = e.message ?? 'Registration failed.';
      }

      showMessage(message);

      debugPrint('REGISTER AUTH ERROR: ${e.code} - ${e.message}');
    } on FirebaseException catch (e) {
      // ========================================================
      // FIRESTORE ERROR
      // ========================================================

      debugPrint('REGISTER FIRESTORE ERROR: ${e.code} - ${e.message}');

      showMessage(
        'Account created, but profile could not be saved.\n'
        'Please check Firestore rules.',
      );

      // If Auth account was created but Firestore failed,
      // sign out so the user doesn't enter the app without
      // a profile document.
      try {
        await _auth.signOut();
      } catch (_) {}
    } catch (e) {
      // ========================================================
      // UNKNOWN ERROR
      // ========================================================

      debugPrint('REGISTER ERROR: $e');

      showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    collegeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
            child: Column(
              children: [
                // ==================================================
                // BACK BUTTON
                // ==================================================
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),

                const SizedBox(height: 5),

                // ==================================================
                // LOGO
                // ==================================================
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // TITLE
                // ==================================================
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Create your GroupNote account',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // NAME
                // ==================================================
                fieldLabel('Full Name'),

                const SizedBox(height: 8),

                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration(
                    hint: 'Enter your name',
                    icon: Icons.person_outline_rounded,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // USERNAME
                // ==================================================
                fieldLabel('Username'),

                const SizedBox(height: 8),

                TextField(
                  controller: usernameController,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: inputDecoration(
                    hint: 'Choose a username',
                    icon: Icons.alternate_email_rounded,
                  ),
                ),

                const SizedBox(height: 6),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Example: kaivalya_patait',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // EMAIL
                // ==================================================
                fieldLabel('Email'),

                const SizedBox(height: 8),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: inputDecoration(
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // COLLEGE
                // ==================================================
                fieldLabel('College'),

                const SizedBox(height: 8),

                TextField(
                  controller: collegeController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration(
                    hint: 'Enter your college',
                    icon: Icons.school_outlined,
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // PASSWORD
                // ==================================================
                fieldLabel('Password'),

                const SizedBox(height: 8),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration:
                      inputDecoration(
                        hint: 'Create a password',
                        icon: Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================
                fieldLabel('Confirm Password'),

                const SizedBox(height: 8),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!isLoading) {
                      registerUser();
                    }
                  },
                  decoration:
                      inputDecoration(
                        hint: 'Confirm your password',
                        icon: Icons.lock_reset_outlined,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // REGISTER BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerUser,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF93C5FD),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // LOGIN LINK
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),

                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
