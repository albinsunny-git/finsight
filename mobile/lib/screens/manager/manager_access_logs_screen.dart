import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:finsight_mobile/screens/communication/chat_screen.dart';
import 'package:finsight_mobile/screens/communication/email_compose_screen.dart';



class ManagerAccessLogsScreen extends StatefulWidget {
  final String? initialSearchQuery;
  const ManagerAccessLogsScreen({super.key, this.initialSearchQuery});

  @override
  State<ManagerAccessLogsScreen> createState() => _ManagerAccessLogsScreenState();
}

class _ManagerAccessLogsScreenState extends State<ManagerAccessLogsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  List<dynamic> _accountants = [];
  List<dynamic> _logs = [];
  bool _isLoading = true;

  late TextEditingController _searchController;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery ?? "";
    _searchController = TextEditingController(text: _searchQuery);
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final users = await _apiService.getUsers();
      final logs = await _apiService.getAuditLogs();
      setState(() {
        _accountants = users.where((u) => u['role']?.toString().toLowerCase() == 'accountant').toList();
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0D0D17);
    const Color cardColor = Color(0xFF161625);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color borderColor = Color(0xFF1F1F35);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Access & Control",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryPurple,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.4),
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: "ACTIVITY LOGS"),
            Tab(text: "PERMISSIONS"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLogsTab(cardColor, borderColor, primaryPurple),
          _buildPermissionsTab(cardColor, borderColor, primaryPurple),
        ],
      ),
    );
  }

  Widget _buildLogsTab(Color cardColor, Color borderColor, Color primaryPurple) {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: primaryPurple));
    if (_logs.isEmpty) {
      return Center(
        child: Text("No activity logs found", style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
      );
    }

    final filteredLogs = _logs.where((log) {
      final name = log['user_name']?.toString().toLowerCase() ?? '';
      final action = log['action']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || action.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search logs by name or action...",
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white24, fontSize: 14),
                prefixIcon: const Icon(LucideIcons.search, color: Colors.white24, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredLogs.isEmpty
              ? Center(child: Text("No matching logs found", style: GoogleFonts.plusJakartaSans(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    final timestamp = DateTime.tryParse(log['timestamp'] ?? '');
                    final timeStr = timestamp != null
                        ? "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')} ${timestamp.hour >= 12 ? 'PM' : 'AM'}"
                        : "N/A";
                    final dateStr = timestamp != null ? "${timestamp.day} ${_getMonth(timestamp.month)} ${timestamp.year}" : "N/A";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryPurple.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getLogIcon(log['action'] ?? ''),
                              color: primaryPurple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        log['user_name'] ?? 'System',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.3)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  log['action'] ?? 'Action',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: primaryPurple.withOpacity(0.8), fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(LucideIcons.calendar, size: 12, color: Colors.white.withOpacity(0.2)),
                                    const SizedBox(width: 4),
                                    Text(dateStr, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.2))),
                                    if (log['ip_address'] != null) ...[
                                      const SizedBox(width: 12),
                                      Icon(LucideIcons.globe, size: 12, color: Colors.white.withOpacity(0.2)),
                                      const SizedBox(width: 4),
                                      Text(log['ip_address'], style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.2))),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _getLogIcon(String action) {
    action = action.toUpperCase();
    if (action.contains('LOGIN')) return LucideIcons.logIn;
    if (action.contains('VOUCHER')) return LucideIcons.fileText;
    if (action.contains('ACCOUNT')) return LucideIcons.wallet;
    if (action.contains('USER')) return LucideIcons.users;
    return LucideIcons.activity;
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildPermissionsTab(Color cardColor, Color borderColor, Color primaryPurple) {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: primaryPurple));
    if (_accountants.isEmpty) {
      return Center(
        child: Text("No accountants found", style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _accountants.length,
      itemBuilder: (context, index) {
        final accountant = _accountants[index];
        final name = "${accountant['first_name'] ?? 'Accountant'} ${accountant['last_name'] ?? ''}";
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryPurple.withOpacity(0.1),
                    child: Text(name[0], style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(accountant['email'] ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white38)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.messageSquare, color: Colors.white.withOpacity(0.4), size: 18),
                        onPressed: () => _showContactOptions(context, accountant, primaryPurple),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.activity, color: primaryPurple, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchQuery = name;
                            _searchController.text = name;
                          });
                          _tabController.animateTo(0);
                        },
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.settings2, color: Colors.white54, size: 20),
                        onPressed: () => _showPermissionEditor(context, accountant, primaryPurple),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusDot("Vouchers", true),
                  _buildStatusDot("Reports", index % 2 == 0),
                  _buildStatusDot("Ledgers", true),
                  _buildStatusDot("Delete", false),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusDot(String label, bool enabled) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFF10B981) : Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showPermissionEditor(BuildContext context, Map<String, dynamic> user, Color primaryPurple) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161625),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Manage Permissions",
                    style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Set access levels for ${user['first_name']}",
                    style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _buildPermissionToggle("Can Create Vouchers", true, setModalState, primaryPurple),
                  _buildPermissionToggle("Can View Reports", true, setModalState, primaryPurple),
                  _buildPermissionToggle("Can Export PDF", false, setModalState, primaryPurple),
                  _buildPermissionToggle("Can Delete Entries", false, setModalState, primaryPurple),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Update Access", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionToggle(String label, bool initialValue, StateSetter setModalState, Color primaryPurple) {
    bool current = initialValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14)),
          Switch(
            value: current,
            onChanged: (val) => setModalState(() => current = val),
            activeColor: primaryPurple,
          ),
        ],
      ),
    );
  }
  void _showContactOptions(BuildContext context, Map<String, dynamic> user, Color primaryPurple) {
    final name = "${user['first_name'] ?? 'Accountant'} ${user['last_name'] ?? ''}";
    final phone = user['phone']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161625),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0] : "?",
                    style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: primaryPurple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                user['role'] ?? 'Member',
                style: GoogleFonts.plusJakartaSans(color: Colors.white38),
              ),
              const SizedBox(height: 32),
              _buildContactButton(LucideIcons.phone, "Call Member", () async {
                Navigator.pop(context);
                if (phone.isNotEmpty) {
                  final Uri telLaunchUri = Uri(scheme: 'tel', path: phone);
                  if (await canLaunchUrl(telLaunchUri)) {
                    await launchUrl(telLaunchUri);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Could not launch phone dialer")),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No phone number registered for this user")),
                  );
                }
              }),
              const SizedBox(height: 12),
              _buildContactButton(LucideIcons.mail, "Send Email", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmailComposeScreen(userName: name, userEmail: email)),
                );
              }),
              const SizedBox(height: 12),
              _buildContactButton(LucideIcons.messageCircle, "Live Chat", () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen(userName: name)),
                );
              }),
            ],
          ),
        );
      },
    );
  }


  Widget _buildContactButton(IconData icon, String label, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white60, size: 20),
        title: Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
      ),
    );
  }
}
