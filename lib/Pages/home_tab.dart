import 'package:flutter/material.dart';
import 'globals.dart';
import 'notifi_screen.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback onNavigateToTasks;

  const HomeTab({Key? key, required this.onNavigateToTasks}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final filteredResults = globalSearchDatabase
        .where(
          (item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Column(
      children: [
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
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
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
                    hintText: "Search 'Stacks', groups, notes...",
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
                            height: 82,
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
                                  '${globalTaskList.where((t) => !t.isCompleted).length}',
                                  'Pending Tasks',
                                  Icons.pending_actions_rounded,
                                  const Color(0xFF0D9488),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
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
                                  color: Colors.black.withOpacity(0.02),
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
                                    ).withOpacity(0.1),
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
                                  onPressed: widget.onNavigateToTasks,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
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
                            'Rahul: PDF for Unit 3 attached',
                            '10:42 AM',
                            true,
                          ),
                          _buildGroupChatTile(
                            'DBMS Internal Exam',
                            'Admin: Lab 204 location confirmed',
                            'Yesterday',
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
            backgroundColor: color.withOpacity(0.12),
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
          backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
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
    if (results.isEmpty)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            "No matches found.",
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
      );
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
                backgroundColor: item.accentColor.withOpacity(0.12),
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
}
