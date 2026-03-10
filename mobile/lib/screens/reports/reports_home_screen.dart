import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/screens/reports/balance_sheet_screen.dart';
import 'package:finsight_mobile/screens/reports/profit_loss_screen.dart';
import 'package:finsight_mobile/screens/reports/trial_balance_screen.dart';
import 'package:finsight_mobile/screens/reports/ledger_screen.dart';
import 'package:finsight_mobile/screens/reports/analytics_screen.dart';
import 'package:finsight_mobile/screens/reports/cash_flow_screen.dart';

class ReportsHomeScreen extends StatefulWidget {
  const ReportsHomeScreen({super.key});

  @override
  State<ReportsHomeScreen> createState() => _ReportsHomeScreenState();
}

class _ReportsHomeScreenState extends State<ReportsHomeScreen> {
  final String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> allReports = [
      {
        'title': 'Profit & Loss',
        'subtitle': 'Comprehensive summary of revenue, costs, and expenses.',
        'icon': LucideIcons.trendingUp,
        'color': const Color(0xFFFF6B00),
        'route': (context) => const ProfitLossScreen(),
      },
      {
        'title': 'Balance Sheet',
        'subtitle': 'Snapshot of your assets, liabilities, and equity.',
        'icon': LucideIcons.landmark,
        'color': const Color(0xFFFF6B00),
        'route': (context) => const BalanceSheetScreen(),
      },
      {
        'title': 'Cash Flow',
        'subtitle': 'Detailed tracking of cash inflows and outflows.',
        'icon': LucideIcons.banknote,
        'color': const Color(0xFFFF6B00),
        'route': (context) => const CashFlowScreen(),
      },
      {
        'title': 'Trial Balance',
        'subtitle': 'Summary of all account balances in the ledger.',
        'icon': LucideIcons.scale,
        'color': const Color(0xFFFF6B00),
        'route': (context) => const TrialBalanceScreen(),
      },
      {
        'title': 'General Ledger',
        'subtitle': 'Complete record of all financial transactions.',
        'icon': LucideIcons.bookOpen,
        'color': const Color(0xFFFF6B00),
        'route': (context) => const LedgerScreen(),
      },
      {
        'title': 'Analytics',
        'subtitle': 'Visual data representation and trends.',
        'icon': LucideIcons.pieChart,
        'color': const Color(0xFFFF6B00),
        'route': (context) => const AnalyticsScreen(),
      },
    ];

    final filteredReports = allReports.where((r) {
      return r['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r['subtitle'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft,
              color: isDark ? Colors.white : const Color(0xFF1A1D23)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Reports",
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1D23))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(LucideIcons.search,
                color: isDark ? Colors.white : const Color(0xFF1A1D23)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Financial Statements",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1D23),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "ADMIN ACCESS",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF6B00),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...filteredReports
                .map((report) => _buildMockupReportCard(theme, isDark, report))
                .toList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMockupReportCard(
      ThemeData theme, bool isDark, Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2E6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(report['icon'],
                    color: const Color(0xFFFF6B00), size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            report['title'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1D23),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report['subtitle'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download,
                    size: 18, color: Color(0xFFFF6B00)),
                label: Text(
                  "Download",
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFF6B00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: report['route']));
                },
                child: Text(
                  "View Details",
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFF6B00),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
