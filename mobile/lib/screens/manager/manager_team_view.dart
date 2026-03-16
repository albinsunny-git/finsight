import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManagerTeamView extends StatelessWidget {
  final List<dynamic> users;
  final bool isDark;
  final Function(String) onNavigate;

  const ManagerTeamView({
    super.key,
    required this.users,
    required this.isDark,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF0D0D17);
    final Color primaryPurple = const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => onNavigate('dashboard'),
        ),
        title: Text(
          "Team Hub",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.userPlus, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildManagementCard(primaryPurple),
            const SizedBox(height: 32),
            Text(
              "Active Members",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...users.map((user) => _buildTeamMemberItem(user, primaryPurple)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(Color primaryPurple) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manage Your Team",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Track performance, approve leaves, and manage roles.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStat("24", "Total Tasks"),
              const SizedBox(width: 24),
              _buildSimpleStat("92%", "Efficiency"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMemberItem(Map<String, dynamic> user, Color primaryPurple) {
    final String name = "${user['first_name'] ?? 'Team'} ${user['last_name'] ?? 'Member'}";
    final String role = user['role'] ?? 'Staff';
    final bool isActive = user['is_active'] == 1 || user['is_active'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161625),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$name"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  role,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF10B981).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? "ONLINE" : "OFFLINE",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF10B981) : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
