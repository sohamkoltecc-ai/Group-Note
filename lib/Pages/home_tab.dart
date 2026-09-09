import 'package:flutter/material.dart';

import 'OCR Page Module.dart';
import 'Ai screen.dart';
import 'Drawing Notes Modulle.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.onNavigateToTasks,
    required this.onNavigateToChat,
    required this.onNavigateToGroups,
    required this.onNavigateToNotes,
    required this.onNavigateToProfile,
  });

  final VoidCallback onNavigateToTasks;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToGroups;
  final VoidCallback onNavigateToNotes;
  final VoidCallback onNavigateToProfile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: CustomScrollView(
        slivers: [
          // =====================================================
          // HEADER
          // =====================================================
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Note App',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'Everything you need to study',
                              style: TextStyle(
                                color: Color(0xFFBFDBFE),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 45,
                        height: 45,

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Row(
                      children: [
                        Icon(
                          Icons.waving_hand_rounded,
                          color: Colors.amber,
                          size: 30,
                        ),

                        SizedBox(width: 12),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Welcome 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              'Ready to learn something new?',
                              style: TextStyle(
                                color: Color(0xFFDBEAFE),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // TITLE
          // =====================================================
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 25, 20, 15),

              child: Text(
                'Study Tools',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),

          // =====================================================
          // FEATURES
          // =====================================================
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            sliver: SliverGrid(
              delegate: SliverChildListDelegate([
                // OCR
                HomeFeatureCard(
                  icon: Icons.document_scanner_rounded,
                  title: 'OCR',
                  subtitle: 'Scan notes',
                  iconColor: const Color(0xFF2563EB),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OCRPage()),
                    );
                  },
                ),

                // AI
                HomeFeatureCard(
                  icon: Icons.smart_toy_rounded,
                  title: 'AI Assistant',
                  subtitle: 'Ask AI',

                  iconColor: const Color(0xFF7C3AED),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIStudyAssistant(),
                      ),
                    );
                  },
                ),

                // DRAWING
                HomeFeatureCard(
                  icon: Icons.brush_rounded,
                  title: 'Drawing',
                  subtitle: 'Draw a note',

                  iconColor: const Color(0xFFDB2777),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DrawingNotePage(),
                      ),
                    );
                  },
                ),

                // CHAT
                HomeFeatureCard(
                  icon: Icons.chat_rounded,
                  title: 'Chat',
                  subtitle: 'Send messages',

                  iconColor: const Color(0xFF059669),

                  onTap: onNavigateToChat,
                ),

                // GROUPS
                HomeFeatureCard(
                  icon: Icons.groups_rounded,
                  title: 'Groups',
                  subtitle: 'Study together',

                  iconColor: const Color(0xFFEA580C),

                  onTap: onNavigateToGroups,
                ),

                // NOTES
                HomeFeatureCard(
                  icon: Icons.note_alt_rounded,
                  title: 'Notes',
                  subtitle: 'Your notes',

                  iconColor: const Color(0xFF0891B2),

                  onTap: onNavigateToNotes,
                ),

                // TASKS
                HomeFeatureCard(
                  icon: Icons.task_alt_rounded,
                  title: 'Tasks',
                  subtitle: 'Manage tasks',

                  iconColor: const Color(0xFF4F46E5),

                  onTap: onNavigateToTasks,
                ),

                // PROFILE
                HomeFeatureCard(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  subtitle: 'Your account',

                  iconColor: const Color(0xFF475569),

                  onTap: onNavigateToProfile,
                ),
              ]),

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,

                crossAxisSpacing: 14,

                mainAxisSpacing: 14,

                childAspectRatio: 1.08,
              ),
            ),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }
}

// =============================================================
// HOME FEATURE CARD
// =============================================================

class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: onTap,

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: const Color(0xFFE2E8F0)),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          padding: const EdgeInsets.all(15),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),

                  borderRadius: BorderRadius.circular(17),
                ),

                child: Icon(icon, size: 30, color: iconColor),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                textAlign: TextAlign.center,

                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
