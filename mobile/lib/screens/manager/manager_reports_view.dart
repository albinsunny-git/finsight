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
                      borderColor,
                      onTap: () => widget.onNavigate('reports'), // Logic to open specific report
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
                      trailingTag: "Actions Req.",
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
    // Extract real chart data (Profit Trend)
    List<double> profitData = [8, 12, 11, 14, 17, 19];
    List<String> labels = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'];
    double totalProfit = 124500;
    String trend = "+22.5%";

    if (widget.dashboardData['analytics'] != null && widget.dashboardData['analytics']['cash_flow'] != null) {
      final cashFlow = widget.dashboardData['analytics']['cash_flow'];
      final income = List<double>.from(cashFlow['income'].map((i) => (i as num).toDouble()));
      final expense = List<double>.from(cashFlow['expense'].map((i) => (i as num).toDouble()));
      final labelsRaw = List<String>.from(cashFlow['labels']);
      
      if (income.length == expense.length && income.isNotEmpty) {
        profitData = [];
        for (int i = 0; i < income.length; i++) {
          profitData.add(income[i] - expense[i]);
        }
        labels = labelsRaw.map((l) => l.split(' ')[0].toUpperCase()).toList();
        totalProfit = profitData.reduce((a, b) => a + b);
        
        if (profitData.length >= 2) {
          double last = profitData.last;
          double prev = profitData[profitData.length - 2];
          double change = prev == 0 ? 0 : ((last - prev) / prev.abs()) * 100;
          trend = "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%";
        }
      }
    }

    double maxVal = profitData.map((e) => e.abs()).reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 10;

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
                  color: (trend.startsWith('+') ? const Color(0xFF10B981) : Colors.redAccent).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(trend.startsWith('+') ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: trend.startsWith('+') ? const Color(0xFF10B981) : Colors.redAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: trend.startsWith('+') ? const Color(0xFF10B981) : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "₹${(totalProfit / 1000).toStringAsFixed(1)}k",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Net Profit (Current Period)",
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
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            labels[index],
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
                barGroups: profitData.asMap().entries.map((e) {
                  return _buildBarGroup(e.key, e.value, primaryPurple, isHighlighted: e.key == profitData.length - 1);
                }).toList(),
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

  Widget _buildReportItem(String title, String subtitle, IconData icon, String btnText, Color btnColor, Color cardColor, Color borderColor, {String? trailingTag, Color? tagColor, VoidCallback? onTap}) {
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
                  onPressed: onTap ?? () {},
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
