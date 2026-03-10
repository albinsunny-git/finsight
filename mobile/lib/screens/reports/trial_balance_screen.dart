import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:finsight_mobile/widgets/report_template.dart';
import 'package:intl/intl.dart';
import 'package:finsight_mobile/utils/report_utils.dart';

class TrialBalanceScreen extends StatefulWidget {
  const TrialBalanceScreen({super.key});

  @override
  State<TrialBalanceScreen> createState() => _TrialBalanceScreenState();
}

class _TrialBalanceScreenState extends State<TrialBalanceScreen> {
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
    final result = await _apiService.getTrialBalance(asOnDate: dateStr);
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
    if (picked != null) {
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
    final List<String> headers = ["Code", "Account Name", "Debit", "Credit"];

    double totalDebit = 0;
    double totalCredit = 0;

    final List<List<dynamic>> csvData = _data.map((item) {
      final dr = double.tryParse(item['total_debit']?.toString() ?? '0') ?? 0;
      final cr = double.tryParse(item['total_credit']?.toString() ?? '0') ?? 0;
      totalDebit += dr;
      totalCredit += cr;
      return [
        item['code'] ?? '',
        item['name'] ?? '',
        dr.toStringAsFixed(2),
        cr.toStringAsFixed(2),
      ];
    }).toList();

    final currency = NumberFormat.currency(symbol: '₹');
    final summary = {
      'Total Debit': currency.format(totalDebit),
      'Total Credit': currency.format(totalCredit),
    };

    await ReportUtils.showDownloadOptions(
      context: context,
      reportName: "Trial Balance",
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Trial Balance',
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
          : SingleChildScrollView(
              child: ReportTemplate(
                title: "Trial Balance",
                dateText:
                    "As of ${DateFormat('MMM dd, yyyy').format(_selectedDate)}",
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _data.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48.0),
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(LucideIcons.fileSpreadsheet,
                                      size: 48, color: theme.primaryColor),
                                ),
                                const SizedBox(height: 24),
                                Text("No Trial Balance Data",
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            theme.textTheme.bodyLarge?.color)),
                                const SizedBox(height: 8),
                                Text("No transactions recorded for this date",
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600])),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // Header Row
                            Container(
                              color:
                                  isDark ? Colors.grey[900] : Colors.grey[200],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text('Account',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                      child: Text('Debit',
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                      child: Text('Credit',
                                          textAlign: TextAlign.right,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold))),
                                ],
                              ),
                            ),

                            // List
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: _data.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = _data[index];
                                // Check if this is a "TOTAL" row if your API returns one, otherwise just standard rendering
                                // Usually APIs might return a specific row for totals or we calculate it.
                                // Assuming API might return it based on previous code.
                                final isTotal = item['name'] == 'TOTAL' ||
                                    item['account_name'] == 'TOTAL';

                                return Container(
                                  color: isTotal
                                      ? (isDark
                                          ? Colors.blue.withOpacity(0.2)
                                          : Colors.blue.withOpacity(0.1))
                                      : null,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    title: Text(
                                        item['name'] ??
                                            item['account_name'] ??
                                            'Unknown',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: isTotal
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          fontSize: isTotal ? 16 : 14,
                                        )),
                                    subtitle: !isTotal && item['code'] != null
                                        ? Text(item['code'],
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                color: Colors.grey))
                                        : null,
                                    trailing: SizedBox(
                                      width: 160,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              NumberFormat.currency(symbol: '')
                                                  .format(double.tryParse(item[
                                                                  'total_debit']
                                                              ?.toString() ??
                                                          '0') ??
                                                      0),
                                              textAlign: TextAlign.right,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontWeight: isTotal
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isTotal
                                                          ? Colors.blue
                                                          : null),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              NumberFormat.currency(symbol: '')
                                                  .format(double.tryParse(
                                                          item['total_credit']
                                                                  ?.toString() ??
                                                              '0') ??
                                                      0),
                                              textAlign: TextAlign.right,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontWeight: isTotal
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isTotal
                                                          ? Colors.blue
                                                          : null),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
            ),
    );
  }
}
