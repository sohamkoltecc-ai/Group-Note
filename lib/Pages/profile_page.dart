import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Get current Firebase user
  User? get currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    // User name
    final String userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : 'Student';

    // User email
    final String userEmail = user?.email ?? 'No email available';

    // Initial
    final String initial = userName.isNotEmpty
        ? userName.substring(0, 1).toUpperCase()
        : 'S';

    return Column(
      children: [
        _buildPageHeader('Student Profile', 'Manage your account'),

        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // =====================================================
                  // PROFILE AVATAR
                  // =====================================================
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFF2563EB),

                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =====================================================
                  // NAME
                  // =====================================================
                  Text(
                    userName,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // =====================================================
                  // EMAIL
                  // =====================================================
                  Text(
                    userEmail,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Cusrow Wadia Institute of Technology',
                    textAlign: TextAlign.center,

                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),

                  const SizedBox(height: 25),

                  // =====================================================
                  // ACCOUNT INFORMATION
                  // =====================================================
                  _buildSectionTitle('Account'),

                  const SizedBox(height: 10),

                  _buildProfileTile(
                    context,
                    Icons.person_outline_rounded,
                    'Personal Information',
                    onTap: () {
                      _showPersonalInfo(context, userName, userEmail);
                    },
                  ),

                  _buildProfileTile(
                    context,
                    Icons.notifications_active_rounded,
                    'Notifications & Alerts',
                    onTap: () {
                      _showComingSoon(context, 'Notifications & Alerts');
                    },
                  ),

                  _buildProfileTile(
                    context,
                    Icons.hub_rounded,
                    'Module Integration Settings',
                    onTap: () {
                      _showComingSoon(context, 'Module Integration Settings');
                    },
                  ),

                  _buildProfileTile(
                    context,
                    Icons.shield_rounded,
                    'Privacy & Security',
                    onTap: () {
                      _showComingSoon(context, 'Privacy & Security');
                    },
                  ),

                  const SizedBox(height: 15),

                  // =====================================================
                  // LOGOUT
                  // =====================================================
                  _buildProfileTile(
                    context,
                    Icons.logout_rounded,
                    'Log Out',
                    isDestructive: true,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // APP VERSION
                  // =====================================================
                  const Text(
                    'GroupNote',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Student Collaboration App',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                  ),

                  const SizedBox(height: 15),
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

  Widget _buildPageHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),

      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,

            style: const TextStyle(color: Color(0xFF93C5FD), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _buildSectionTitle(String title) {
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

  Widget _buildProfileTile(
    BuildContext context,
    IconData icon,
    String title, {
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFFE2E8F0)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: ListTile(
        onTap: onTap,

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),

        leading: Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: isDestructive
                ? const Color(0xFFFFF1F2)
                : const Color(0xFFEFF6FF),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(
            icon,

            color: isDestructive
                ? const Color(0xFFEF4444)
                : const Color(0xFF2563EB),

            size: 21,
          ),
        ),

        title: Text(
          title,

          style: TextStyle(
            color: isDestructive
                ? const Color(0xFFEF4444)
                : const Color(0xFF0F172A),

            fontWeight: FontWeight.w600,

            fontSize: 14,
          ),
        ),

        trailing: Icon(
          Icons.chevron_right_rounded,

          color: isDestructive
              ? const Color(0xFFFCA5A5)
              : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  // ===============================================================
  // PERSONAL INFORMATION
  // ===============================================================

  void _showPersonalInfo(BuildContext context, String name, String email) {
    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Personal Information',

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 20),

                _infoRow(Icons.person_rounded, 'Name', name),

                const SizedBox(height: 15),

                _infoRow(Icons.email_rounded, 'Email', email),

                const SizedBox(height: 20),
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
      children: [
        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
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

                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),

              const SizedBox(height: 2),

              Text(
                value,

                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
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
            borderRadius: BorderRadius.circular(20),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),

              onPressed: () async {
                Navigator.pop(dialogContext);

                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                // Login/Register page par le jao.
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
