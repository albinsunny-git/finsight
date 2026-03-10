import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:finsight_mobile/widgets/report_template.dart';
import 'package:intl/intl.dart';
import 'package:finsight_mobile/utils/report_utils.dart';

class BalanceSheetScreen extends StatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  State<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends State<BalanceSheetScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _data = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final result = await _apiService.getBalanceSheet(asOnDate: dateStr);
    if (mounted) {
      setState(() {
        _data = result;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    final List<String> headers = [
      "Code",
      "Account Name",
      "Type",
      "Sub Type",
      "Balance"
    ];
    final List<List<dynamic>> csvData = _data.map((item) {
      final balance = double.tryParse(item['balance'].toString()) ?? 0;
      return [
        item['code'] ?? '',
        item['name'] ?? '',
        item['type'] ?? '',
        item['sub_type'] ?? '',
        balance.toStringAsFixed(2),
      ];
    }).toList();

    final assets = _data.where((item) => item['type'] == 'Asset').toList();
    final liabilities =
        _data.where((item) => item['type'] == 'Liability').toList();
    final equity = _data.where((item) => item['type'] == 'Equity').toList();

    double totalAssets = assets.fold(
        0,
        (sum, item) =>
            sum + (double.tryParse(item['balance'].toString()) ?? 0));
    double totalLiabilities = liabilities.fold(
        0,
        (sum, item) =>
            sum + (double.tryParse(item['balance'].toString()) ?? 0));
    double totalEquity = equity.fold(
        0,
        (sum, item) =>
            sum + (double.tryParse(item['balance'].toString()) ?? 0));

    final currency = NumberFormat.currency(symbol: '₹');
    final summary = {
      'Total Assets': currency.format(totalAssets),
      'Total Liabilities': currency.format(totalLiabilities),
      'Total Equity': currency.format(totalEquity),
      'Liabilities + Equity': currency.format(totalLiabilities + totalEquity),
    };

    if (totalAssets.toStringAsFixed(2) !=
        (totalLiabilities + totalEquity).toStringAsFixed(2)) {
      summary['Imbalance'] = currency
          .format((totalAssets - (totalLiabilities + totalEquity)).abs());
    }

    await ReportUtils.showDownloadOptions(
      context: context,
      reportName: "Balance Sheet",
      dateInfo: "As of $dateStr",
      csvHeaders: headers,
      csvData: csvData,
      rawData: _data.cast<Map<String, dynamic>>(),
      summaryData: summary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group Data
    final assets = _data.where((item) => item['type'] == 'Asset').toList();
    final liabilities =
        _data.where((item) => item['type'] == 'Liability').toList();
    final equity = _data.where((item) => item['type'] == 'Equity').toList();

    double totalAssets = assets.fold(
        0,
        (sum, item) =>
            sum + (double.tryParse(item['balance'].toString()) ?? 0));
    double totalLiabilities = liabilities.fold(
        0,
        (sum, item) =>
            sum + (double.tryParse(item['balance'].toString()) ?? 0));
    double totalEquity = equity.fold(
        0,
        (sum, item) =>
            sum + (double.tryParse(item['balance'].toString()) ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text('Balance Sheet',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: [const ThemeToggleButton(), 
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () => _downloadReport(context),
            tooltip: "Download CSV",
          ),
          IconButton(
            icon: const Icon(LucideIcons.calendar),
            onPressed: () => _selectDate(context),
            tooltip: "Select Date",
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                child: ReportTemplate(
                  title: "Balance Sheet",
                  dateText:
                      "As of ${DateFormat('MMM dd, yyyy').format(_selectedDate)}",
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
                                    child: Icon(LucideIcons.pieChart,
                                        size: 48, color: theme.primaryColor),
                                  ),
                                  const SizedBox(height: 24),
                                  Text("No Balance Sheet Data",
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
                              _buildSection(context, "Assets", assets,
                                  totalAssets, Colors.green),
                              const SizedBox(height: 24),
                              _buildSection(context, "Liabilities", liabilities,
                                  totalLiabilities, Colors.red),
                              const SizedBox(height: 24),
                              _buildSection(context, "Equity", equity,
                                  totalEquity, Colors.blue),
                              const SizedBox(height: 32),

                              // Accounting Equation Check
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: theme.cardTheme.color,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: (totalAssets.toStringAsFixed(2) ==
                                              (totalLiabilities + totalEquity)
                                                  .toStringAsFixed(2))
                                          ? Colors.green.withOpacity(0.5)
                                          : Colors.orange.withOpacity(0.5),
                                      width: 1.5),
                                ),
                                child: Column(
                                  children: [
                                    _buildTotalRow("Total Assets", totalAssets,
                                        Colors.green),
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      child: Divider(),
                                    ),
                                    _buildTotalRow(
                                        "Total Liab. + Equity",
                                        totalLiabilities + totalEquity,
                                        Colors.blue),
                                    if (totalAssets.toStringAsFixed(2) !=
                                        (totalLiabilities + totalEquity)
                                            .toStringAsFixed(2))
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                            "Imbalance: ¥${(totalAssets - (totalLiabilities + totalEquity)).abs().toStringAsFixed(2)}",
                                            style: GoogleFonts.plusJakartaSans(
                                                color: Colors.red,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTotalRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600, fontSize: 15)),
        Text(
          NumberFormat.currency(symbol: '₹').format(value),
          style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
      ],
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
            Text(currency.format(total),
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
              final balance = double.tryParse(item['balance'].toString()) ?? 0;
              return ListTile(
                title: Text(item['name'],
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500)),
                subtitle: Text(item['code'],
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.grey)),
                trailing: Text(
                  currency.format(balance.abs()),
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
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
