import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManagerTeamView extends StatefulWidget {
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
  State<ManagerTeamView> createState() => _ManagerTeamViewState();
}

class _ManagerTeamViewState extends State<ManagerTeamView> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0D0D17);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color cardColor = Color(0xFF161625);
    const Color borderColor = Color(0xFF1F1F35);

    final filteredUsers = widget.users.where((user) {
      final name = "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    final activeCount = widget.users.where((u) => u['is_active'] == 1 || u['is_active'] == true).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => widget.onNavigate('dashboard'),
        ),
        title: Text(
          "Team Hub",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.userPlus, color: Colors.white, size: 22), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(primaryPurple, cardColor, borderColor),
          const SizedBox(height: 8),
          _buildStatsRow(activeCount, widget.users.length, primaryPurple, cardColor, borderColor),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildMemberCard(filteredUsers[index], primaryPurple, cardColor, borderColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(Color primaryPurple, Color cardColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 54,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  icon: Icon(LucideIcons.search, color: Colors.white.withOpacity(0.3), size: 20),
                  border: InputBorder.none,
                  hintText: "Search team member...",
                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.2), fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryPurple.withOpacity(0.3)),
            ),
            child: Icon(LucideIcons.slidersHorizontal, color: primaryPurple, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int active, int total, Color primaryPurple, Color cardColor, Color borderColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatChip("Active", active.toString(), const Color(0xFF10B981), cardColor, borderColor),
          const SizedBox(width: 12),
          _buildStatChip("Total", total.toString(), primaryPurple, cardColor, borderColor),
          const SizedBox(width: 12),
          _buildStatChip("Offline", (total - active).toString(), Colors.grey, cardColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color, Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> user, Color primaryPurple, Color cardColor, Color borderColor) {
    final name = "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}";
    final role = user['role'] ?? "Accountant";
    final isActive = user['is_active'] == 1 || user['is_active'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: primaryPurple.withOpacity(0.1),
                child: Text(name.isNotEmpty ? name[0] : "?", style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF10B981) : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 2),
                  ),
                ),
              ),
            ],
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
                    color: Colors.white.withOpacity(0.35),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildSimpleIconButton(LucideIcons.messageSquare, Colors.white.withOpacity(0.2)),
              const SizedBox(width: 8),
              _buildSimpleIconButton(LucideIcons.clipboardList, primaryPurple.withOpacity(0.15), iconColor: primaryPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleIconButton(IconData icon, Color bg, {Color iconColor = Colors.white54}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }
}
