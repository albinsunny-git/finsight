import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/screens/reports/profit_loss_screen.dart';
import 'package:finsight_mobile/screens/reports/analytics_screen.dart';
import 'package:finsight_mobile/screens/reports/trial_balance_screen.dart';

class ManagerReportsView extends StatelessWidget {
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

  Widget _buildReportCard(
      BuildContext context, String title, String subtitle, IconData icon) {
    Color cardColor =
        isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1A1D23);
    Color subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return GestureDetector(
      onTap: () {
        Widget screen;
        if (title.contains("Budget")) {
          screen = const ProfitLossScreen();
        } else if (title.contains("Team")) {
          screen = const ProfitLossScreen();
        } else if (title.contains("Revenue")) {
          screen = const AnalyticsScreen();
        } else {
          screen = const TrialBalanceScreen();
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => screen),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B2F11), // Dark yellow tint
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFFC107), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: subtextColor, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = isDark ? const Color(0xFF191813) : const Color(0xFFF5F5F5);
    Color textColor = isDark ? Colors.white : const Color(0xFF1A1D23);

    // Let's make the summary card follow theme too for consistency unless it's a specific design choice.
    // Actually, following theme is safer.
    Color summaryCardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final summary = dashboardData['summary'] ?? {};
    final double assets =
        double.tryParse(summary['assets']?.toString() ?? '0') ?? 0;
    final double liabilities =
        double.tryParse(summary['liabilities']?.toString() ?? '0') ?? 0;
    final double netWorth = (assets - liabilities) / 100000; // in Lakhs

    // Calculate current quarter
    final month = DateTime.now().month;
    final quarter = ((month - 1) ~/ 3) + 1;

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Financial Overviews",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "High-level managerial insights and data.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                _buildReportCard(
                    context,
                    "Budget vs Actual",
                    "Monthly performance vs\nprojected budget",
                    LucideIcons.pieChart),
                _buildReportCard(
                    context,
                    "Team Expense Summaries",
                    "Aggregate spending across all\ndepartments",
                    LucideIcons.users),
                _buildReportCard(context, "Revenue Projections",
                    "Quarterly forecasting and trends", LucideIcons.trendingUp),
                _buildReportCard(
                    context,
                    "Departmental Audits",
                    "Deep dive into specific unit\ncompliance",
                    LucideIcons.wallet),
                const SizedBox(height: 32),
                Text(
                  "Recent Summaries",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: summaryCardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark
                            ? Colors.blueGrey.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 160,
                        decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                          color: Colors.white,
                          image: DecorationImage(
                            image: NetworkImage(
                                "https://images.unsplash.com/photo-1551288049-bebda4e38f71?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Q$quarter REVIEW",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFFFC107),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  "Live Data",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Net Worth: ₹${netWorth.toStringAsFixed(1)}L",
                              style: GoogleFonts.plusJakartaSans(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Assets generated so far this quarter.",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
