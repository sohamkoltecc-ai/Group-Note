import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController searchController = TextEditingController();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Timer? _debounce;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> users = [];

  bool searching = false;
  String searchText = '';

  @override
  void initState() {
    super.initState();

    searchController.addListener(_onSearchChanged);
  }

  // ============================================================
  // SEARCH TEXT CHANGED
  // ============================================================

  void _onSearchChanged() {
    final text = searchController.text.trim().toLowerCase();

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 400), () {
      searchUsers(text);
    });

    if (mounted) {
      setState(() {
        searchText = text;
      });
    }
  }

  // ============================================================
  // SEARCH USERS
  // ============================================================

  Future<void> searchUsers(String username) async {
    username = username.trim().toLowerCase();

    if (username.isEmpty) {
      if (!mounted) return;

      setState(() {
        users = [];
        searching = false;
        searchText = '';
      });

      return;
    }

    if (mounted) {
      setState(() {
        searching = true;
        searchText = username;
      });
    }

    try {
      /*
       IMPORTANT:

       Firestore username field lowercase hona chahiye.

       Example:

       username: "kaivalya_patait"

       Search:
       "kaivalya"
       "kaivalya_"
       "kaivalya_patait"

       sab kaam karega.
      */

      final result = await firestore
          .collection('users')
          .orderBy('username')
          .startAt([username])
          .endAt(['$username\uf8ff'])
          .limit(20)
          .get();

      if (!mounted) return;

      setState(() {
        users = result.docs;
        searching = false;
      });
    } catch (e) {
      debugPrint('SEARCH USER ERROR: $e');

      if (!mounted) return;

      setState(() {
        users = [];
        searching = false;
      });

      _showMessage('Search failed. Check Firestore users collection.');
    }
  }

  // ============================================================
  // ADD FRIEND
  // ============================================================

  Future<void> addFriend(String friendUid, Map<String, dynamic> data) async {
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      _showMessage('Please login first.');
      return;
    }

    if (friendUid == currentUser.uid) {
      _showMessage('You cannot add yourself.');
      return;
    }

    try {
      final currentUserRef = firestore.collection('users').doc(currentUser.uid);

      final friendRef = firestore.collection('users').doc(friendUid);

      // --------------------------------------------------------
      // ADD FRIEND TO CURRENT USER
      // --------------------------------------------------------

      await currentUserRef.set({
        'friends': FieldValue.arrayUnion([friendUid]),
      }, SetOptions(merge: true));

      // --------------------------------------------------------
      // ADD CURRENT USER TO OTHER USER
      // --------------------------------------------------------

      await friendRef.set({
        'friends': FieldValue.arrayUnion([currentUser.uid]),
      }, SetOptions(merge: true));

      if (!mounted) return;

      final name = data['name']?.toString().trim().isNotEmpty == true
          ? data['name'].toString()
          : data['username']?.toString() ?? 'User';

      _showMessage('$name added successfully!', success: true);
    } catch (e) {
      debugPrint('ADD FRIEND ERROR: $e');

      _showMessage('Unable to add friend.');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // USER CARD
  // ============================================================

  Widget _buildUserCard(QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();

    final String name = data['name']?.toString().trim().isNotEmpty == true
        ? data['name'].toString().trim()
        : 'Student';

    final String username =
        data['username']?.toString().trim().isNotEmpty == true
        ? data['username'].toString().trim()
        : 'username';

    final String college = data['college']?.toString().trim().isNotEmpty == true
        ? data['college'].toString().trim()
        : 'Student';

    final String initial = name.isNotEmpty
        ? name.substring(0, 1).toUpperCase()
        : 'S';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

        // ------------------------------------------------------
        // PROFILE
        // ------------------------------------------------------
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFFEFF6FF),
          child: Text(
            initial,
            style: const TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),

        // ------------------------------------------------------
        // NAME
        // ------------------------------------------------------
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),

        // ------------------------------------------------------
        // USERNAME + COLLEGE
        // ------------------------------------------------------
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),

            Text(
              '@$username',
              style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              college,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),

        // ------------------------------------------------------
        // ADD BUTTON
        // ------------------------------------------------------
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddFriendPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Add',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _debounce?.cancel();

    searchController.removeListener(_onSearchChanged);

    searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,

        title: const Text(
          'Add Friends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // ======================================================
          // SEARCH HEADER
          // ======================================================
          Container(
            width: double.infinity,

            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),

            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),

              borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find your friends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Search by username',
                  style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 13),
                ),

                const SizedBox(height: 16),

                // ------------------------------------------------
                // SEARCH BOX
                // ------------------------------------------------
                TextField(
                  controller: searchController,

                  textInputAction: TextInputAction.search,

                  decoration: InputDecoration(
                    hintText: 'Search username...',

                    prefixIcon: const Icon(Icons.search_rounded),

                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                            },
                            icon: const Icon(Icons.clear_rounded),
                          )
                        : null,

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // RESULTS
          // ======================================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: _buildResults(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RESULTS
  // ============================================================

  Widget _buildResults() {
    // ----------------------------------------------------------
    // SEARCHING
    // ----------------------------------------------------------

    if (searching) {
      return const Center(child: CircularProgressIndicator());
    }

    // ----------------------------------------------------------
    // NOTHING SEARCHED
    // ----------------------------------------------------------

    if (searchText.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 65,
              color: Color(0xFFCBD5E1),
            ),

            SizedBox(height: 12),

            Text(
              'Search for a friend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),

            SizedBox(height: 4),

            Text(
              'Enter their username above',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // NO USER
    // ----------------------------------------------------------

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 60,
              color: Color(0xFFCBD5E1),
            ),

            const SizedBox(height: 12),

            const Text(
              'No user found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'No account found for @$searchText',
              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // USERS
    // ----------------------------------------------------------

    return ListView.builder(
      physics: const BouncingScrollPhysics(),

      itemCount: users.length,

      itemBuilder: (context, index) {
        return _buildUserCard(users[index]);
      },
    );
  }
}
