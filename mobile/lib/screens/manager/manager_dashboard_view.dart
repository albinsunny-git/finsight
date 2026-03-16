import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:finsight_mobile/screens/voucher_detail_screen.dart';
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
  final String userRole;
  final String currentUserId;

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
    required this.userRole,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Premium Amethyst Palette
    const Color bgColor = Color(0xFF0D0D17);
    const Color cardColor = Color(0xFF161625);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color accentPurple = Color(0xFFA855F7);
    const Color borderColor = Color(0xFF1F1F35);

    // Calculate Pending Approvals
    final int pendingApprovals = vouchers.where((v) => v['status'].toString().toLowerCase() == 'pending').length;

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
                      dashboardData['summary'] != null ? "+12.5%" : "0.0%", // Placeholder trend
                      LucideIcons.banknote,
                      primaryPurple,
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      "Pending Approvals",
                      pendingApprovals.toString(),
                      "Requires Action",
                      LucideIcons.clock,
                      const Color(0xFFF59E0B),
                      pendingApprovals > 0,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Overview Card with Bar Chart
              _buildOverviewCard(cardColor, borderColor, primaryPurple, accentPurple),
              
              const SizedBox(height: 32),
              
              // Recent Team Activity Section
              _buildRecentActivity(context, cardColor, borderColor, primaryPurple),
              
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
        GestureDetector(
          onTap: () => onNavigate('notifications'),
          child: Container(
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
    List<double> incomeData = [10, 14, 18, 8, 13, 6, 4];
    List<double> expenseData = [8, 10, 12, 6, 11, 4, 3];
    List<String> labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    if (dashboardData['analytics'] != null && dashboardData['analytics']['cash_flow'] != null) {
      final cashFlow = dashboardData['analytics']['cash_flow'];
      incomeData = List<double>.from(cashFlow['income'].map((i) => (i as num).toDouble()));
      expenseData = List<double>.from(cashFlow['expense'].map((i) => (i as num).toDouble()));
      final labelsRaw = List<String>.from(cashFlow['labels']);
      
      if (incomeData.isNotEmpty) {
        labels = labelsRaw.map((l) => l.split(' ')[0]).toList();
      }
    }

    double maxVal = 10;
    if (incomeData.isNotEmpty) maxVal = incomeData.reduce((a, b) => a > b ? a : b);
    if (expenseData.isNotEmpty) {
      double maxExp = expenseData.reduce((a, b) => a > b ? a : b);
      if (maxExp > maxVal) maxVal = maxExp;
    }
    if (maxVal == 0) maxVal = 10;

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
                    "Cash Flow Trends",
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
                "₹${_formatCurrency(totalIncome)}",
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
                  "YTD Income",
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
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1F1F35),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        "₹${_formatCurrency(rod.toY)}",
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
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
                barGroups: incomeData.asMap().entries.map((e) {
                  return _buildDualBarGroup(e.key, e.value, expenseData[e.key], accentPurple, const Color(0xFFF43F5E), isHighlighted: e.key == incomeData.length - 1);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildDualBarGroup(int x, double y1, double y2, Color c1, Color c2, {bool isHighlighted = false}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: isHighlighted ? c1 : c1.withOpacity(0.3),
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: y2,
          color: isHighlighted ? c2 : c2.withOpacity(0.3),
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, Color cardColor, Color borderColor, Color primaryPurple) {
    // Get real activity from vouchers
    final recentVouchers = vouchers.take(5).toList();

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
            InkWell(
              onTap: () => onNavigate('vouchers'),
              child: Text(
                "See all",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (recentVouchers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text("No recent activity", style: TextStyle(color: Colors.white.withOpacity(0.3))),
            ),
          )
        else
          ...recentVouchers.map((v) {
            String status = v['status']?.toString().toLowerCase() ?? 'pending';
            IconData icon = LucideIcons.clock;
            Color iconColor = const Color(0xFFF59E0B);
            
            if (status == 'posted' || status == 'approved') {
              icon = LucideIcons.checkCircle2;
              iconColor = const Color(0xFF10B981);
            } else if (status == 'rejected') {
              icon = LucideIcons.xCircle;
              iconColor = const Color(0xFFF43F5E);
            }

            return _buildActivityItem(
              context,
              v,
              "${v['first_name'] ?? 'User'} added ${v['voucher_type_name'] ?? 'Voucher'}",
              "₹${_formatCurrency(double.tryParse(v['total_debit']?.toString() ?? '0') ?? 0)} • ${v['voucher_date'] ?? 'Recent'}",
              icon,
              iconColor.withOpacity(0.12),
              iconColor,
            );
          }),
      ],
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> voucher, String title, String subtitle, IconData icon, Color bg, Color iconColor) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoucherDetailScreen(
              voucher: voucher,
              userRole: userRole,
              currentUserId: currentUserId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
