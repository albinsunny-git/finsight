import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/screens/add_user_screen.dart';
import 'package:finsight_mobile/services/api_service.dart';

class UserManagementScreen extends StatefulWidget {
  final List<dynamic> users;
  final VoidCallback onRefresh;
  final String currentUserId;

  const UserManagementScreen({
    super.key,
    required this.users,
    required this.onRefresh,
    required this.currentUserId,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredUsers = widget.users.where((u) {
      final name = "${u['first_name']} ${u['last_name']}".toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) ||
          email.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('User Management',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1D23))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.userPlus,
                color: isDark ? Colors.white : const Color(0xFF1A1D23)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddUserScreen()),
              );
              if (result == true) widget.onRefresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),
            Text(
              "Manage your team and permissions",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(LucideIcons.search,
                    size: 20, color: Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFFF6B00)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (filteredUsers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text("No users found",
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
                ),
              )
            else
              ...filteredUsers
                  .map((user) => _buildUserListItem(user, isDark))
                  .toList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user, bool isDark) {
    final name = "${user['first_name']} ${user['last_name']}".trim();
    final role = (user['role'] ?? 'User').toString();
    final isActive = user['is_active'] == 1 ||
        user['is_active'] == true ||
        user['is_active'] == '1';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE6D2),
              shape: BoxShape.circle,
              image: user['profile_image'] != null &&
                      user['profile_image'].toString().isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(user['profile_image']
                              .toString()
                              .startsWith('http')
                          ? user['profile_image']
                          : "${ApiService.baseUrl.replaceAll('/api', '')}/${user['profile_image']}"),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user['profile_image'] == null ||
                    user['profile_image'].toString().isEmpty
                ? Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFFF6B00),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1D23),
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (val) {
              // Implementation for toggle would go here
            },
            activeThumbColor: const Color(0xFFFF6B00),
          ),
          IconButton(
            icon: const Icon(LucideIcons.edit2, size: 18, color: Colors.grey),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddUserScreen(user: user)),
              );
              if (result == true) widget.onRefresh();
            },
          ),
        ],
      ),
    );
  }
}
