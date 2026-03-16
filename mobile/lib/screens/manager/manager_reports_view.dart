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
    const Color bgColor = Color(0xFF0D0D17);
    const Color cardColor = Color(0xFF161625);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color accentPurple = Color(0xFFA855F7);
    const Color borderColor = Color(0xFF1F1F35);

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
          "Executive Reports",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.share2, color: Colors.white, size: 20), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(primaryPurple, accentPurple),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => widget.onRefresh(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickInsight(cardColor, borderColor, primaryPurple, accentPurple),
                    const SizedBox(height: 32),
                    Text(
                      "Critical Business Reports",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildReportItem(
                      "Monthly Performance",
                      "Revenue streams, operational expenses, and monthly target KPIs for all departments.",
                      LucideIcons.trendingUp,
                      "Generate Report",
                      primaryPurple,
                      cardColor,
                      borderColor
                    ),
                    _buildReportItem(
                      "Tax Compliance",
                      "Projected tax liabilities and compliance checks based on current quarterly earnings.",
                      LucideIcons.shieldCheck,
                      "Review Status",
                      const Color(0xFF1F1F35),
                      cardColor,
                      borderColor
                    ),
                    _buildReportItem(
                      "Audit Readiness",
                      "Financial documentation and compliance certificates status for annual audit.",
                      LucideIcons.fileCheck,
                      "Check Readiness",
                      const Color(0xFF1F1F35),
                      cardColor,
                      borderColor,
                      trailingTag: "2 Actions",
                      tagColor: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primaryPurple, Color accentPurple) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF161625),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem("Overview", 0, primaryPurple, accentPurple)),
          Expanded(child: _buildTabItem("Tax Filing", 1, primaryPurple, accentPurple)),
          Expanded(child: _buildTabItem("Audit Logs", 2, primaryPurple, accentPurple)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, Color primaryPurple, Color accentPurple) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInsight(Color cardColor, Color borderColor, Color primaryPurple, Color accentPurple) {
    return Container(
      padding: const EdgeInsets.all(28),
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
              Text(
                "Profit Analytics",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.trendingUp, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "22.5%",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "₹1,24,500",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Estimated Net Profit (QTD)",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.35),
              fontWeight: FontWeight.w600,
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
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            months[value.toInt()],
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withOpacity(0.25),
                              fontSize: 10,
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
                  _buildBarGroup(0, 8, primaryPurple),
                  _buildBarGroup(1, 12, primaryPurple),
                  _buildBarGroup(2, 11, primaryPurple),
                  _buildBarGroup(3, 14, primaryPurple),
                  _buildBarGroup(4, 17, primaryPurple),
                  _buildBarGroup(5, 19, accentPurple, isHighlighted: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color, {bool isHighlighted = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: isHighlighted ? color : color.withOpacity(0.2),
          width: 32,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildReportItem(String title, String subtitle, IconData icon, String btnText, Color btnColor, Color cardColor, Color borderColor, {String? trailingTag, Color? tagColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: const Color(0xFF8B5CF6), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.4),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    btnText,
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              if (trailingTag != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: tagColor!.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.alertCircle, color: tagColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        trailingTag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
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
