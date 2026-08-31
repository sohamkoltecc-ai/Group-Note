import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatPage({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  // ============================================================
  // SERVICES
  // ============================================================

  final ChatService chatService = ChatService();

  // ============================================================
  // STATE
  // ============================================================

  bool isSending = false;
  bool isSearching = false;
  bool notificationsEnabled = true;

  String searchText = '';

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => FirebaseAuth.instance.currentUser;

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    if (text.isEmpty) return;

    final user = currentUser;

    if (user == null) {
      _showMessage('Please login first');
      return;
    }

    if (widget.receiverId.trim().isEmpty) {
      _showMessage('Receiver not found');
      return;
    }

    if (isSending) return;

    setState(() {
      isSending = true;
    });

    final message = text;

    messageController.clear();

    try {
      await chatService.sendMessage(
        senderId: user.uid,
        receiverId: widget.receiverId,
        message: message,
      );

      if (!mounted) return;

      _scrollToBottom();
    } catch (e) {
      messageController.text = message;

      if (!mounted) return;

      _showMessage('Message failed');
    } finally {
      if (!mounted) return;

      setState(() {
        isSending = false;
      });
    }
  }

  // ============================================================
  // SCROLL TO BOTTOM
  // ============================================================

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted || !scrollController.hasClients) return;

      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  // RECEIVER INITIAL
  // ============================================================

  String getReceiverInitial() {
    final name = widget.receiverName.trim();

    if (name.isEmpty) {
      return '?';
    }

    return name.substring(0, 1).toUpperCase();
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    final date = timestamp.toDate();

    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
        ? 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void openSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void closeSearch() {
    searchController.clear();

    setState(() {
      searchText = '';
      isSearching = false;
    });
  }

  // ============================================================
  // NOTIFICATION TOGGLE
  // ============================================================

  void toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });

    _showMessage(
      notificationsEnabled ? 'Notifications enabled' : 'Notifications muted',
    );
  }

  // ============================================================
  // MORE MENU
  // ============================================================

  void showMoreMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HANDLE
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                // SEARCH
                ListTile(
                  leading: _menuIcon(
                    Icons.search_rounded,
                    const Color(0xFFEFF6FF),
                    const Color(0xFF2563EB),
                  ),
                  title: const Text(
                    'Search messages',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    openSearch();
                  },
                ),

                // NOTIFICATIONS
                ListTile(
                  leading: _menuIcon(
                    notificationsEnabled
                        ? Icons.notifications_none_rounded
                        : Icons.notifications_off_outlined,
                    const Color(0xFFF3E8FF),
                    const Color(0xFF7C3AED),
                  ),
                  title: Text(
                    notificationsEnabled
                        ? 'Mute notifications'
                        : 'Turn on notifications',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    toggleNotifications();
                  },
                ),

                // CHAT INFO
                ListTile(
                  leading: _menuIcon(
                    Icons.info_outline_rounded,
                    const Color(0xFFECFDF5),
                    const Color(0xFF059669),
                  ),
                  title: const Text(
                    'Chat information',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    _showChatInfo();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // MENU ICON
  // ============================================================

  Widget _menuIcon(IconData icon, Color background, Color iconColor) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: iconColor),
    );
  }

  // ============================================================
  // CHAT INFO
  // ============================================================

  void _showChatInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 15, 24, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFE0E7FF),
                  child: Text(
                    getReceiverInitial(),
                    style: const TextStyle(
                      color: Color(0xFF4338CA),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  widget.receiverName.isEmpty ? 'Chat' : widget.receiverName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Student collaboration chat',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),

                const SizedBox(height: 20),

                _infoItem(Icons.verified_user_outlined, 'Secure Firebase Chat'),

                _infoItem(Icons.bolt_rounded, 'Real-time messaging'),

                _infoItem(
                  Icons.notifications_active_outlined,
                  notificationsEnabled
                      ? 'Notifications enabled'
                      : 'Notifications muted',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    messageController.dispose();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
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
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(
          child: Text(
            'Please login first',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        titleSpacing: 0,

        title: isSearching ? _buildSearchBar() : _buildChatTitle(),

        actions: [
          if (!isSearching)
            IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.search_rounded),
              onPressed: openSearch,
            ),

          if (isSearching)
            IconButton(
              tooltip: 'Close search',
              icon: const Icon(Icons.close_rounded),
              onPressed: closeSearch,
            ),

          if (!isSearching)
            IconButton(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: showMoreMenu,
            ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chatService.getMessages(user.uid, widget.receiverId),

              builder: (context, snapshot) {
                // ------------------------------------------------
                // LOADING
                // ------------------------------------------------

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                  );
                }

                // ------------------------------------------------
                // ERROR
                // ------------------------------------------------

                if (snapshot.hasError) {
                  return _buildError(snapshot.error);
                }

                // ------------------------------------------------
                // NO DATA
                // ------------------------------------------------

                if (!snapshot.hasData) {
                  return _emptyChat();
                }

                final messages = snapshot.data!.docs;

                // ------------------------------------------------
                // FILTER SEARCH
                // ------------------------------------------------

                final filteredMessages = messages.where((doc) {
                  if (searchText.trim().isEmpty) {
                    return true;
                  }

                  final data = doc.data();

                  final message =
                      data['message']?.toString().toLowerCase() ?? '';

                  return message.contains(searchText.toLowerCase());
                }).toList();

                // ------------------------------------------------
                // EMPTY
                // ------------------------------------------------

                if (filteredMessages.isEmpty) {
                  if (searchText.isNotEmpty) {
                    return _buildNoSearchResult();
                  }

                  return _emptyChat();
                }

                // ------------------------------------------------
                // MESSAGE LIST
                // ------------------------------------------------

                return ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
                  itemCount: filteredMessages.length,

                  itemBuilder: (context, index) {
                    final data = filteredMessages[index].data();

                    final senderId = data['senderId']?.toString() ?? '';

                    final message = data['message']?.toString() ?? '';

                    Timestamp? timestamp;

                    final timestampData = data['timestamp'];

                    if (timestampData is Timestamp) {
                      timestamp = timestampData;
                    }

                    final isMe = senderId == user.uid;

                    return _buildMessageBubble(
                      message: message,
                      timestamp: timestamp,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          // ========================================================
          // INPUT
          // ========================================================
          _buildMessageInput(),
        ],
      ),
    );
  }

  // ============================================================
  // CHAT TITLE
  // ============================================================

  Widget _buildChatTitle() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE9D5FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              getReceiverInitial(),
              style: const TextStyle(
                color: Color(0xFF6D28D9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.receiverName.trim().isEmpty
                    ? 'Chat'
                    : widget.receiverName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 2),

              const Row(
                children: [
                  Icon(Icons.circle, size: 7, color: Color(0xFF86EFAC)),
                  SizedBox(width: 5),
                  Text(
                    'Active now',
                    style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TextField(
        controller: searchController,
        autofocus: true,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: const InputDecoration(
          hintText: 'Search messages...',
          hintStyle: TextStyle(color: Color(0xFFBFDBFE)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 38,
                color: Color(0xFFEF4444),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load messages',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NO SEARCH RESULT
  // ============================================================

  Widget _buildNoSearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 35,
              color: Color(0xFF2563EB),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No messages found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Try another keyword',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY CHAT
  // ============================================================

  Widget _emptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE0E7FF), Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Icon(
              Icons.forum_rounded,
              size: 39,
              color: Color(0xFF4338CA),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Send ${widget.receiverName.isEmpty ? 'a message' : 'a message to ${widget.receiverName}'} 👋',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MESSAGE BUBBLE
  // ============================================================

  Widget _buildMessageBubble({
    required String message,
    required Timestamp? timestamp,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),

        margin: const EdgeInsets.only(bottom: 8),

        padding: const EdgeInsets.fromLTRB(14, 11, 10, 7),

        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],

          border: isMe ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: isMe ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTime(timestamp),
                  style: TextStyle(
                    fontSize: 9,
                    color: isMe
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFF94A3B8),
                  ),
                ),

                if (isMe) ...[
                  const SizedBox(width: 4),

                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Color(0xFFBFDBFE),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE INPUT
  // ============================================================

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ====================================================
            // PLUS
            // ====================================================
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(15),
              ),

              child: IconButton(
                tooltip: 'More',
                onPressed: () {
                  _showAttachmentMenu();
                },
                icon: const Icon(Icons.add_rounded, color: Color(0xFF475569)),
              ),
            ),

            const SizedBox(width: 8),

            // ====================================================
            // TEXT FIELD
            // ====================================================
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 44,
                  maxHeight: 120,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: TextField(
                  controller: messageController,

                  minLines: 1,
                  maxLines: 4,

                  textCapitalization: TextCapitalization.sentences,

                  textInputAction: TextInputAction.newline,

                  onSubmitted: (_) {
                    sendMessage();
                  },

                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF111827),
                  ),

                  decoration: const InputDecoration(
                    hintText: 'Write a message...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),

                    border: InputBorder.none,

                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 11,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ====================================================
            // SEND
            // ====================================================
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              width: 46,
              height: 46,

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(16),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: IconButton(
                tooltip: 'Send',
                onPressed: isSending ? null : sendMessage,

                icon: isSending
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 21,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ATTACHMENT MENU
  // ============================================================

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Share something',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _attachmentOption(
                        Icons.image_outlined,
                        'Photo',
                        const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _attachmentOption(
                        Icons.insert_drive_file_outlined,
                        'File',
                        const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _attachmentOption(
                        Icons.link_rounded,
                        'Link',
                        const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ATTACHMENT OPTION
  // ============================================================

  Widget _attachmentOption(IconData icon, String title, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pop(context);

        _showMessage('$title sharing will be added soon');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
