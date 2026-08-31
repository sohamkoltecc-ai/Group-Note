import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_friend_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    final User? user = currentUser;

    final String userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Student';

    final String userEmail = user?.email?.trim().isNotEmpty == true
        ? user!.email!.trim()
        : 'No email available';

    final String initial = userName.isNotEmpty
        ? userName.substring(0, 1).toUpperCase()
        : 'S';

    final bool isGoogleUser =
        user?.providerData.any(
          (provider) => provider.providerId == 'google.com',
        ) ??
        false;

    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
              child: Column(
                children: [
                  // =====================================================
                  // PROFILE CARD
                  // =====================================================
                  _buildProfileCard(
                    userName: userName,
                    userEmail: userEmail,
                    initial: initial,
                    isGoogleUser: isGoogleUser,
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // ACCOUNT
                  // =====================================================
                  _sectionTitle('Account'),

                  const SizedBox(height: 10),

                  // ADD FRIEND
                  _profileTile(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Add Friend',
                    subtitle: 'Find friends using username',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddFriendPage(),
                        ),
                      );
                    },
                  ),

                  // PERSONAL INFORMATION
                  _profileTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    subtitle: 'Name, DOB, nickname & college',
                    onTap: () {
                      _showPersonalInformation(context, userName, userEmail);
                    },
                  ),

                  // EDIT PROFILE
                  _profileTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update your profile details',
                    onTap: () {
                      _showComingSoon(context, 'Edit Profile');
                    },
                  ),

                  const SizedBox(height: 18),

                  // =====================================================
                  // PREFERENCES
                  // =====================================================
                  _sectionTitle('Preferences'),

                  const SizedBox(height: 10),

                  _profileTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage alerts and reminders',
                    onTap: () {
                      _showComingSoon(context, 'Notifications');
                    },
                  ),

                  _profileTile(
                    icon: Icons.extension_outlined,
                    title: 'Module Settings',
                    subtitle: 'Manage app modules',
                    onTap: () {
                      _showComingSoon(context, 'Module Settings');
                    },
                  ),

                  const SizedBox(height: 18),

                  // =====================================================
                  // SECURITY
                  // =====================================================
                  _sectionTitle('Security'),

                  const SizedBox(height: 10),

                  _profileTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () {
                      _changePassword(context);
                    },
                  ),

                  _profileTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & Security',
                    subtitle: 'Manage privacy settings',
                    onTap: () {
                      _showComingSoon(context, 'Privacy & Security');
                    },
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // LOGOUT
                  // =====================================================
                  _buildLogoutButton(context),

                  const SizedBox(height: 25),

                  const Text(
                    'GroupNote',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Student Collaboration App',
                    style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 17, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Manage your GroupNote account',
            style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PROFILE CARD
  // ===============================================================

  Widget _buildProfileCard({
    required String userName,
    required String userEmail,
    required String initial,
    required bool isGoogleUser,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: const Color(0xFF2563EB),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 13),

          Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            userEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGoogleUser
                      ? Icons.g_mobiledata_rounded
                      : Icons.verified_user_outlined,
                  size: 18,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(width: 5),
                Text(
                  isGoogleUser ? 'Google Account' : 'Verified Account',
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===============================================================
  // PROFILE TILE
  // ===============================================================

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 21),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  // ===============================================================
  // PERSONAL INFORMATION
  // ===============================================================

  void _showPersonalInformation(
    BuildContext context,
    String name,
    String email,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Your account information',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),

                const SizedBox(height: 22),

                _infoRow(Icons.person_outline, 'Name', name),

                const SizedBox(height: 16),

                _infoRow(Icons.email_outlined, 'Email', email),

                const SizedBox(height: 16),

                _infoRow(
                  Icons.school_outlined,
                  'College',
                  'Cusrow Wadia Institute of Technology',
                ),

                const SizedBox(height: 16),

                _infoRow(Icons.cake_outlined, 'Date of Birth', 'Not added'),

                const SizedBox(height: 16),

                _infoRow(Icons.badge_outlined, 'Nickname', 'Not added'),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // INFO ROW
  // ===============================================================

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // CHANGE PASSWORD
  // ===============================================================

  Future<void> _changePassword(BuildContext context) async {
    final User? user = _auth.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email account found.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: user.email!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Unable to send password reset email.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ===============================================================
  // LOGOUT BUTTON
  // ===============================================================

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFECACA)),
          backgroundColor: const Color(0xFFFFF7F7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // LOGOUT DIALOG
  // ===============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Log Out?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to log out of GroupNote?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _auth.signOut();

                  if (!context.mounted) return;

                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                } on FirebaseAuthException catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? 'Logout failed.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  // ===============================================================
  // COMING SOON
  // ===============================================================

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
