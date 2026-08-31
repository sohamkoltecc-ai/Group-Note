import 'package:flutter/material.dart';

import '../Pages/home_tab.dart';
import '../Pages/groups_page.dart';
import '../Pages/notes_page.dart';
import '../Pages/tasks_page.dart';
import '../Pages/chat_list_page.dart';
import '../Pages/profile_page.dart';
import '../Services/deadline_service.dart';

class NavigationHub extends StatefulWidget {
  const NavigationHub({super.key, required this.deadlineService});

  final DeadlineService deadlineService;

  @override
  State<NavigationHub> createState() => _NavigationHubState();
}

class _NavigationHubState extends State<NavigationHub> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(
        onNavigateToTasks: () => _changeTab(3),
        onNavigateToChat: () => _changeTab(4),
        onNavigateToGroups: () => _changeTab(1),
        onNavigateToNotes: () => _changeTab(2),
        onNavigateToProfile: () => _changeTab(5),
      ),

      const GroupsPage(),

      const NotesPage(),

      const TasksPage(),

      const ChatListPage(),

      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: pages),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: _currentIndex,

          onTap: _changeTab,

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.white,

          selectedItemColor: const Color(0xFF2563EB),

          unselectedItemColor: const Color(0xFF94A3B8),

          selectedFontSize: 11,

          unselectedFontSize: 10,

          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.groups_rounded),
              activeIcon: Icon(Icons.groups_rounded),
              label: 'Groups',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt_rounded),
              activeIcon: Icon(Icons.note_alt_rounded),
              label: 'Notes',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              activeIcon: Icon(Icons.task_alt_rounded),
              label: 'Tasks',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.chat_rounded),
              activeIcon: Icon(Icons.chat_rounded),
              label: 'Chat',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
