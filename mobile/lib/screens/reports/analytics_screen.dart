import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final result = await _apiService.getAnalytics();
    if (mounted) {
      setState(() {
        _data = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          actions: const [ThemeToggleButton()],
          title: Text('Financial Analytics',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Cash Flow
    final cashFlow = _data['cash_flow'] ?? {};
    final List<double> cfIncome = (cashFlow['income'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];
    final List<double> cfExpense = (cashFlow['expense'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];

    // Top Expenses
    final expenses = _data['top_expenses'] ?? {};
    final List<String> expLabels = (expenses['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final List<double> expData = (expenses['data'] as List<dynamic>?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];

    double totalRevenue = cfIncome.fold(0, (sum, item) => sum + item);
    double totalExpense = cfExpense.fold(0, (sum, item) => sum + item);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Financial Reports',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1D23))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [ThemeToggleButton()],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metric Cards Row
              Row(
                children: [
                  _buildMiniMetricCard(
                      "Revenue",
                      "₹${NumberFormat('#,##0').format(totalRevenue)}",
                      const Color(0xFF38A169),
                      isDark),
                  const SizedBox(width: 12),
                  _buildMiniMetricCard(
                      "Expense",
                      "₹${NumberFormat('#,##0').format(totalExpense)}",
                      const Color(0xFFE53E3E),
                      isDark),
                  const SizedBox(width: 12),
                  _buildMiniMetricCard(
                      "Net Profit",
                      "₹${NumberFormat('#,##0').format(totalRevenue - totalExpense)}",
                      const Color(0xFFFF6B00),
                      isDark),
                ],
              ),
              const SizedBox(height: 24),
              // Revenue vs Expense Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Revenue vs Expense",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1D23),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: cfIncome
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: true,
                              color: const Color(0xFFFF6B00),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B00).withOpacity(0.2),
                                    const Color(0xFFFF6B00).withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            LineChartBarData(
                              spots: cfExpense
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: true,
                              color: const Color(0xFF2563EB),
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2563EB).withOpacity(0.1),
                                    const Color(0xFF2563EB).withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Expense by Category",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1D23),
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(expLabels.length, (index) {
                return _buildCategoryExpenseItem(
                    expLabels[index], expData[index], isDark);
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMetricCard(
      String title, String amount, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(amount,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryExpenseItem(String label, double amount, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2E6),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(LucideIcons.tag, color: Color(0xFFFF6B00), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1A1D23),
              ),
            ),
          ),
          Text(
            "₹${NumberFormat('#,##0.00').format(amount)}",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: const Color(0xFFE53E3E),
            ),
          ),
        ],
      ),
    );
  }
}
