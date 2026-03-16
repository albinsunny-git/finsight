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
  String _selectedFilter = "All Members";

  @override
  Widget build(BuildContext context) {
    // Amethyst Theme Colors
    const Color bgColor = Color(0xFF0D0D17);
    const Color cardColor = Color(0xFF161625);
    const Color accentPurple = Color(0xFFA855F7);
    const Color borderColor = Color(0xFF1F1F35);

    // Filter logic
    List<dynamic> filteredUsers = widget.users.where((user) {
      final String name = "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".toLowerCase();
      final String role = (user['role'] ?? '').toLowerCase();
      final bool matchesSearch = name.contains(_searchQuery.toLowerCase()) || role.contains(_searchQuery.toLowerCase());
      
      if (_selectedFilter == "All Members") return matchesSearch;
      if (_selectedFilter == "Accountant") return matchesSearch && role.contains('accountant');
      if (_selectedFilter == "Staff") return matchesSearch && (role.contains('staff') || role.contains('accountant') == false && role.contains('admin') == false);
      if (_selectedFilter == "Active") return matchesSearch && (user['is_active'] == 1 || user['is_active'] == true);
      
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    _buildSearchBar(cardColor, borderColor),
                    const SizedBox(height: 20),
                    
                    // Filter Chips
                    _buildFilterChips(accentPurple, cardColor, borderColor),
                    const SizedBox(height: 30),
                    
                    // Stats section
                    _buildStatsRow(widget.users),
                    const SizedBox(height: 32),
                    
                    Text(
                      "MEMBERS",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Member List
                    if (filteredUsers.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Text(
                            "No members found",
                            style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...filteredUsers.map((user) => _buildMemberCard(user, cardColor, borderColor, accentPurple)),
                    
                    const SizedBox(height: 24),
                    
                    // Add Button
                    _buildAddButton(accentPurple),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => widget.onNavigate('dashboard'),
          ),
          const SizedBox(width: 8),
          Text(
            "Team Hub",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.bell, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA855F7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(LucideIcons.moreVertical, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color cardColor, Color borderColor) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(LucideIcons.search, color: Colors.white.withOpacity(0.4), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search team members...",
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(Color accentPurple, Color cardColor, Color borderColor) {
    final filters = ["All Members", "Accountant", "Staff", "Active"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentPurple : cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? accentPurple : borderColor),
                ),
                child: Text(
                  f,
                  style: GoogleFonts.plusJakartaSans(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsRow(List<dynamic> allUsers) {
    final totalMembers = allUsers.length;
    final activeNow = allUsers.where((u) => u['is_active'] == 1 || u['is_active'] == true).length;

    return Row(
      children: [
        Expanded(child: _buildStatItem("TOTAL MEMBERS", totalMembers.toString(), const Color(0xFF161625))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem("ACTIVE NOW", activeNow.toString(), const Color(0xFF161625), accentColor: const Color(0xFF10B981))),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color bgColor, {Color? accentColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: accentColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> user, Color cardColor, Color borderColor, Color accentPurple) {
    final String name = "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}";
    final String role = user['role'] ?? 'Staff';
    final bool isActive = user['is_active'] == 1 || user['is_active'] == true;

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
          // Avatar with status
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: accentPurple.withOpacity(0.2),
                backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=${name.hashCode}"),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF10B981) : Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: cardColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.briefcase, size: 12, color: Colors.white.withOpacity(0.4)),
                    const SizedBox(width: 6),
                    Text(
                      role,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          IconButton(
            icon: Icon(LucideIcons.messageSquare, color: accentPurple, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.clipboardSignature, color: Colors.white.withOpacity(0.4), size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(Color accentPurple) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: accentPurple,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.userPlus, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                "Add New Team Member",
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
