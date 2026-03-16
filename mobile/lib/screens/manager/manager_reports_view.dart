import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

class ManagerReportsView extends StatefulWidget {
  final Map<String, dynamic> dashboardData;
  final bool isDark;
  final Function(String) onNavigate;
  final VoidCallback onRefresh;

  const ManagerReportsView({
    super.key,
    required this.dashboardData,
    required this.isDark,
    required this.onNavigate,
    required this.onRefresh,
  });

  @override
  State<ManagerReportsView> createState() => _ManagerReportsViewState();
}

class _ManagerReportsViewState extends State<ManagerReportsView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF0D0D17);
    final Color cardColor = const Color(0xFF161625);
    final Color primaryPurple = const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Executive Summaries",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell, color: Colors.white), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=manager"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(primaryPurple),
          const Divider(color: Color(0xFF1F1F35), height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickInsight(cardColor, primaryPurple),
                  const SizedBox(height: 32),
                  Text(
                    "Key Reports",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReportItem(
                    "Monthly Performance",
                    "Detailed breakdown of revenue streams, operational expenses, and monthly target KPIs for all departments.",
                    LucideIcons.calendar,
                    "View Report",
                    primaryPurple,
                  ),
                  _buildReportItem(
                    "Quarterly Tax Estimates",
                    "Projected tax liabilities based on current quarterly earnings. Includes deductions and localized tax compliance checks.",
                    LucideIcons.wallet,
                    "Review Estimates",
                    const Color(0xFF1F1F35),
                  ),
                  _buildReportItem(
                    "Audit Readiness",
                    "Status update on financial documentation and compliance certificates required for the upcoming annual audit.",
                    LucideIcons.clipboardCheck,
                    "Audit Checklist",
                    const Color(0xFF1F1F35),
                    trailingTag: "2 Pending",
                    tagColor: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primaryPurple) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem("Overview", 0, primaryPurple),
          _buildTabItem("Tax Filing", 1, primaryPurple),
          _buildTabItem("Audit Logs", 2, primaryPurple),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, Color primaryPurple) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primaryPurple : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInsight(Color cardColor, Color primaryPurple) {
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
                    "Quick Insight",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NET PROFIT TREND",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "+\$124,500.00",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFA855F7),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.trendingUp, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "12%",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "vs last quarter",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
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
                        const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'];
                        if (value.toInt() >= months.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            months[value.toInt()],
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey[500],
                              fontSize: 10,
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
                  _buildBarGroup(0, 8),
                  _buildBarGroup(1, 12),
                  _buildBarGroup(2, 11),
                  _buildBarGroup(3, 14),
                  _buildBarGroup(4, 17),
                  _buildBarGroup(5, 19, isHighlighted: true),
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
          color: isHighlighted ? const Color(0xFF8B5CF6) : const Color(0xFF581C87),
          width: 35,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildReportItem(String title, String subtitle, IconData icon, String btnText, Color btnColor, {String? trailingTag, Color? tagColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161625),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFF8B5CF6).withOpacity(0.5), size: 48),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    btnText,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (trailingTag != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: tagColor!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertTriangle, color: tagColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        trailingTag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
