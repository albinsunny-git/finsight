import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finsight_mobile/screens/reports/ledger_screen.dart';
import 'package:finsight_mobile/screens/reports/cash_flow_screen.dart';
import 'package:finsight_mobile/screens/reports/monthly_performance_screen.dart';
import 'package:finsight_mobile/screens/reports/balance_sheet_screen.dart';
import 'package:finsight_mobile/screens/reports/profit_loss_screen.dart';
import 'package:finsight_mobile/config.dart';

class ReportsHomeScreen extends StatefulWidget {
  const ReportsHomeScreen({super.key});

  @override
  State<ReportsHomeScreen> createState() => _ReportsHomeScreenState();
}

class _ReportsHomeScreenState extends State<ReportsHomeScreen> {
  bool _isLoadingTrend = true;
  List<double> _netProfits = [];
  List<String> _labels = [];
  double _totalNet = 0;
  double _pctChange = 0;

  @override
  void initState() {
    super.initState();
    _loadTrendData();
  }

  Future<void> _loadTrendData() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.apiUrl}/reports.php?type=analytics"),
        headers: {'Accept': 'application/json'},
      );
      final json = jsonDecode(response.body);
      if (json['success']) {
        final data = json['data'];
        final incomeList = List<num>.from(data['cash_flow']['income']);
        final expenseList = List<num>.from(data['cash_flow']['expense']);
        final labelList = List<String>.from(data['cash_flow']['labels']);

        List<double> profits = [];
        for (int i = 0; i < incomeList.length; i++) {
          profits.add((incomeList[i] - expenseList[i]).toDouble());
        }

        double total = profits.fold(0, (a, b) => a + b);
        double change = 0;
        if (profits.length >= 2) {
          double last = profits.last;
          double prev = profits[profits.length - 2];
          change = prev == 0 ? 100 : ((last - prev) / prev.abs()) * 100;
        }

        setState(() {
          _netProfits = profits;
          _labels = labelList.map((l) => l.split(' ')[0]).toList();
          _totalNet = total;
          _pctChange = change;
          _isLoadingTrend = false;
        });
      }
    } catch (e) {
      debugPrint("Trend Error: $e");
      setState(() => _isLoadingTrend = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(isDark),
                  const SizedBox(height: 24),
                  _buildInsightCard(isDark),
                  const SizedBox(height: 32),
                  Text(
                    "Key Reports",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReportStack(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF0F111A) : Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Executive Summaries",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              "Strategic financial overview",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.bell, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTabs(bool isDark) {
    return Row(
      children: [
        _buildTab("Overview", true, isDark),
        const SizedBox(width: 24),
        _buildTab("Tax Filing", false, isDark),
        const SizedBox(width: 24),
        _buildTab("Audit Logs", false, isDark),
      ],
    );
  }

  Widget _buildTab(String label, bool active, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active ? (isDark ? Colors.white : Colors.black) : Colors.grey,
          ),
        ),
        if (active)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 20,
            color: const Color(0xFF8B5CF6),
          ),
      ],
    );
  }

  Widget _buildInsightCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1429),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.1)),
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
                    "NET PROFIT TREND",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_totalNet >= 0 ? '+' : '-'}₹${_totalNet.abs().toStringAsFixed(0)}",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _pctChange >= 0 ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_pctChange >= 0 ? '+' : ''}${_pctChange.toStringAsFixed(1)}%",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _pctChange >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: _isLoadingTrend
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                : BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              if (index >= 0 && index < _labels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(_labels[index], style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(_netProfits.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: _netProfits[i],
                              color: const Color(0xFF8B5CF6),
                              width: 14,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStack(bool isDark) {
    final List<Map<String, dynamic>> reports = [
      {
        'title': 'Monthly Performance',
        'desc': 'Detailed breakdown of revenue streams and KPIs.',
        'icon': LucideIcons.calendar,
        'screen': const MonthlyPerformanceScreen(),
      },
      {
        'title': 'Balance Sheet',
        'desc': 'Assets, liabilities, and shareholder equity.',
        'icon': LucideIcons.landmark,
        'screen': const BalanceSheetScreen(),
      },
      {
        'title': 'Profit & Loss (P&L)',
        'desc': 'Summary of revenues, costs, and expenses.',
        'icon': LucideIcons.trendingUp,
        'screen': const ProfitLossScreen(),
      },
      {
        'title': 'Cash Flow',
        'desc': 'Movement of money in and out of business.',
        'icon': LucideIcons.banknote,
        'screen': const CashFlowScreen(),
      },
      {
        'title': 'Trial Balance',
        'desc': 'Worksheet listing all account balances for validation.',
        'icon': LucideIcons.calculator,
        'screen': const LedgerScreen(), // Using Ledger as placeholder or just simulate
      },
      {
        'title': 'General Ledger',
        'desc': 'Complete record of all financial transactions.',
        'icon': LucideIcons.bookOpen,
        'screen': const LedgerScreen(),
      },
      {
        'title': 'Financial Health Analysis',
        'desc': 'AI-driven audit of solvency, liquidity, and margins.',
        'icon': LucideIcons.activity,
        'screen': const MonthlyPerformanceScreen(),
      },
    ];

    return Column(
      children: reports.map((r) => _buildReportCard(r, isDark)).toList(),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> r, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1429) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(r['icon'], color: const Color(0xFF8B5CF6), size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            r['title'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            r['desc'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => r['screen']));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("View Report", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.download, size: 20, color: Colors.grey),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
