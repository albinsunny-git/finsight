import 'package:flutter/material.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:finsight_mobile/widgets/report_template.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class CashFlowScreen extends StatefulWidget {
  const CashFlowScreen({super.key});

  @override
  State<CashFlowScreen> createState() => _CashFlowScreenState();
}

class _CashFlowScreenState extends State<CashFlowScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _data = [];
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final from = DateFormat('yyyy-MM-dd').format(_dateRange.start);
    final to = DateFormat('yyyy-MM-dd').format(_dateRange.end);

    final result = await _apiService.getCashFlow(fromDate: from, toDate: to);
    if (mounted) {
      setState(() {
        _data = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₹');

    double totalInflow = _data.fold(0, (sum, item) => sum + (double.tryParse(item['inflow'].toString()) ?? 0));
    double totalOutflow = _data.fold(0, (sum, item) => sum + (double.tryParse(item['outflow'].toString()) ?? 0));
    double totalOpening = _data.fold(0, (sum, item) => sum + (double.tryParse(item['opening'].toString()) ?? 0));
    double totalClosing = _data.fold(0, (sum, item) => sum + (double.tryParse(item['closing'].toString()) ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text("Cash Flow", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: [const ThemeToggleButton()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                child: ReportTemplate(
                  title: "Cash Flow Statement",
                  dateText: "${DateFormat('MMM dd').format(_dateRange.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange.end)}",
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRangePicker(theme),
                        const SizedBox(height: 24),
                        
                        if (_data.isEmpty)
                          _buildEmptyState(theme)
                        else
                          Column(
                            children: [
                              _buildSummaryCard(theme, totalInflow, totalOutflow, totalClosing - totalOpening),
                              const SizedBox(height: 32),
                              
                              _buildSectionHeader("CASH & BANK BALANCES"),
                              const SizedBox(height: 8),
                              ..._data.map((item) => _buildCashAccountCard(theme, item, currency)),
                              
                              const Divider(height: 48, thickness: 1),
                              
                              _buildTotalRow("CASH AT BEGINNING", currency.format(totalOpening), null),
                              _buildTotalRow("NET CHANGE IN CASH", currency.format(totalClosing - totalOpening), (totalClosing - totalOpening) >= 0 ? Colors.blue : Colors.red),
                              _buildTotalRow("CASH AT END", currency.format(totalClosing), Colors.green),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRangePicker(ThemeData theme) {
    return InkWell(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2101),
          initialDateRange: _dateRange,
        );
        if (picked != null) {
          setState(() => _dateRange = picked);
          _fetchData();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, size: 18, color: Colors.blue),
            const SizedBox(width: 12),
            Text("Filter Period", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(LucideIcons.chevronDown, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, double inflow, double outflow, double net) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem("Inflow", inflow, Colors.green),
          _buildSummaryItem("Outflow", outflow, Colors.red),
          _buildSummaryItem("Net", net, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double val, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(NumberFormat.compactCurrency(symbol: '₹').format(val),
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _buildCashAccountCard(ThemeData theme, dynamic item, NumberFormat currency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(LucideIcons.wallet, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(item['name'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(currency.format(double.tryParse(item['closing'].toString()) ?? 0), 
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniLabel("Opening", currency.format(double.tryParse(item['opening'].toString()) ?? 0)),
                _buildMiniLabel("Inflow", "+ ${currency.format(double.tryParse(item['inflow'].toString()) ?? 0)}", Colors.green),
                _buildMiniLabel("Outflow", "- ${currency.format(double.tryParse(item['outflow'].toString()) ?? 0)}", Colors.red),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniLabel(String label, String val, [Color? color]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey)),
        Text(val, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1));
  }

  Widget _buildTotalRow(String label, String amount, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          Text(amount, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(LucideIcons.frown, size: 48, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text("No cash transactions found", style: GoogleFonts.plusJakartaSans(color: Colors.grey)),
        ],
      ),
    );
  }
}
