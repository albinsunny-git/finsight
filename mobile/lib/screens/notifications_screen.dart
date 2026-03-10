import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finsight_mobile/screens/voucher_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = data['notifications'] ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int? id) async {
    final success = await _apiService.markNotificationAsRead(id: id);
    if (success) {
      _fetchNotifications();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to mark notification as read'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final success = await _apiService.clearNotifications();
    if (success) {
      _fetchNotifications();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to clear notifications'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notif) async {
    if (notif['is_read'] != 1) {
      await _markAsRead(int.tryParse(notif['id'].toString()));
    }

    final relatedId = notif['related_id'];
    if (relatedId != null && relatedId.toString().isNotEmpty) {
      try {
        final voucherId = int.tryParse(relatedId.toString());
        if (voucherId != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Loading voucher...'),
                duration: Duration(milliseconds: 500),
              ),
            );
          }
          final details = await _apiService.getVoucherDetails(voucherId);
          if (details.isNotEmpty && mounted) {
            final prefs = await SharedPreferences.getInstance();
            final userDataString = prefs.getString('user_data');
            String role = 'Admin';
            String uid = '';
            if (userDataString != null) {
              final ud = jsonDecode(userDataString);
              role = ud['role'] ?? 'Admin';
              uid = ud['id']?.toString() ?? '';
            }
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => VoucherDetailScreen(
                  voucher: details,
                  userRole: role,
                  currentUserId: uid,
                ),
              ),
            );
            _fetchNotifications();
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Voucher not found or access denied.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: [
          const ThemeToggleButton(),
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical),
              onSelected: (value) {
                if (value == 'mark_read') {
                  _markAsRead(null);
                } else if (value == 'clear') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Notifications'),
                      content: const Text(
                          'Are you sure you want to delete all notifications?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearAll();
                          },
                          child: const Text('Clear',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'mark_read',
                  child: Row(
                    children: [
                      Icon(LucideIcons.checkCheck, size: 18),
                      SizedBox(width: 8),
                      Text('Mark all as read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear all', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isRead = notif['is_read'] == 1;

                      IconData iconData = LucideIcons.bell;
                      Color iconColor = theme.primaryColor;

                      if (notif['type'] == 'success') {
                        iconData = LucideIcons.checkCircle;
                        iconColor = Colors.green;
                      } else if (notif['type'] == 'error') {
                        iconData = LucideIcons.alertCircle;
                        iconColor = Colors.red;
                      } else if (notif['type'] == 'warning') {
                        iconData = LucideIcons.alertTriangle;
                        iconColor = Colors.orange;
                      }

                      return Material(
                        color: isRead
                            ? Colors.transparent
                            : theme.primaryColor.withOpacity(0.05),
                        child: InkWell(
                          onTap: () => _handleNotificationTap(notif),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: iconColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(iconData,
                                      color: iconColor, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif['message'] ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: isRead
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                          color: isRead
                                              ? Colors.grey[600]
                                              : theme
                                                  .textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatTime(notif['created_at']),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(LucideIcons.bellOff, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll let you know when something\nimportant happens.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
