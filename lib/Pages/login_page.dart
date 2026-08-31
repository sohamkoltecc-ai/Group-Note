import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // STATES
  // ============================================================

  bool obscurePassword = true;
  bool isLoading = false;
  bool isGoogleLoading = false;

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(String message, {Color color = const Color(0xFF1E3A8A)}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  // GO TO HOME
  // ============================================================

  void goToHome() {
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  // ============================================================
  // EMAIL LOGIN
  // ============================================================

  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (email.isEmpty) {
      showMessage('Please enter your email.');
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter your password.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // FIREBASE LOGIN
      // --------------------------------------------------------

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // --------------------------------------------------------
      // LOGIN SUCCESS
      // --------------------------------------------------------

      if (!mounted) return;

      showMessage('Login successful!', color: Colors.green);

      // Small delay so user can see success message.
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // --------------------------------------------------------
      // DIRECT HOME
      // --------------------------------------------------------

      goToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'user-not-found':
          message = 'No account found with this email.';
          break;

        case 'wrong-password':
          message = 'Incorrect password.';
          break;

        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;

        case 'user-disabled':
          message = 'This account has been disabled.';
          break;

        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        case 'operation-not-allowed':
          message = 'Email/password login is not enabled in Firebase.';
          break;

        default:
          message = e.message ?? 'Login failed.';
      }

      debugPrint('EMAIL LOGIN ERROR: ${e.code} - ${e.message}');

      showMessage(message);
    } catch (e) {
      if (!mounted) return;

      debugPrint('EMAIL LOGIN UNKNOWN ERROR: $e');

      showMessage('Something went wrong.\n$e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  Future<void> loginWithGoogle() async {
    if (isLoading || isGoogleLoading) return;

    setState(() {
      isGoogleLoading = true;
    });

    try {
      // --------------------------------------------------------
      // GOOGLE SIGN IN
      // --------------------------------------------------------

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      // --------------------------------------------------------
      // CHECK SUPPORT
      // --------------------------------------------------------

      if (!googleSignIn.supportsAuthenticate()) {
        throw Exception('Google Sign-In is not supported on this platform.');
      }

      // --------------------------------------------------------
      // GOOGLE ACCOUNT
      // --------------------------------------------------------

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // --------------------------------------------------------
      // GOOGLE AUTH
      // --------------------------------------------------------

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // --------------------------------------------------------
      // ID TOKEN
      // --------------------------------------------------------

      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google ID token is missing.\n'
          'Please check Firebase Google Sign-In configuration.',
        );
      }

      // --------------------------------------------------------
      // FIREBASE CREDENTIAL
      // --------------------------------------------------------

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // --------------------------------------------------------
      // FIREBASE LOGIN
      // --------------------------------------------------------

      await _auth.signInWithCredential(credential);

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (!mounted) return;

      showMessage('Google login successful!', color: Colors.green);

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // --------------------------------------------------------
      // DIRECT HOME
      // --------------------------------------------------------

      goToHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      debugPrint('GOOGLE FIREBASE ERROR: ${e.code} - ${e.message}');

      showMessage(
        'Firebase Error\n'
        'Code: ${e.code}\n'
        '${e.message ?? ''}',
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;

      debugPrint(
        'GOOGLE SIGN-IN ERROR: '
        '${e.code} - ${e.description}',
      );

      showMessage(
        'Google Sign-In Error\n'
        '${e.code}\n'
        '${e.description ?? ''}',
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('GOOGLE LOGIN UNKNOWN ERROR: $e');

      showMessage('Google Sign-In Error\n$e');
    } finally {
      if (mounted) {
        setState(() {
          isGoogleLoading = false;
        });
      }
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> forgotPassword() async {
    final TextEditingController resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        bool sending = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),

              // ------------------------------------------------
              // TITLE
              // ------------------------------------------------
              title: const Row(
                children: [
                  Icon(Icons.lock_reset_rounded, color: Color(0xFF2563EB)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // ------------------------------------------------
              // CONTENT
              // ------------------------------------------------
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter your registered email address. '
                      'We will send you a password reset link.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ------------------------------------------------
              // BUTTONS
              // ------------------------------------------------
              actions: [
                TextButton(
                  onPressed: sending
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: sending
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();

                          if (email.isEmpty) {
                            showMessage('Please enter your email.');
                            return;
                          }

                          setDialogState(() {
                            sending = true;
                          });

                          try {
                            await _auth.sendPasswordResetEmail(email: email);

                            if (!mounted) return;

                            Navigator.pop(dialogContext);

                            showMessage(
                              'Password reset link sent to your email.',
                              color: Colors.green,
                            );
                          } on FirebaseAuthException catch (e) {
                            if (!context.mounted) return;

                            setDialogState(() {
                              sending = false;
                            });

                            String message;

                            switch (e.code) {
                              case 'invalid-email':
                                message = 'Please enter a valid email.';
                                break;

                              case 'user-not-found':
                                message = 'No account found with this email.';
                                break;

                              case 'network-request-failed':
                                message =
                                    'Network error. Check your internet connection.';
                                break;

                              default:
                                message =
                                    e.message ?? 'Unable to send reset email.';
                            }

                            showMessage(message);
                          } catch (e) {
                            if (!context.mounted) return;

                            setDialogState(() {
                              sending = false;
                            });

                            showMessage('Something went wrong.\n$e');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send Link'),
                ),
              ],
            );
          },
        );
      },
    );

    resetEmailController.dispose();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  void openRegister() {
    if (isLoading || isGoogleLoading) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              children: [
                // ==================================================
                // LOGO
                // ==================================================
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
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
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TITLE
                // ==================================================
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Login to continue to GroupNote',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // EMAIL LABEL
                // ==================================================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // EMAIL
                // ==================================================
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading && !isGoogleLoading,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
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
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // PASSWORD LABEL
                // ==================================================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // PASSWORD
                // ==================================================
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading && !isGoogleLoading,
                  onSubmitted: (_) {
                    if (!isLoading && !isGoogleLoading) {
                      loginWithEmail();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: isLoading || isGoogleLoading
                          ? null
                          : () {
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
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // FORGOT PASSWORD
                // ==================================================
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading || isGoogleLoading
                        ? null
                        : forgotPassword,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                // ==================================================
                // LOGIN BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading || isGoogleLoading
                        ? null
                        : loginWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
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
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // OR
                // ==================================================
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),

                const SizedBox(height: 22),

                // ==================================================
                // GOOGLE
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: isGoogleLoading || isLoading
                        ? null
                        : loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isGoogleLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GoogleLogo(),
                              SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // REGISTER
                // ==================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    GestureDetector(
                      onTap: isLoading || isGoogleLoading ? null : openRegister,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// GOOGLE LOGO
// ================================================================

class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: GoogleLogoPainter()),
    );
  }
}

// ================================================================
// GOOGLE LOGO PAINTER
// ================================================================

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final radius = size.width * 0.40;

    const double strokeWidth = 4.2;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // ------------------------------------------------------------
    // RED
    // ------------------------------------------------------------

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, -2.35, 1.55, false, redPaint);

    // ------------------------------------------------------------
    // YELLOW
    // ------------------------------------------------------------

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, -0.80, 1.15, false, yellowPaint);

    // ------------------------------------------------------------
    // GREEN
    // ------------------------------------------------------------

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, 0.35, 1.65, false, greenPaint);

    // ------------------------------------------------------------
    // BLUE
    // ------------------------------------------------------------

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, 2.00, 1.93, false, bluePaint);

    // ------------------------------------------------------------
    // BLUE BAR
    // ------------------------------------------------------------

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.50,
        size.height * 0.42,
        size.width * 0.38,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
