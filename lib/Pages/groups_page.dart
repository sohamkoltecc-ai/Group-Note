import 'package:flutter/material.dart';

// =====================================================
// GROUP PAGE
// =====================================================

class GroupsPage extends StatelessWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPageHeader(
          'Class & Study Groups',
          '12 Channels Joined',
        ),

        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildGroupCategory(
                  'Official Course Groups',
                  [
                    _buildGroupRow(
                      context,
                      'Data Structures FY',
                      '142 Members',
                      Icons.code_rounded,
                      const Color(0xFF2563EB),
                    ),
                    _buildGroupRow(
                      context,
                      'Database Systems (DBMS)',
                      '138 Members',
                      Icons.storage_rounded,
                      const Color(0xFF0284C7),
                    ),
                    _buildGroupRow(
                      context,
                      'IoT & Sensor Systems',
                      '120 Members',
                      Icons.developer_board_rounded,
                      const Color(0xFF0D9488),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _buildGroupCategory(
                  'Study & Project Channels',
                  [
                    _buildGroupRow(
                      context,
                      'Coding Club Exam Prep',
                      '18 Members',
                      Icons.terminal_rounded,
                      const Color(0xFF4F46E5),
                    ),
                    _buildGroupRow(
                      context,
                      'Group Note Mini-Project Team',
                      '5 Members',
                      Icons.laptop_mac_rounded,
                      const Color(0xFF7C3AED),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader(String title, String subtitle) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        24,
      ),
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
            style: const TextStyle(
              color: Color(0xFFBFDBFE),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCategory(
    String title,
    List<Widget> children,
  ) {
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
    BuildContext context,
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
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),

        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            members,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ),

        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailPage(
                  groupName: name,
                  members: members,
                  icon: icon,
                  color: color,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            shape: const StadiumBorder(),
          ),
          child: const Text(
            'Open',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// GROUP DETAIL PAGE
// =====================================================

class GroupDetailPage extends StatelessWidget {
  final String groupName;
  final String members;
  final IconData icon;
  final Color color;

  const GroupDetailPage({
    Key? key,
    required this.groupName,
    required this.members,
    required this.icon,
    required this.color,
  }) : super(key: key);

  void _openSection(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupSectionPage(
          groupName: groupName,
          title: title,
          icon: icon,
        ),
      ),
    );
  }

  void _openMembers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupMembersPage(
          groupName: groupName,
          members: members,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          groupName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _openMembers(context),
            icon: const Icon(Icons.people_alt_rounded),
            tooltip: 'Members',
          ),
        ],
      ),

      body: Column(
        children: [
          // GROUP HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 28,
              horizontal: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    size: 38,
                    color: color,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  groupName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  members,
                  style: const TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 14),

                OutlinedButton.icon(
                  onPressed: () => _openMembers(context),
                  icon: const Icon(
                    Icons.people_alt_rounded,
                    size: 18,
                  ),
                  label: const Text('View Members'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SECTIONS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _infoCard(
                  context,
                  Icons.chat_bubble_outline_rounded,
                  'Active Discussions',
                  'Discuss course topics, questions and ideas.',
                ),

                _infoCard(
                  context,
                  Icons.description_outlined,
                  'Shared Notes',
                  'Share and access notes and study material.',
                ),

                _infoCard(
                  context,
                  Icons.assignment_outlined,
                  'Assignments',
                  'View assignments, deadlines and academic tasks.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _openSection(
            context,
            title,
            icon,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// MEMBERS PAGE
// =====================================================

class GroupMembersPage extends StatefulWidget {
  final String groupName;
  final String members;
  final Color color;

  const GroupMembersPage({
    Key? key,
    required this.groupName,
    required this.members,
    required this.color,
  }) : super(key: key);

  @override
  State<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final List<String> memberList = [
    'Ashrafjaha',
    'Sneha',
    'Sanchita',
    'Rahul',
    'Aarav',
  ];

  void _addMember() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Member'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter member name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    memberList.add(
                      controller.text.trim(),
                    );
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${controller.text.trim()} added to group',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: const Text(
          'Group Members',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMember,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Member'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E3A8A),
                  Color(0xFF2563EB),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.groups_rounded,
                  size: 45,
                  color: Colors.white,
                ),

                const SizedBox(height: 10),

                Text(
                  widget.groupName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${memberList.length} members shown',
                  style: const TextStyle(
                    color: Color(0xFFBFDBFE),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ...memberList.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final name = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.color.withOpacity(0.12),
                      child: Text(
                        name.isNotEmpty
                            ? name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    if (index == 0)
                      const Text(
                        'You',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =====================================================
// GROUP SECTION PAGE
// =====================================================

class GroupSectionPage extends StatefulWidget {
  final String groupName;
  final String title;
  final IconData icon;

  const GroupSectionPage({
    Key? key,
    required this.groupName,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  State<GroupSectionPage> createState() => _GroupSectionPageState();
}

class _GroupSectionPageState extends State<GroupSectionPage> {
  final List<String> discussions = [
    'Can someone explain this topic?',
    'Does anyone have the Unit 2 notes?',
  ];

  final List<String> notes = [
    'Unit 1 - Introduction Notes',
    'Important Exam Questions',
  ];

  final List<Map<String, String>> assignments = [
    {
      'title': 'Database Assignment 1',
      'deadline': '10 September 2026',
    },
    {
      'title': 'Unit 2 Practice Questions',
      'deadline': '15 September 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          widget.title == 'Active Discussions'
              ? 'Start Discussion'
              : widget.title == 'Shared Notes'
                  ? 'Add Note'
                  : 'Add Assignment',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          if (widget.title == 'Active Discussions')
            _buildDiscussions(),

          if (widget.title == 'Shared Notes')
            _buildNotes(),

          if (widget.title == 'Assignments')
            _buildAssignments(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String description = '';

    if (widget.title == 'Active Discussions') {
      description =
          'Discuss course topics, questions and ideas with other students.';
    } else if (widget.title == 'Shared Notes') {
      description =
          'View and share notes and study material with group members.';
    } else {
      description =
          'View assignments, deadlines and important academic tasks.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              widget.icon,
              size: 32,
              color: const Color(0xFF2563EB),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            widget.groupName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================
  // DISCUSSIONS
  // ===================================================

  Widget _buildDiscussions() {
    return Column(
      children: [
        ...discussions.map(
          (message) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(
                    Icons.person,
                    color: Color(0xFF2563EB),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Student',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===================================================
  // NOTES
  // ===================================================

  Widget _buildNotes() {
    return Column(
      children: [
        ...notes.map(
          (note) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        note,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Shared by group member',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.download_outlined,
                  color: Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===================================================
  // ASSIGNMENTS
  // ===================================================

  Widget _buildAssignments() {
    return Column(
      children: [
        ...assignments.map(
          (assignment) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Color(0xFF2563EB),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),

                          const SizedBox(width: 5),

                          Text(
                            'Due: ${assignment['deadline']}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
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
      ],
    );
  }

  // ===================================================
  // ADD DIALOG
  // ===================================================

  void _showAddDialog() {
    final controller = TextEditingController();

    String dialogTitle = '';

    if (widget.title == 'Active Discussions') {
      dialogTitle = 'Start Discussion';
    } else if (widget.title == 'Shared Notes') {
      dialogTitle = 'Add Note';
    } else {
      dialogTitle = 'Add Assignment';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(dialogTitle),

          content: TextField(
            controller: controller,
            maxLines: widget.title == 'Active Discussions'
                ? 3
                : 1,
            decoration: InputDecoration(
              hintText: widget.title == 'Active Discussions'
                  ? 'Write your discussion...'
                  : widget.title == 'Shared Notes'
                      ? 'Enter note title'
                      : 'Enter assignment title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();

                if (text.isEmpty) {
                  return;
                }

                setState(() {
                  if (widget.title == 'Active Discussions') {
                    discussions.insert(0, text);
                  } else if (widget.title == 'Shared Notes') {
                    notes.insert(0, text);
                  } else {
                    assignments.insert(
                      0,
                      {
                        'title': text,
                        'deadline': '20 September 2026',
                      },
                    );
                  }
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.title == 'Active Discussions'
                          ? 'Discussion posted!'
                          : widget.title == 'Shared Notes'
                              ? 'Note added!'
                              : 'Assignment added!',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}