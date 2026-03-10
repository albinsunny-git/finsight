import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:finsight_mobile/widgets/report_template.dart';
import 'package:intl/intl.dart';
import 'package:finsight_mobile/utils/report_utils.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _data = [];
  DateTime _fromDate = DateTime(DateTime.now().year, 1, 1);
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final from = DateFormat('yyyy-MM-dd').format(_fromDate);
    final to = DateFormat('yyyy-MM-dd').format(_toDate);

    final result = await _apiService.getProfitLoss(fromDate: from, toDate: to);
    if (mounted) {
      setState(() {
        _data = result;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _fetchData();
    }
  }

  Future<void> _downloadReport(BuildContext context) async {
    if (_data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No data available to download")));
      return;
    }

    final dateStr =
        "${DateFormat('MMM dd').format(_fromDate)} - ${DateFormat('MMM dd, yyyy').format(_toDate)}";

    final List<String> headers = ["Code", "Account Name", "Type", "Amount"];
    final List<List<dynamic>> csvData = _data.map((item) {
      final amount = double.tryParse(item['amount'].toString()) ?? 0;
      return [
        item['code'] ?? '',
        item['name'] ?? '',
        item['type'] ?? '',
        amount.toStringAsFixed(2),
      ];
    }).toList();

    final income = _data.where((item) => item['type'] == 'Income').toList();
    final expense = _data.where((item) => item['type'] == 'Expense').toList();

    double totalIncome = income.fold(0,
        (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0));
    double totalExpense = expense.fold(0,
        (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0));
    double netProfit = totalIncome - totalExpense;
    final currency = NumberFormat.currency(symbol: '₹');

    final summary = {
      'Total Income': currency.format(totalIncome.abs()),
      'Total Expenses': currency.format(totalExpense.abs()),
      (netProfit >= 0 ? 'Net Profit' : 'Net Loss'):
          currency.format(netProfit.abs()),
    };

    await ReportUtils.showDownloadOptions(
      context: context,
      reportName: "Profit and Loss",
      dateInfo: dateStr,
      csvHeaders: headers,
      csvData: csvData,
      rawData: _data.cast<Map<String, dynamic>>(),
      summaryData: summary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final income = _data.where((item) => item['type'] == 'Income').toList();
    final expense = _data.where((item) => item['type'] == 'Expense').toList();

    double totalIncome = income.fold(0,
        (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0));
    double totalExpense = expense.fold(0,
        (sum, item) => sum + (double.tryParse(item['amount'].toString()) ?? 0));

    // In our system, Income is positive (Cr-Dr) and Expense is positive (Dr-Cr)
    // So Net Profit = Income - Expense
    double netProfit = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profit & Loss',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: [const ThemeToggleButton(), 
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () => _downloadReport(context),
            tooltip: "Download CSV",
          ),
          IconButton(
            icon: const Icon(LucideIcons.calendar),
            onPressed: () => _selectDateRange(context),
            tooltip: "Select Date Range",
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                child: ReportTemplate(
                  title: "Profit & Loss Statement",
                  dateText:
                      "${DateFormat('MMM dd, yyyy').format(_fromDate)} - ${DateFormat('MMM dd, yyyy').format(_toDate)}",
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _data.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 48.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(LucideIcons.barChart2,
                                        size: 48, color: theme.primaryColor),
                                  ),
                                  const SizedBox(height: 24),
                                  Text("No Profit & Loss Data",
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .textTheme.bodyLarge?.color)),
                                  const SizedBox(height: 8),
                                  Text(
                                      "No transactions recorded for this period",
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[400]
                                              : Colors.grey[600])),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Net Profit Card
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: netProfit >= 0
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: netProfit >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      width: 1.5),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                        netProfit >= 0
                                            ? "Net Profit"
                                            : "Net Loss",
                                        style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w600,
                                            color: netProfit >= 0
                                                ? Colors.green[800]
                                                : Colors.red[800])),
                                    const SizedBox(height: 8),
                                    Text(
                                        NumberFormat.currency(symbol: '₹')
                                            .format(netProfit.abs()),
                                        style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 32,
                                            color: netProfit >= 0
                                                ? Colors.green[900]
                                                : Colors.red[900])),
                                    if (netProfit < 0)
                                      Text("(Total Expenses > Total Income)",
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: Theme.of(context).brightness == Brightness.dark ? Colors.red[300] : Colors.red[700])),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              _buildSection(context, "Income", income,
                                  totalIncome, Colors.green),
                              const SizedBox(height: 24),
                              _buildSection(context, "Expenses", expense,
                                  totalExpense, Colors.red),
                            ],
                          ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<dynamic> items,
      double total, Color color) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(symbol: '₹');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 4,
                height: 20,
                color: color,
                margin: const EdgeInsets.only(right: 8)),
            Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(currency.format(total.abs()),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final amount = double.tryParse(item['amount'].toString()) ?? 0;
              return ListTile(
                title: Text(item['name'],
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500)),
                subtitle: Text(item['code'],
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.grey)),
                trailing: Text(
                  currency.format(amount.abs()),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color:
                        amount < 0 ? Colors.red : null, // Highlight reversals
                  ),
                ),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
