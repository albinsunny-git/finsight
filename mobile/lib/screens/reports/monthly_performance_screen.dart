import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finsight_mobile/config.dart';

class MonthlyPerformanceScreen extends StatefulWidget {
  const MonthlyPerformanceScreen({super.key});

  @override
  State<MonthlyPerformanceScreen> createState() => _MonthlyPerformanceScreenState();
}

class _MonthlyPerformanceScreenState extends State<MonthlyPerformanceScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    try {
      final now = DateTime.now();
      final from = "${now.year}-${now.month.toString().padLeft(2, '0')}-01";
      final to = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      final response = await http.get(
        Uri.parse("${AppConfig.apiUrl}/reports.php?type=performance&from=$from&to=$to"),
      );
      
      final json = jsonDecode(response.body);
      if (json['success']) {
        setState(() {
          _data = json['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Report Load Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Performance Report",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.download, color: isDark ? Colors.white : Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _data == null
              ? const Center(child: Text("Failed to load report data"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildMetricsGrid(),
                      const SizedBox(height: 24),
                      _buildIndicators(),
                      const SizedBox(height: 24),
                      _buildStrategicInsights(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            "MONTHLY PERFORMANCE",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8B5CF6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Executive Analysis",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final income = _data!['total_income'] ?? 0.0;
    final expense = _data!['total_expense'] ?? 0.0;
    final net = income - expense;
    final margin = income > 0 ? (net / income * 100).toStringAsFixed(1) : "0.0";

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard(
          "GROSS REVENUE",
          income.toString(),
          LucideIcons.arrowUpRight,
          const Color(0xFF10B981),
        ),
        _buildMetricCard(
          "TOTAL EXPENSES",
          expense.toString(),
          LucideIcons.arrowDownRight,
          const Color(0xFFEF4444),
        ),
        _buildMetricCard(
          "NET PROFIT",
          net.abs().toString(),
          LucideIcons.wallet,
          const Color(0xFFF59E0B),
          prefix: net < 0 ? "-" : "+",
        ),
        _buildMetricCard(
          "PROFIT MARGIN",
          "$margin%",
          LucideIcons.percent,
          const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, {String? prefix}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1429) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              "${prefix ?? ''}₹$value",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    final income = _data!['total_income'] ?? 0.0;
    final expense = _data!['total_expense'] ?? 0.0;
    final net = income - expense;
    final margin = income > 0 ? (net / income * 100) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Financial Health Indicators",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressBar("Profitability Index", margin / 100, const Color(0xFF10B981)),
        const SizedBox(height: 16),
        _buildProgressBar("Expense Efficiency", (100 - (margin > 0 ? margin : 0)) / 100, const Color(0xFF8B5CF6)),
      ],
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1429) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              Text("${(progress * 100).toInt()}%", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.1),
              color: color,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategicInsights() {
    final income = _data!['total_income'] ?? 0.0;
    final expense = _data!['total_expense'] ?? 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.05),
        border: Border(left: BorderSide(color: const Color(0xFF8B5CF6), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Strategic Insights",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 12),
          Text(
            income >= expense 
                ? "The business is maintaining a positive profit margin. Strategic focus should be on scaling operations while optimizing fixed costs."
                : "Operational expenditures currently exceed revenue. A detailed audit of high-cost ledgers is recommended to stabilize liquidity.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
