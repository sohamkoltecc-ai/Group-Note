import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_friend_page.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // GET CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  // ============================================================
  // FRIEND STREAM
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final user = currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // ============================================================
  // GET FRIEND USERS
  // ============================================================

  Future<List<Map<String, dynamic>>> _getFriends(
    List<dynamic> friendIds,
  ) async {
    if (friendIds.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>> friends = [];

    for (final id in friendIds) {
      final friendId = id.toString();

      if (friendId.isEmpty) continue;

      try {
        final document = await _firestore
            .collection('users')
            .doc(friendId)
            .get();

        if (!document.exists) continue;

        final data = document.data();

        if (data == null) continue;

        friends.add({'uid': friendId, ...data});
      } catch (e) {
        debugPrint('Error loading friend $friendId: $e');
      }
    }

    // Sort alphabetically
    friends.sort((a, b) {
      final nameA = (a['name'] ?? a['username'] ?? 'Student')
          .toString()
          .toLowerCase();

      final nameB = (b['name'] ?? b['username'] ?? 'Student')
          .toString()
          .toLowerCase();

      return nameA.compareTo(nameB);
    });

    return friends;
  }

  // ============================================================
  // OPEN ADD FRIEND
  // ============================================================

  Future<void> _openAddFriend() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFriendPage()),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // OPEN CHAT
  // ============================================================

  void _openChat(Map<String, dynamic> friend) {
    final friendUid = friend['uid']?.toString() ?? '';

    if (friendUid.isEmpty) {
      _showMessage('Unable to open chat.');
      return;
    }

    final name = friend['name']?.toString().trim();

    final username = friend['username']?.toString().trim();

    final receiverName = name != null && name.isNotEmpty
        ? name
        : username != null && username.isNotEmpty
        ? username
        : 'Student';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatPage(receiverId: friendUid, receiverName: receiverName),
      ),
    );
  }

  // ============================================================
  // REMOVE FRIEND
  // ============================================================

  Future<void> _removeFriend(String friendUid, String friendName) async {
    final user = currentUser;

    if (user == null) {
      _showMessage('Please login first.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Remove Friend?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Remove $friendName from your friends?',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final currentUserRef = _firestore.collection('users').doc(user.uid);

      final friendRef = _firestore.collection('users').doc(friendUid);

      await currentUserRef.set({
        'friends': FieldValue.arrayRemove([friendUid]),
      }, SetOptions(merge: true));

      await friendRef.set({
        'friends': FieldValue.arrayRemove([user.uid]),
      }, SetOptions(merge: true));

      if (!mounted) return;

      _showMessage('$friendName removed from friends.', success: true);
    } catch (e) {
      debugPrint('Remove friend error: $e');

      if (!mounted) return;

      _showMessage('Unable to remove friend.');
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, {bool success = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  // GET INITIAL
  // ============================================================

  String _getInitial(Map<String, dynamic> friend) {
    final name = friend['name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name.substring(0, 1).toUpperCase();
    }

    final username = friend['username']?.toString().trim();

    if (username != null && username.isNotEmpty) {
      return username.substring(0, 1).toUpperCase();
    }

    return 'S';
  }

  // ============================================================
  // FRIEND CARD
  // ============================================================

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    final uid = friend['uid']?.toString() ?? '';

    final name = friend['name']?.toString().trim();

    final username = friend['username']?.toString().trim();

    final displayName = name != null && name.isNotEmpty
        ? name
        : username != null && username.isNotEmpty
        ? username
        : 'Student';

    final displayUsername = username != null && username.isNotEmpty
        ? '@$username'
        : '';

    final college = friend['college']?.toString().trim();

    final collegeText = college != null && college.isNotEmpty
        ? college
        : 'GroupNote user';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            _openChat(friend);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // ==================================================
                // AVATAR
                // ==================================================
                CircleAvatar(
                  radius: 27,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    _getInitial(friend),
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 13),

                // ==================================================
                // NAME
                // ==================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 3),

                      if (displayUsername.isNotEmpty)
                        Text(
                          displayUsername,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                      const SizedBox(height: 3),

                      Text(
                        collegeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ==================================================
                // CHAT BUTTON
                // ==================================================
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: IconButton(
                    tooltip: 'Chat',
                    onPressed: () {
                      _openChat(friend);
                    },
                    icon: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),

                // ==================================================
                // MENU
                // ==================================================
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF64748B),
                  ),
                  onSelected: (value) {
                    if (value == 'remove') {
                      _removeFriend(uid, displayName);
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_remove_outlined,
                              color: Color(0xFFDC2626),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text('Remove Friend'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: Color(0xFF2563EB),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No friends yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Find your classmates and start chatting.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: _openAddFriend,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Friends'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Color(0xFFDC2626),
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load friends',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 60,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(height: 15),
              const Text(
                'Please login first',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),

        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            tooltip: 'Add Friend',
            onPressed: _openAddFriend,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF2563EB),
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream(),

        builder: (context, snapshot) {
          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            );
          }

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          }

          // ------------------------------------------------------
          // USER DOCUMENT DOES NOT EXIST
          // ------------------------------------------------------

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 60,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Profile not found',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please complete your profile first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            );
          }

          // ------------------------------------------------------
          // GET FRIEND IDS
          // ------------------------------------------------------

          final data = snapshot.data!.data();

          final rawFriends = data?['friends'];

          List<dynamic> friendIds = [];

          if (rawFriends is List) {
            friendIds = rawFriends;
          }

          // ------------------------------------------------------
          // NO FRIENDS
          // ------------------------------------------------------

          if (friendIds.isEmpty) {
            return _buildEmptyState();
          }

          // ------------------------------------------------------
          // LOAD FRIEND DETAILS
          // ------------------------------------------------------

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getFriends(friendIds),

            builder: (context, friendSnapshot) {
              if (friendSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                );
              }

              if (friendSnapshot.hasError) {
                return _buildErrorState(friendSnapshot.error!);
              }

              final friends = friendSnapshot.data ?? [];

              if (friends.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                color: const Color(0xFF2563EB),
                onRefresh: () async {
                  setState(() {});
                  await Future<void>.delayed(const Duration(milliseconds: 300));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Friends',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Tap a friend to start chatting',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${friends.length}',
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // FRIENDS
                    // ==================================================
                    ...friends.map((friend) => _buildFriendCard(friend)),
                  ],
                ),
              );
            },
          );
        },
      ),

      // ==========================================================
      // ADD FRIEND FAB
      // ==========================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddFriend,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Add Friend',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
