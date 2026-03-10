import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

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

  Widget _buildMetricCard(
      String title,
      String value,
      String trend,
      bool isPositive,
      IconData icon,
      Color iconColor,
      Color cardColor,
      Color textColor,
      Color subtextColor,
      VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: subtextColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalItem(
      String title,
      String subtitle,
      String amount,
      String time,
      IconData icon,
      Color cardColor,
      Color textColor,
      Color subtextColor,
      VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blueGrey, size: 24),
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
                      fontSize: 14,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: subtextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: subtextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String percentage,
      Color textColor, Color subtextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    color: subtextColor, fontSize: 13)),
          ],
        ),
        Text(percentage,
            style: GoogleFonts.plusJakartaSans(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF1A1D23);
    Color subtextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    // Logic to pull real data
    final summary = dashboardData['summary'] ?? {};
    final double assets =
        double.tryParse(summary['assets']?.toString() ?? '0') ?? 0;
    final double liabilities =
        double.tryParse(summary['liabilities']?.toString() ?? '0') ?? 0;
    final double equity =
        double.tryParse(summary['equity']?.toString() ?? '0') ?? 0;

    // Filter pending vouchers
    final pendingVouchers = vouchers
        .where((v) => v['status']?.toString().toLowerCase() == 'pending')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  "TOTAL INCOME",
                  "₹${(totalIncome / 100000).toStringAsFixed(1)} L",
                  "+14%",
                  true,
                  LucideIcons.arrowUpRight,
                  Colors.green,
                  cardColor,
                  textColor,
                  subtextColor,
                  () => onNavigate('reports'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  "TOTAL EXPENSE",
                  "₹${(totalExpense / 100000).toStringAsFixed(1)} L",
                  "-8%",
                  false,
                  LucideIcons.arrowDownRight,
                  Colors.red,
                  cardColor,
                  textColor,
                  subtextColor,
                  () => onNavigate('reports'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Awaiting My Approval",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () => onNavigate('vouchers'),
                child: Text(
                  "VIEW ALL (${pendingVouchers.length})",
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFFC107),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pendingVouchers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(LucideIcons.checkCircle2,
                        color: Colors.green, size: 48),
                    const SizedBox(height: 12),
                    Text("Great! No pending approvals",
                        style:
                            GoogleFonts.plusJakartaSans(color: subtextColor)),
                  ],
                ),
              ),
            )
          else
            ...pendingVouchers.take(3).map((v) => _buildApprovalItem(
                v['narration'] ?? 'No Description',
                "Submitted by ${v['first_name'] ?? 'Staff'} ${v['last_name'] ?? ''}"
                    .trim(),
                "₹${double.tryParse(v['total_debit']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}",
                v['voucher_date']?.toString().split(' ')[0] ?? 'Just now',
                LucideIcons.fileText,
                cardColor,
                textColor,
                subtextColor,
                () => onNavigate('vouchers'))),
          const SizedBox(height: 24),
          Text(
            "Account Analytics",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 60,
                          startDegreeOffset: 270,
                          sections: [
                            PieChartSectionData(
                                color: const Color(0xFFFFC107),
                                value: assets > 0 ? assets : 1,
                                radius: 25,
                                showTitle: false),
                            PieChartSectionData(
                                color: const Color(0xFFFACC15),
                                value: liabilities > 0 ? liabilities : 0.1,
                                radius: 25,
                                showTitle: false),
                            PieChartSectionData(
                                color: const Color(0xFF2E2C23),
                                value: equity > 0 ? equity : 0.1,
                                radius: 25,
                                showTitle: false),
                          ],
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "TOTAL ASSETS",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: subtextColor,
                              ),
                            ),
                            Text(
                              "₹${(assets / 100000).toStringAsFixed(1)}L",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildLegendItem(const Color(0xFFFFC107), "Assets",
                              "Active", textColor, subtextColor),
                          const SizedBox(height: 12),
                          _buildLegendItem(const Color(0xFFFACC15),
                              "Liabilities", "Owed", textColor, subtextColor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildLegendItem(const Color(0xFF2E2C23), "Equity",
                              "Capital", textColor, subtextColor),
                          const SizedBox(height: 12),
                          _buildLegendItem(Colors.greenAccent, "Net Cash",
                              "Pos.", textColor, subtextColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
