import 'package:flutter/material.dart';

void main() {
  runApp(const GroupNoteNotificationsApp());
}

class GroupNoteNotificationsApp extends StatelessWidget {
  const GroupNoteNotificationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Note - Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1E3A8A),
        primaryColor: const Color(0xFF2563EB),
        fontFamily: 'Roboto',
      ),
      home: const NotificationsScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. NOTIFICATION DATA MODEL
// -----------------------------------------------------------------------------
enum NotificationType { message, announcement, task, invite }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final String timestamp;
  bool isRead;
  String? inviteStatus; // 'pending', 'accepted', 'declined'
  bool isTaskSaved; // For announcements save-to-task feature

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.isRead = false,
    this.inviteStatus = 'pending',
    this.isTaskSaved = false,
  });
}

// -----------------------------------------------------------------------------
// 2. NOTIFICATIONS SCREEN
// -----------------------------------------------------------------------------
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  // Database of user alerts across all 4 required categories
  final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      type: NotificationType.announcement,
      title: '📢 DBMS Internal Exam Announcement',
      subtitle:
          'Date: Aug 28 • Time: 10:00 AM • Room: Lab 204. Please review Unit 2 notes prior to entry.',
      timestamp: '10 mins ago',
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      type: NotificationType.invite,
      title: 'Python Study Group Invite',
      subtitle:
          'Rahul Sharma invited you to join "Python & Django Coding Circle".',
      timestamp: '30 mins ago',
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      type: NotificationType.task,
      title: '⏰ Assignment 3 Due Tomorrow',
      subtitle:
          'Data Structures: Complete Stacks & Queues submission by 6:00 PM.',
      timestamp: '2 hours ago',
      isRead: false,
    ),
    NotificationModel(
      id: '4',
      type: NotificationType.message,
      title: 'Rahul in Data Structures',
      subtitle: 'Uploaded Unit 3 PDF. Check pages 12-18 for stack operations.',
      timestamp: '3 hours ago',
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      type: NotificationType.announcement,
      title: '📢 IoT Lab Schedule Revised',
      subtitle:
          'Tomorrow\'s IoT practical session shifted to Lab 301 at 2:00 PM.',
      timestamp: 'Yesterday',
      isRead: true,
      isTaskSaved: true,
    ),
    NotificationModel(
      id: '6',
      type: NotificationType.invite,
      title: 'Robotics Club Invite',
      subtitle: 'Prof. Patil added you to "Robotics Core Team 2026".',
      timestamp: '2 days ago',
      isRead: true,
      inviteStatus: 'accepted',
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredNotifications = _notifications.where((n) {
      if (_selectedFilter == 'Announcements') {
        return n.type == NotificationType.announcement;
      }
      if (_selectedFilter == 'Messages') {
        return n.type == NotificationType.message;
      }
      if (_selectedFilter == 'Tasks') return n.type == NotificationType.task;
      if (_selectedFilter == 'Invites') {
        return n.type == NotificationType.invite;
      }
      return true; // 'All'
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Blue Header Section
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Title & Mark Read Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_unreadCount > 0) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_unreadCount New',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _unreadCount > 0 ? _markAllAsRead : null,
                        icon: const Icon(
                          Icons.done_all_rounded,
                          size: 16,
                          color: Color(0xFF93C5FD),
                        ),
                        label: const Text(
                          'Mark Read',
                          style: TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Filter Chips
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Announcements'),
                        _buildFilterChip('Messages'),
                        _buildFilterChip('Tasks'),
                        _buildFilterChip('Invites'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Notification Content Surface
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
                  child: filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final item = filteredNotifications[index];
                            return _buildNotificationCard(item);
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------------
  // 3. UI COMPONENTS
  // -----------------------------------------------------------------------------

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    return GestureDetector(
      onTap: () {
        setState(() => item.isRead = true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead
              ? Colors.white
              : const Color(0xFFEFF6FF), // Highlight unread
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.isRead
                ? const Color(0xFFE2E8F0)
                : const Color(0xFFBFDBFE),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Category Badge & Timestamp
            Row(
              children: [
                _getCategoryBadge(item.type),
                const Spacer(),
                Text(
                  item.timestamp,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!item.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),

            // Notification Title
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),

            // Notification Subtitle/Description
            Text(
              item.subtitle,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                height: 1.4,
              ),
            ),

            // Context-Specific Actions (Section 10 Integration Logic)
            if (item.type == NotificationType.announcement) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: item.isTaskSaved
                      ? null
                      : () {
                          setState(() {
                            item.isTaskSaved = true;
                            item.isRead = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Saved directly to Member 4 Task Calendar!',
                              ),
                              backgroundColor: Color(0xFF059669),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                  icon: Icon(
                    item.isTaskSaved
                        ? Icons.check_circle_rounded
                        : Icons.calendar_today_rounded,
                    size: 14,
                    color: item.isTaskSaved
                        ? const Color(0xFF059669)
                        : const Color(0xFF2563EB),
                  ),
                  label: Text(
                    item.isTaskSaved ? 'Saved to Tasks' : 'Save to Tasks',
                    style: TextStyle(
                      color: item.isTaskSaved
                          ? const Color(0xFF059669)
                          : const Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: item.isTaskSaved
                          ? const Color(0xFF059669)
                          : const Color(0xFF2563EB),
                    ),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                  ),
                ),
              ),
            ],

            if (item.type == NotificationType.invite) ...[
              const SizedBox(height: 12),
              if (item.inviteStatus == 'pending')
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          item.inviteStatus = 'accepted';
                          item.isRead = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          item.inviteStatus = 'declined';
                          item.isRead = true;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item.inviteStatus == 'accepted'
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.inviteStatus == 'accepted'
                        ? 'Joined Group'
                        : 'Declined',
                    style: TextStyle(
                      color: item.inviteStatus == 'accepted'
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // Category Badge Customizer
  Widget _getCategoryBadge(NotificationType type) {
    String label;
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.announcement:
        label = 'Announcement';
        icon = Icons.campaign_rounded;
        color = const Color(0xFFD97706); // Amber
        break;
      case NotificationType.message:
        label = 'Message';
        icon = Icons.chat_bubble_outline_rounded;
        color = const Color(0xFF2563EB); // Blue
        break;
      case NotificationType.task:
        label = 'Task Deadline';
        icon = Icons.timer_outlined;
        color = const Color(0xFFE11D48); // Red
        break;
      case NotificationType.invite:
        label = 'Group Invite';
        icon = Icons.group_add_rounded;
        color = const Color(0xFF059669); // Emerald
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 12),
          Text(
            'No notifications in this category',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
