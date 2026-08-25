import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'groups_page.dart';
import 'notes_page.dart';
import 'tasks_page.dart';
import 'profile_page.dart';
import 'notifi_screen.dart'; // Make sure this matches your notification file name
import 'calendar_screen.dart';
import 'deadlines_screen.dart';
import '../Services/deadline_service.dart';
import '../Services/deadline_service_factory.dart';

void main() {
  runApp(GroupNoteApp(deadlineService: createLocalDeadlineService()));
}

class GroupNoteApp extends StatelessWidget {
  const GroupNoteApp({Key? key, required this.deadlineService})
    : super(key: key);

  final DeadlineService deadlineService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Note',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1E40AF),
        primaryColor: const Color(0xFF2563EB),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: const Color(0xFFF8FAFC),
        ),
      ),
      home: NavigationHub(deadlineService: deadlineService),
    );
  }
}

// --- NAVIGATION HUB ---
class NavigationHub extends StatefulWidget {
  const NavigationHub({Key? key, required this.deadlineService})
    : super(key: key);

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
    final List<Widget> pages = [
      HomeTab(onNavigateToTasks: () => _changeTab(3)), // Tab 0
      const GroupsPage(), // Tab 1
      const NotesPage(), // Tab 2
      const TasksPage(), // Tab 3
      const ProfilePage(), // Tab 4
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: SafeArea(bottom: false, child: pages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
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
          selectedItemColor: const Color(0xFF1D4ED8),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Groups',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
