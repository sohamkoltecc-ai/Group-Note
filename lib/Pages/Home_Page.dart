import 'package:flutter/material.dart';
import 'notifi_screen.dart'; // Make sure this matches your notification file name
import 'calendar_screen.dart';
import 'deadlines_screen.dart';
import '../Services/deadline_service.dart';
import '../Services/deadline_service_factory.dart';

void main() {
  runApp(GroupNoteApp(deadlineService: createLocalDeadlineService()));
}

class GroupNoteApp extends StatelessWidget {
  const GroupNoteApp({super.key, required this.deadlineService});

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

// Global Search Data Model
class SearchItem {
  final String title;
  final String category;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  SearchItem({
    required this.title,
    required this.category,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

// Interactive Task Model
class TaskItem {
  final String id;
  final String title;
  final String course;
  final String dueDate;
  bool isCompleted;

  TaskItem({
    required this.id,
    required this.title,
    required this.course,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class NavigationHub extends StatefulWidget {
  const NavigationHub({super.key, required this.deadlineService});

  final DeadlineService deadlineService;

  @override
  State<NavigationHub> createState() => _NavigationHubState();
}

class _NavigationHubState extends State<NavigationHub> {
  int _currentIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Central Database for Global Search
  final List<SearchItem> _searchDatabase = [
    SearchItem(
      title: 'Data Structures - Stacks PDF',
      category: 'PDF',
      subtitle: 'Unit 3 • 24 Annotations',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: Colors.redAccent,
    ),
    SearchItem(
      title: 'DBMS Internal Exam Group',
      category: 'Group',
      subtitle: '138 Members • Active Discussion',
      icon: Icons.forum_rounded,
      accentColor: const Color(0xFF2563EB),
    ),
    SearchItem(
      title: 'Complete DBMS Assignment 3',
      category: 'Task',
      subtitle: 'Due Tomorrow • 6:00 PM',
      icon: Icons.assignment_turned_in_rounded,
      accentColor: Colors.amber.shade700,
    ),
    SearchItem(
      title: 'IoT Sensor Data Lecture Notes',
      category: 'Note',
      subtitle: 'Updated by Soham • 5 Pages',
      icon: Icons.edit_note_rounded,
      accentColor: Colors.green,
    ), // Changed from Colors.emerald to Colors.green for older Flutter versions compatibility
    SearchItem(
      title: 'DTM Study Circle',
      category: 'Group',
      subtitle: '4 Members • Private Group',
      icon: Icons.groups_rounded,
      accentColor: Colors.indigo,
    ),
    SearchItem(
      title: 'Prepare DS Unit 3 Questions',
      category: 'Task',
      subtitle: 'Due Aug 28 • 9:00 PM',
      icon: Icons.check_circle_rounded,
      accentColor: Colors.teal,
    ),
  ];

  // Task List State
  final List<TaskItem> _taskList = [
    TaskItem(
      id: '1',
      title: 'Complete DBMS Assignment 3',
      course: 'Database Systems',
      dueDate: 'Tomorrow, 6:00 PM',
    ),
    TaskItem(
      id: '2',
      title: 'Prepare DS Unit 3 Questions',
      course: 'Data Structures',
      dueDate: 'Aug 28, 9:00 PM',
    ),
    TaskItem(
      id: '3',
      title: 'Revise IoT Sensor Architecture',
      course: 'IoT Systems',
      dueDate: 'Aug 30, 11:59 PM',
    ),
    TaskItem(
      id: '4',
      title: 'Group Note Mini-Project Submission',
      course: 'Software Engineering',
      dueDate: 'Sep 02, 5:00 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      _buildGroupsPage(),
      _buildNotesPage(),
      _buildTasksPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: SafeArea(bottom: false, child: pages[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
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

  // ---------------------------------------------------------------------------
  // 1. HOME PAGE
  // ---------------------------------------------------------------------------
  Widget _buildHomePage() {
    final filteredResults = _searchDatabase
        .where(
          (item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Column(
      children: [
        // Electric Blue Header Section
        Container(
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
              // User Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Good Morning, Soham 👋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Computer Engineering • Semester 3',
                        style: TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // ----- NOTIFICATION BELL WITH NAVIGATION -----
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Interactive Global Search Input
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: "Search 'Stacks', groups, notes, tasks...",
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),

        // White Curved Main Body
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _searchQuery.isNotEmpty
                    ? _buildSearchResultsList(filteredResults)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Action Horizontal Pills
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 72,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildActionPill(
                                  'New Note',
                                  'Create document',
                                  Icons.add_circle_outline_rounded,
                                  const Color(0xFF2563EB),
                                ),
                                _buildActionPill(
                                  'Join Channel',
                                  'Enter code',
                                  Icons.group_add_rounded,
                                  const Color(0xFF0284C7),
                                ),
                                _buildActionPill(
                                  'Upload PDF',
                                  'Annotate slides',
                                  Icons.picture_as_pdf_rounded,
                                  const Color(0xFFE11D48),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Dashboard Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  '12',
                                  'Active Groups',
                                  Icons.forum_rounded,
                                  const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  '28',
                                  'Saved Notes',
                                  Icons.description_rounded,
                                  const Color(0xFF4F46E5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  '${_taskList.where((t) => !t.isCompleted).length}',
                                  'Pending Tasks',
                                  Icons.pending_actions_rounded,
                                  const Color(0xFF0D9488),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Signature Integration: Upcoming Task Banner
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Upcoming Deadline',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2563EB,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.assignment_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Data Structures',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Assignment 3 • Stacks & Queues',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Due Tomorrow at 6:00 PM',
                                        style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  onPressed: () => setState(
                                    () => _currentIndex = 3,
                                  ), // Navigate to Tasks
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Recent Groups Activity
                          const Text(
                            'Recent Group Chats',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildGroupChatTile(
                            'Data Structures Channel',
                            'Rahul: PDF for Unit 3 Stacks attached',
                            '10:42 AM',
                            true,
                          ),
                          _buildGroupChatTile(
                            'DBMS Internal Exam',
                            'Admin: Lab 204 location confirmed',
                            'Yesterday',
                            false,
                          ),
                          _buildGroupChatTile(
                            'IoT Project Team',
                            'Soham uploaded sensor code snippet',
                            'Aug 22',
                            false,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. GROUPS PAGE
  // ---------------------------------------------------------------------------
  Widget _buildGroupsPage() {
    return Column(
      children: [
        _buildPageHeader('Class & Study Groups', '12 Channels Joined'),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildGroupCategory('Official Course Groups', [
                  _buildGroupRow(
                    'Data Structures FY',
                    '142 Members',
                    Icons.code_rounded,
                    const Color(0xFF2563EB),
                  ),
                  _buildGroupRow(
                    'Database Systems (DBMS)',
                    '138 Members',
                    Icons.storage_rounded,
                    const Color(0xFF0284C7),
                  ),
                  _buildGroupRow(
                    'IoT & Sensor Systems',
                    '120 Members',
                    Icons.developer_board_rounded,
                    const Color(0xFF0D9488),
                  ),
                ]),
                const SizedBox(height: 20),
                _buildGroupCategory('Study & Project Channels', [
                  _buildGroupRow(
                    'Coding Club Exam Prep',
                    '18 Members',
                    Icons.terminal_rounded,
                    const Color(0xFF4F46E5),
                  ),
                  _buildGroupRow(
                    'Group Note Mini-Project Team',
                    '5 Members',
                    Icons.laptop_mac_rounded,
                    const Color(0xFF7C3AED),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. NOTES PAGE
  // ---------------------------------------------------------------------------
  Widget _buildNotesPage() {
    return Column(
      children: [
        _buildPageHeader('Notebooks & PDFs', '28 Files Stored'),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _buildGridNoteCard(
                  'Data Structures',
                  '12 Pages • Annotated PDF',
                  Icons.picture_as_pdf_rounded,
                  const Color(0xFFE11D48),
                ),
                _buildGridNoteCard(
                  'DBMS Unit 2',
                  '8 Pages • Handwritten',
                  Icons.edit_note_rounded,
                  const Color(0xFFD97706),
                ),
                _buildGridNoteCard(
                  'IoT Architecture',
                  '5 Pages • Notes',
                  Icons.sensors_rounded,
                  const Color(0xFF059669),
                ),
                _buildGridNoteCard(
                  'OOP in C++',
                  '15 Pages • PDF Document',
                  Icons.article_rounded,
                  const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. TASKS PAGE (Interactive Checkboxes)
  // ---------------------------------------------------------------------------
  Widget _buildTasksPage() {
    return Column(
      children: [
        _buildPageHeader(
          'Planner & Tasks',
          '${_taskList.where((t) => !t.isCompleted).length} Pending Tasks',
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _taskList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Calendar, deadlines & reminders',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CalendarScreen(
                                deadlineService: widget.deadlineService,
                              ),
                            ),
                          ),
                          child: const Text('Calendar'),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeadlinesScreen(
                                deadlineService: widget.deadlineService,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final task = _taskList[index - 1];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: CheckboxListTile(
                    activeColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    value: task.isCompleted,
                    onChanged: (val) {
                      setState(() {
                        task.isCompleted = val ?? false;
                      });
                    },
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: task.isCompleted
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF0F172A),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      '${task.course} • ${task.dueDate}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. PROFILE PAGE
  // ---------------------------------------------------------------------------
  Widget _buildProfilePage() {
    return Column(
      children: [
        _buildPageHeader('Student Profile', 'Member 5 Scope'),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFF2563EB),
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Soham Kolte',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Cusrow Wadia Institute of Technology',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  _buildProfileTile(
                    Icons.notifications_active_rounded,
                    'Notifications & Alerts',
                  ),
                  _buildProfileTile(
                    Icons.hub_rounded,
                    'Module Integration Settings',
                  ),
                  _buildProfileTile(Icons.shield_rounded, 'Privacy & Security'),
                  _buildProfileTile(
                    Icons.logout_rounded,
                    'Log Out',
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget Components
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

  Widget _buildActionPill(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String count,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChatTile(
    String title,
    String message,
    String time,
    bool unread,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
          child: Text(
            title[0],
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
            ),
            if (unread) ...[
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList(List<SearchItem> results) {
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            "No matches found.",
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${results.length})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        ...results.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item.accentColor.withValues(alpha: 0.12),
                child: Icon(item.icon, color: item.accentColor),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                '${item.category} • ${item.subtitle}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCategory(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }

  Widget _buildGroupRow(
    String name,
    String members,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          members,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            shape: const StadiumBorder(),
          ),
          child: const Text(
            'Open',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildGridNoteCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(
    IconData icon,
    String title, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive
              ? const Color(0xFFEF4444)
              : const Color(0xFF2563EB),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive
                ? const Color(0xFFEF4444)
                : const Color(0xFF0F172A),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}
