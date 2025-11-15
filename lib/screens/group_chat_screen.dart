import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animations/animations.dart';
import 'package:spring_button/spring_button.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../widgets/upload/UploadPopup.dart';

class GroupChatScreen extends StatefulWidget {
  static const String routeName = '/group-chat';
  final GroupChatArgs args;

  const GroupChatScreen({Key? key, required this.args}) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> with TickerProviderStateMixin {
  final APIService _apiService = APIService();
  late List<ChatMessage> messages;
  late bool loading;
  String? _lastMessageId;
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;
  bool _showScrollToBottom = false;
  Map<String, dynamic>? _groupDetails;
  List<dynamic>? _groupMembers;
  List<dynamic> _groupImages = [];
  bool _loadingGroupData = true;
  late AnimationController _fabAnimationController;
  Timer? _refreshTimer;
  String? _lastFetchedMessageId;


  // App color scheme matching dashboard
  static const Color primaryBlue = Color(0xFF0D1F2D);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color lightGray = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    print('initState called');
    messages = [];
    loading = false;

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Start periodic refresh
    _startPeriodicRefresh();

    Future.microtask(() async {
      await _initializeChat();
      _setupScrollListener();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && !loading) {
        _checkForNewMessages();
      }
    });
  }

  Future<void> _checkForNewMessages() async {
    try {
      final result = await APIService.getGroupDetails(
        groupId: widget.args.groupId,
        code: widget.args.groupCode ?? '',
        uid: widget.args.uid,
      );
      if (result['success'] == true && mounted) {
        final List<dynamic> messagesData = result['messages'] ?? [];
        if (messagesData.isNotEmpty) {
          final String latestMessageId = messagesData.first['id']?.toString() ?? '';

          // Check if we have new messages
          if (_lastFetchedMessageId != latestMessageId) {
            setState(() {
              // Convert API messages to ChatMessage objects
              messages = messagesData.map((msg) => ChatMessage(
                id: msg['id']?.toString() ?? '',
                username: msg['username']?.toString() ?? 'Unknown',
                imageUrl: msg['imageUrl']?.toString(),
                downloadUrl: msg['downloadUrl']?.toString(),
                viewUrl: msg['viewUrl']?.toString(),
                timestamp: DateTime.parse(msg['timestamp'] ?? DateTime.now().toIso8601String()),
                title: msg['title']?.toString() ?? '',
                size: msg['size']?.toString(),
                isMyMessage: msg['uid']?.toString() == widget.args.uid.toString(),  // Ensure string comparison
              )).toList();

              _lastFetchedMessageId = latestMessageId;
              _groupDetails = result['group'];
              _groupMembers = result['members'];
            });

            // If we're already at the bottom, scroll to show new message
            if (_scrollController.hasClients &&
                _scrollController.position.pixels == 0) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error in periodic refresh: $e');
    }
  }

  Future<void> _initializeChat() async {
    print('_initializeChat called');
    if (loading) {
      print('Loading is true, returning early');
      return;
    }
    setState(() {
      loading = true;
      messages = [];
      _lastMessageId = null;
      _hasMore = true;
    });

    print('Starting to fetch data...');
    try {
      await Future.wait([
        _fetchGroupDetails(),
        // _fetchMessages(),
      ]);
      print('Both fetches completed');
    } catch (e) {
      print('Error in _initializeChat: $e');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _fetchGroupDetails() async {
    print('_fetchGroupDetails called');
    setState(() => _loadingGroupData = true);
    try {
      final details = await APIService.getGroupDetails(
        groupId: widget.args.groupId,
        code: widget.args.groupCode ?? '',
        uid: widget.args.uid,
      );

      if (details['success'] == true && mounted) {
        final groupData = details['group'];
        final List<dynamic> messagesData = details['messages'] ?? [];

        setState(() {
          _groupDetails = groupData;
          _groupMembers = details['members'];

          // Convert API messages to ChatMessage objects
          messages = messagesData.map((msg) => ChatMessage(
            id: msg['id']?.toString() ?? '',
            username: msg['username']?.toString() ?? 'Unknown',
            imageUrl: msg['imageUrl']?.toString(),
            downloadUrl: msg['downloadUrl']?.toString(),
            viewUrl: msg['viewUrl']?.toString(),
            timestamp: DateTime.parse(msg['timestamp'] ?? DateTime.now().toIso8601String()),
            title: msg['title']?.toString() ?? '',
            size: msg['size']?.toString(),
            isMyMessage: msg['uid']?.toString() == widget.args.uid.toString(),  // Ensure string comparison
          )).toList();

          if (messages.isNotEmpty) {
            _lastMessageId = messages.last.id;
          }
          _loadingGroupData = false;
        });

        // Auto-scroll to bottom (latest messages) after loading
        if (messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              // With reverse: true, position 0 is the bottom (latest messages)
              _scrollController.jumpTo(0);
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(details['message'] ?? 'Failed to load group details')),
          );
        }
      }
    } catch (e) {
      print('Error in _fetchGroupDetails: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load group details')),
        );
      }
    }
    if (mounted) setState(() => _loadingGroupData = false);
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Show/hide scroll to bottom button with animation
      // With reverse: true, we need to check if we're NOT at position 0 (bottom)
      if (_scrollController.position.pixels > 500) {
        if (!_showScrollToBottom) {
          setState(() => _showScrollToBottom = true);
          _fabAnimationController.forward();
        }
      } else {
        if (_showScrollToBottom) {
          setState(() => _showScrollToBottom = false);
          _fabAnimationController.reverse();
        }
      }

      // Removed automatic load more messages when reaching top
      // Users can now only refresh manually using the refresh button in the app bar
    });
  }

  // Add the missing _loadMoreMessages method
  Future<void> _loadMoreMessages() async {
    if (loading || !_hasMore) return;

    // For now, we'll call the existing fetch method
    // In a real implementation, you'd want to fetch older messages using pagination
    await _fetchGroupDetails();
  }

  Widget _buildShimmerMessagesList() {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: 5, // Show 5 shimmer items
      itemBuilder: (context, index) {
        final bool isLeft = index % 2 == 0;
        return Padding(
          padding: EdgeInsets.only(
            left: isLeft ? 0 : 60,
            right: isLeft ? 60 : 0,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (isLeft) _buildShimmerUsernameLabel(),
              const SizedBox(height: 4),
              _buildShimmerMessageBubble(isLeft),
              const SizedBox(height: 4),
              _buildShimmerTimeStamp(isLeft),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerUsernameLabel() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 120,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildShimmerMessageBubble(bool isLeft) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildShimmerTimeStamp(bool isLeft) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 80,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // Scroll to bottom to see latest messages
  void _scrollToBottom() {
    HapticFeedback.selectionClick();
    _scrollController.animateTo(
      0, // With reverse: true, position 0 is the bottom (latest messages)
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _handleImageSelection() async {
    HapticFeedback.mediumImpact();
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => loading = true);

        // Show loading indicator in a snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Sending image...'),
                ],
              ),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        final result = await _apiService.sendImageMessage(
          groupId: widget.args.groupId,
          code: widget.args.groupCode ?? '',
          uid: widget.args.uid,
          username: widget.args.username,
          file: File(image.path),
        );

        if (result['success'] == true) {
          // Fetch latest messages
          await _fetchGroupDetails();

          // Scroll to bottom to show new message
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }

          // Show success feedback
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 12),
                    const Text('Image sent successfully'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                    const SizedBox(width: 12),
                    Text(result['message'] ?? 'Failed to send image'),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error picking/sending image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onError,
                ),
                const SizedBox(width: 12),
                const Text('Failed to send image. Please try again.'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  void _showSharedImageFullScreen(Map<String, dynamic> image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: _FullScreenImageViewer(
          imageUrl: image['link'],
          username: image['username'] ?? 'Unknown',
          timestamp: image['timestamp'] ?? '',
        ),
      ),
    );
  }

  Future<void> _copyGroupCode() async {
    if (widget.args.groupCode != null) {
      await Clipboard.setData(ClipboardData(text: widget.args.groupCode!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group code copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showShareGroupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Share Group',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share this group code with others:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.args.groupCode ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyGroupCode,
                      tooltip: 'Copy code',
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (widget.args.groupCode != null) {
                  await Share.share('Join my PicDB group with code: ${widget.args.groupCode}');
                }
              },
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupCodeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Group Code: ${widget.args.groupCode ?? "N/A"}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: _copyGroupCode,
            tooltip: 'Copy group code',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: _buildModernAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryBlue.withOpacity(0.03),
              lightGray,
              surfaceColor,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                if (_loadingGroupData) _buildLoadingHeader(),
                if (!_loadingGroupData && messages.isEmpty) _buildEmptyState(),
                Expanded(child: _buildMessagesList()),
                _buildModernMessageInput(),
              ],
            ),
            // Floating scroll to bottom button in right corner
            Positioned(
              right: 16,
              bottom: 80, // Position above the message input
              child: _buildScrollToBottomButton(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: primaryBlue,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: _loadingGroupData
          ? _buildLoadingTitle()
          : _buildGroupTitle(),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refreshMessages,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: () => _showGroupInfo(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _groupDetails?['name'] ?? 'Group Chat',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accentGreen,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${_groupMembers?.length ?? 0} members',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: accentBlue,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Loading conversation...',
            style: TextStyle(
              color: primaryBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: accentBlue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Start the conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send your first image to get started!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_loadingGroupData) {
      return _buildShimmerMessagesList();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        return false;
      },
      child: AnimationLimiter(
        child: ListView.builder(
          // Use reverse: true to show latest messages at bottom
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: messages.length + (loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == messages.length && loading) {
              return _buildLoadingIndicator();
            }

            // Reverse the message index since we're using reverse: true
            final messageIndex = messages.length - 1 - index;
            final message = messages[messageIndex];
            final bool isFirstMessageOfDay = messageIndex == messages.length - 1 ||
                !_isSameDay(message.timestamp, messages[messageIndex + 1].timestamp);

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: Column(
                    children: [
                      if (isFirstMessageOfDay)
                        _buildDateDivider(message.timestamp),
                      _buildEnhancedMessageBubble(message),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Add refresh messages method
  Future<void> _refreshMessages() async {
    if (loading) return;

    HapticFeedback.mediumImpact();
    await _fetchGroupDetails();

    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text('Messages refreshed'),
            ],
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: accentBlue,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more messages...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isMyMessage ? 60 : 0,
        right: message.isMyMessage ? 0 : 60,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: message.isMyMessage
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!message.isMyMessage) _buildUsernameLabel(message),
          _buildMessageContainer(message),
          _buildMessageFooter(message),
        ],
      ),
    );
  }

  Widget _buildUsernameLabel(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getUserColor(message.username),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                message.username.isNotEmpty ? message.username[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            message.username,
            style: TextStyle(
              fontSize: 13,
              color: _getUserColor(message.username),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContainer(ChatMessage message) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: message.isMyMessage ? primaryBlue : surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(message.isMyMessage ? 20 : 6),
          bottomRight: Radius.circular(message.isMyMessage ? 6 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: message.imageUrl != null
          ? _buildEnhancedImageMessage(message)
          : _buildTextMessage(message),
    );
  }

  Widget _buildTextMessage(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        message.title,
        style: TextStyle(
          color: message.isMyMessage ? Colors.white : primaryBlue,
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildEnhancedImageMessage(ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: GestureDetector(
            onTap: () => _showImageFullScreen(message),
            child: Hero(
              tag: 'image_${message.id}',
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      message.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: _buildImageLoadingBuilder,
                      errorBuilder: _buildImageErrorBuilder,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Show message details if title exists or show default "Photo" text
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.title.isNotEmpty ? message.title : 'Photo',
                style: TextStyle(
                  color: message.isMyMessage ? Colors.white : primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (message.size?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  _formatFileSize(message.size!),
                  style: TextStyle(
                    color: (message.isMyMessage ? Colors.white : primaryBlue)
                        .withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageLoadingBuilder(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: accentBlue,
              strokeWidth: 3,
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading image...',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      color: Colors.grey.shade100,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_rounded,
            color: Colors.grey,
            size: 48,
          ),
          SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFooter(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        left: message.isMyMessage ? 0 : 16,
        right: message.isMyMessage ? 16 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(message.timestamp),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (message.isMyMessage) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.check_rounded,
              size: 14,
              color: accentGreen,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImagePickerButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return SpringButton(
      SpringButtonType.OnlyScale,
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accentBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accentBlue.withOpacity(0.2)),
        ),
        child: Icon(
          Icons.add_photo_alternate_rounded,
          color: accentBlue,
          size: 22,
        ),
      ),
      onTap: _handleImageSelection,
      scaleCoefficient: 0.95,
    );
  }

  Widget _buildScrollToBottomButton() {
    return ScaleTransition(
      scale: _fabAnimationController,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.small(
          backgroundColor: primaryBlue,
          elevation: 4,
          onPressed: _scrollToBottom,
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Color _getUserColor(String username) {
    final colors = [
      accentBlue,
      accentGreen,
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
    ];
    return colors[username.hashCode.abs() % colors.length];
  }

  String _formatFileSize(String size) {
    try {
      final sizeNum = double.parse(size.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (sizeNum < 1024) return '${sizeNum.toStringAsFixed(1)} KB';
      if (sizeNum < 1024 * 1024) return '${(sizeNum / 1024).toStringAsFixed(1)} MB';
      return '${(sizeNum / (1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return size;
    }
  }

  void _showImageFullScreen(ChatMessage message) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenImageViewer(
              imageUrl: message.imageUrl!,
              username: message.username,
              timestamp: _formatTime(message.timestamp),
              heroTag: 'image_${message.id}',
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(date); // Day of week
    }
    return DateFormat('MMM d, y').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  void _showGroupInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _GroupInfoBottomSheet(
        groupDetails: _groupDetails,
        groupMembers: _groupMembers,
        totalMessages: messages.length,
        onShare: () {
          // This callback is called when the share action is triggered
          _showShareGroupDialog();
        },
      ),
    );
  }

  void _pickImage(BuildContext context) {
    _handleImageSelection();
  }
}

class _GroupInfoBottomSheet extends StatelessWidget {
  final Map<String, dynamic>? groupDetails;
  final List<dynamic>? groupMembers;
  final int totalMessages;
  final VoidCallback onShare; // Add this callback

  // App color scheme constants for this widget
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentGreen = Color(0xFF4CAF50);

  const _GroupInfoBottomSheet({
    required this.groupDetails,
    required this.groupMembers,
    required this.totalMessages,
    required this.onShare, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0D1F2D),
            const Color(0xFF0D1F2D).withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: const Color(0xFF2196F3).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.groups_rounded,
              size: 40,
              color: Color(0xFF2196F3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            groupDetails?['name'] ?? 'Group Chat',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${groupMembers?.length ?? 0} members',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildMembersSection(),
          const SizedBox(height: 24),
          _buildActionsSection(context),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    print(groupMembers);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Messages',
              totalMessages.toString(),
              Icons.chat_bubble_outline_rounded,
              const Color(0xFF2196F3),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Members',
              '${groupMembers?.length ?? 0}',
              Icons.people_outline_rounded,
              const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Members',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1F2D),
          ),
        ),
        const SizedBox(height: 12),
        if (groupMembers?.isNotEmpty == true)
          ...groupMembers!.take(5).map((member) => _buildMemberTile(member))
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 12),
                Text(
                  'No members to display',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMemberTile(dynamic member) {
    final username = member['username'] ?? member['name'] ?? 'Unknown';
    final isOnline = member['isOnline'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getUserColor(username),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1F2D),
                  ),
                ),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? const Color(0xFF4CAF50) : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0D1F2D),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'Share Group',
          'Invite others to join this group',
          Icons.share_rounded,
          const Color(0xFF2196F3),
          () => _shareGroup(context),
        ),
        // _buildActionTile(
        //   'Group Settings',
        //   'Manage group preferences',
        //   Icons.settings_rounded,
        //   const Color(0xFFFF9800),
        //   () => _openSettings(context),
        // ),
        // _buildActionTile(
        //   'Leave Group',
        //   'Exit this group conversation',
        //   Icons.exit_to_app_rounded,
        //   const Color(0xFFE91E63),
        //   () => _leaveGroup(context),
        // ),
      ],
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D1F2D),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUserColor(String username) {
    final colors = [
      accentBlue,
      accentGreen,
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFE91E63),
      const Color(0xFF00BCD4),
    ];
    return colors[username.hashCode.abs() % colors.length];
  }

  void _shareGroup(BuildContext context) {
    onShare(); // Show dialog first
    Navigator.pop(context); // Close bottom sheet after
  }

  void _openSettings(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Group settings feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _leaveGroup(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group? You won\'t be able to see new messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF0D1F2D)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Close the chat screen too
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String timestamp;
  final String? heroTag;

  const _FullScreenImageViewer({
    required this.imageUrl,
    required this.username,
    required this.timestamp,
    this.heroTag,
  });

  String _getFileName() {
    try {
      return imageUrl.split('/').last;
    } catch (e) {
      return 'Image';
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Image Info'),
              onTap: () {
                Navigator.pop(context);
                _showImageInfo(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showImageInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UploadPopup(
        imageUrl: imageUrl,
        imageName: _getFileName(),
        viewUrl: imageUrl.replaceAll('/v/', '/d/'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(128),
        elevation: 0,
        title: Text(_getFileName(), style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ChatArguments {
  final String username;
  final String uid;

  ChatArguments({
    required this.username,
    required this.uid,
  });
}

class GroupChatArgs {
  final String username;
  final String uid;
  final String groupId;
  final String groupName;
  final String? groupCode;

  GroupChatArgs({
    required this.username,
    required this.uid,
    required this.groupId,
    required this.groupName,
    this.groupCode,
  });
}

class ChatMessage {
  final String id;
  final String username;
  final String? imageUrl;
  final String? downloadUrl;
  final String? viewUrl;
  final DateTime timestamp;
  final String title;
  final String? size;  // Changed from int to String
  final bool isMyMessage;

  ChatMessage({
    required this.id,
    required this.username,
    this.imageUrl,
    this.downloadUrl,
    this.viewUrl,
    required this.timestamp,
    required this.title,
    this.size,
    required this.isMyMessage,
  });
}

