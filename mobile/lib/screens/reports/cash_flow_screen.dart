import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class CashFlowScreen extends StatefulWidget {
  const CashFlowScreen({super.key});

  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text("Cash Flow Statement",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildRangeHeader(theme, isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("OPERATING ACTIVITIES"),
                _buildCashItem(
                    "Cash receipts from customers", "₹45,200.00", true),
                _buildCashItem("Cash paid to suppliers", "₹(28,400.00)", false),
                _buildCashItem(
                    "Cash paid for employees", "₹(12,000.00)", false),
                _buildSubtotal("Net Cash from Operating", "₹4,800.00"),
                const SizedBox(height: 24),
                _buildSectionHeader("INVESTING ACTIVITIES"),
                _buildCashItem("Purchase of equipment", "₹(5,000.00)", false),
                _buildCashItem("Sale of assets", "₹1,200.00", true),
                _buildSubtotal("Net Cash from Investing", "₹(3,800.00)"),
                const SizedBox(height: 24),
                _buildSectionHeader("FINANCING ACTIVITIES"),
                _buildCashItem("Proceeds from loans", "₹10,000.00", true),
                _buildCashItem("Repayment of loans", "₹(2,000.00)", false),
                _buildSubtotal("Net Cash from Financing", "₹8,000.00"),
                const Divider(height: 48, thickness: 2),
                _buildTotalRow(
                    "NET INCREASE IN CASH", "₹9,000.00", Colors.blue),
                _buildTotalRow("CASH AT BEGINNING", "₹12,450.00", null),
                _buildTotalRow("CASH AT END", "₹21,450.00", Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeHeader(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 18, color: Colors.blue),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PERIOD",
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  Text(
                    "${DateFormat('MMM dd, yy').format(_dateRange.start)} - ${DateFormat('MMM dd, yy').format(_dateRange.end)}",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDateRange: _dateRange);
              if (picked != null) setState(() => _dateRange = picked);
            },
            child: Text("Change",
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1)),
    );
  }

  Widget _buildCashItem(String label, String amount, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14)),
          Text(amount,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  Widget _buildSubtotal(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.bold)),
          Text(amount,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(amount,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
