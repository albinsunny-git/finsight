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
    // Premium Amethyst Palette
    const Color bgColor = Color(0xFF0D0D17);
    const Color cardColor = Color(0xFF161625);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color accentPurple = Color(0xFFA855F7);
    const Color borderColor = Color(0xFF1F1F35);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, primaryPurple),
              const SizedBox(height: 32),
              
              // Top Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      "Total Revenue",
                      "₹${_formatCurrency(totalIncome)}",
                      "+12.5%",
                      LucideIcons.banknote,
                      primaryPurple,
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      "Pending Approvals",
                      "14",
                      "Requires Action",
                      LucideIcons.clock,
                      const Color(0xFFF59E0B),
                      true,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Overview Card with Bar Chart
              _buildOverviewCard(cardColor, borderColor, primaryPurple, accentPurple),
              
              const SizedBox(height: 32),
              
              // Recent Team Activity Section
              _buildRecentActivity(cardColor, borderColor, primaryPurple),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amt) {
    if (amt >= 100000) {
      return "${(amt / 100000).toStringAsFixed(1)} L";
    } else if (amt >= 1000) {
      return "${(amt / 1000).toStringAsFixed(1)} k";
    }
    return amt.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget _buildHeader(BuildContext context, Color primaryPurple) {
    final String name = userData['first_name'] ?? 'Alex Sterling';
    final profileImage = userData['profileImage'];

    return Row(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryPurple.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: primaryPurple.withOpacity(0.1),
                backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                    ? (profileImage.startsWith('http') || profileImage.startsWith('uploads/'))
                        ? NetworkImage(profileImage.startsWith('http')
                            ? profileImage
                            : "${ApiService.baseUrl.replaceAll('/api', '')}/$profileImage") as ImageProvider
                        : FileImage(File(profileImage))
                    : null,
                child: (profileImage == null || profileImage.isEmpty)
                    ? Icon(LucideIcons.user, color: primaryPurple, size: 28)
                    : null,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle),
                child: const Icon(LucideIcons.check, color: Colors.white, size: 10),
              ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back,",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: primaryPurple,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E30),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2E2E45)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(LucideIcons.bell, color: Colors.white, size: 22),
              if (unreadNotificationsCount > 0)
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
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, String trend, IconData icon, Color color, bool isWarning) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161625),
        borderRadius: BorderRadius.circular(28),
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
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.4),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isWarning)
                const Icon(LucideIcons.alertCircle, color: Color(0xFFF43F5E), size: 14)
              else
                const Icon(LucideIcons.trendingUp, color: Color(0xFF10B981), size: 14),
              const SizedBox(width: 6),
              Text(
                trend,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isWarning ? const Color(0xFFF43F5E) : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(Color cardColor, Color borderColor, Color primaryPurple, Color accentPurple) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
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
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Weekly Performance Stats",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => onNavigate('reports'),
                child: Text(
                  "View Details",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accentPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₹42,000",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Target: ₹50k",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.3),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
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
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            days[value.toInt()],
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
                  _buildBarGroup(0, 10, accentPurple),
                  _buildBarGroup(1, 14, accentPurple),
                  _buildBarGroup(2, 18, accentPurple, isHighlighted: true),
                  _buildBarGroup(3, 8, accentPurple),
                  _buildBarGroup(4, 13, accentPurple),
                  _buildBarGroup(5, 6, accentPurple),
                  _buildBarGroup(6, 4, accentPurple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color accentPurple, {bool isHighlighted = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isHighlighted ? accentPurple : const Color(0xFF1F1F35),
          width: 28,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(Color cardColor, Color borderColor, Color primaryPurple) {
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
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              "See all",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primaryPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildActivityItem(
          "Sarah completed 'Project Amethyst'",
          "2 hours ago • Development Team",
          LucideIcons.checkCircle2,
          const Color(0xFF10B981).withOpacity(0.12),
          const Color(0xFF10B981),
        ),
        _buildActivityItem(
          "James requested leave",
          "5 hours ago • Sales Team",
          LucideIcons.alertTriangle,
          const Color(0xFFF59E0B).withOpacity(0.12),
          const Color(0xFFF59E0B),
        ),
        _buildActivityItem(
          "New team member joined",
          "Yesterday • Marketing Team",
          LucideIcons.userPlus,
          const Color(0xFF8B5CF6).withOpacity(0.12),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.35),
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
}
