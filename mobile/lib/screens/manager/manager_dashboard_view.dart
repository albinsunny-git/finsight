import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'dart:io';

class ManagerDashboardView extends StatelessWidget {
  final Map<String, dynamic> dashboardData;
  final List<dynamic> vouchers;
  final bool isDark;
  final Map<String, dynamic> userData;
  final int unreadNotificationsCount;
  final double totalIncome;
  final double totalExpense;
  final Function(String) onNavigate;

  const ManagerDashboardView({
    super.key,
    required this.dashboardData,
    required this.vouchers,
    required this.isDark,
    required this.userData,
    required this.unreadNotificationsCount,
    required this.totalIncome,
    required this.totalExpense,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    // Colors from Amethyst Theme logic
    final Color bgColor = const Color(0xFF0D0D17);
    final Color cardColor = const Color(0xFF161625);
    final Color primaryPurple = const Color(0xFF8B5CF6);
    final Color accentPurple = const Color(0xFFD8B4FE);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, primaryPurple),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      "Total Revenue",
                      "\$${(totalIncome / 1).toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                      "+12.5%",
                      LucideIcons.banknote,
                      const Color(0xFF8B5CF6).withOpacity(0.15),
                      const Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      "Pending Approvals",
                      "14",
                      "Requires Action",
                      LucideIcons.clipboardCheck,
                      const Color(0xFFF59E0B).withOpacity(0.15),
                      const Color(0xFFF59E0B),
                      isWarning: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildOverviewCard(cardColor, primaryPurple, accentPurple),
              const SizedBox(height: 24),
              _buildRecentActivity(cardColor),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryPurple) {
    final String name = userData['first_name'] ?? 'Alex Sterling';
    final profileImage = userData['profileImage'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: primaryPurple.withOpacity(0.2),
              backgroundImage: profileImage != null && profileImage.isNotEmpty
                  ? (profileImage.startsWith('http') ||
                          profileImage.startsWith('uploads/'))
                      ? NetworkImage(profileImage.startsWith('http')
                          ? profileImage
                          : "${ApiService.baseUrl.replaceAll('/api', '')}/$profileImage") as ImageProvider
                      : FileImage(File(profileImage))
                  : null,
              child: profileImage == null || profileImage.isEmpty
                  ? Icon(LucideIcons.user, color: primaryPurple, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E30),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bell, color: Colors.white, size: 24),
            ),
            if (unreadNotificationsCount > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF43F5E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String trend,
      IconData icon, Color iconBg, Color iconColor,
      {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161625),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!isWarning)
                Icon(LucideIcons.trendingUp, color: const Color(0xFF10B981), size: 14),
              if (isWarning)
                const Text("!", style: TextStyle(color: Color(0xFFF43F5E), fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isWarning ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(Color cardColor, Color primaryPurple, Color accentPurple) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Manager's Overview",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Weekly Performance Stats",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              Text(
                "View Details",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "\$42,000",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Target: \$50k",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt()],
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 10),
                  _buildBarGroup(1, 14),
                  _buildBarGroup(2, 18, isHighlighted: true),
                  _buildBarGroup(3, 8),
                  _buildBarGroup(4, 13),
                  _buildBarGroup(5, 6),
                  _buildBarGroup(6, 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, {bool isHighlighted = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isHighlighted ? const Color(0xFF8B5CF6) : const Color(0xFF1F1F35),
          width: 30,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Team Activity",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "See all",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          "Sarah completed 'Project Amethyst'",
          "2 hours ago • Development Team",
          LucideIcons.checkCircle2,
          const Color(0xFF10B981).withOpacity(0.1),
          const Color(0xFF10B981),
        ),
        _buildActivityItem(
          "James requested leave",
          "5 hours ago • Sales Team",
          LucideIcons.alertTriangle,
          const Color(0xFFF59E0B).withOpacity(0.1),
          const Color(0xFFF59E0B),
        ),
        _buildActivityItem(
          "New team member joined",
          "Yesterday • Marketing Team",
          LucideIcons.userPlus,
          const Color(0xFF8B5CF6).withOpacity(0.1),
          const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color bg, Color iconColor) {
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
