import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:finsight_mobile/widgets/report_template.dart';
import 'package:finsight_mobile/utils/report_utils.dart';
import 'package:intl/intl.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  Map<String, dynamic>? _data;
  List<dynamic> _accounts = [];
  String? _selectedAccountId;
  DateTime _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _toDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final accounts = await _apiService.getAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        if (accounts.isNotEmpty) {
          _selectedAccountId = accounts[0]['id'].toString();
          _fetchLedger();
        }
      });
    }
  }

  Future<void> _fetchLedger() async {
    if (_selectedAccountId == null) return;
    setState(() => _isLoading = true);

    final fromStr = DateFormat('yyyy-MM-dd').format(_fromDate);
    final toStr = DateFormat('yyyy-MM-dd').format(_toDate);

    try {
      final url =
          '${ApiService.baseUrl}/reports.php?type=ledger&account_id=$_selectedAccountId&from=$fromStr&to=$toStr';
      final response = await _apiService.get(url);

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success']) {
          setState(() => _data = resData['data']);
        }
      }
    } catch (e) {
      print("Error fetching ledger: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadReport(BuildContext context) async {
    if (_data == null || _data!['transactions'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No data available to download")));
      return;
    }

    final fromStr = DateFormat('yyyy-MM-dd').format(_fromDate);
    final toStr = DateFormat('yyyy-MM-dd').format(_toDate);
    final accountName = _data!['account_name'] ?? 'Account';

    final List<String> headers = [
      "Date",
      "Particulars",
      "Voucher #",
      "Debit",
      "Credit",
      "Balance"
    ];
    final List<dynamic> txns = _data!['transactions'];

    final List<List<dynamic>> csvData = txns.map((t) {
      return [
        t['date'] ?? '',
        t['particulars'] ?? '',
        t['voucher_number'] ?? '',
        (double.tryParse(t['debit'].toString()) ?? 0).toStringAsFixed(2),
        (double.tryParse(t['credit'].toString()) ?? 0).toStringAsFixed(2),
        (double.tryParse(t['balance'].toString()) ?? 0).toStringAsFixed(2),
      ];
    }).toList();

    final currency = NumberFormat.currency(symbol: '₹');
    final opBal =
        double.tryParse(_data!['opening_balance']?.toString() ?? '0') ?? 0;
    final clBal =
        double.tryParse(_data!['closing_balance']?.toString() ?? '0') ?? 0;
    final dr = double.tryParse(_data!['period_debit']?.toString() ?? '0') ?? 0;
    final cr = double.tryParse(_data!['period_credit']?.toString() ?? '0') ?? 0;

    final summary = {
      'Opening Balance': currency.format(opBal),
      'Period Debit': currency.format(dr),
      'Period Credit': currency.format(cr),
      'Closing Balance': currency.format(clBal),
    };

    await ReportUtils.showDownloadOptions(
      context: context,
      reportName: "Ledger - $accountName",
      dateInfo: "$fromStr to $toStr",
      csvHeaders: headers,
      csvData: csvData,
      rawData: txns.cast<Map<String, dynamic>>(),
      summaryData: summary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = _data?['transactions'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Ledger',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: [const ThemeToggleButton(), 
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () => _downloadReport(context),
            tooltip: "Download CSV",
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.cardTheme.color,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedAccountId,
                  decoration: InputDecoration(
                    labelText: "Select Account",
                    prefixIcon: const Icon(LucideIcons.landmark),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _accounts
                      .map((acc) => DropdownMenuItem(
                            value: acc['id'].toString(),
                            child: Text("${acc['code']} - ${acc['name']}"),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedAccountId = val);
                    _fetchLedger();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(LucideIcons.calendar, size: 16),
                        label: Text(DateFormat('MMM dd').format(_fromDate)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: _fromDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now());
                          if (picked != null) {
                            setState(() => _fromDate = picked);
                            _fetchLedger();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(LucideIcons.calendar, size: 16),
                        label: Text(DateFormat('MMM dd').format(_toDate)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                              context: context,
                              initialDate: _toDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now());
                          if (picked != null) {
                            setState(() => _toDate = picked);
                            _fetchLedger();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _data == null
                    ? const Center(
                        child: Text("Select an account to view ledger"))
                    : SingleChildScrollView(
                        child: ReportTemplate(
                          title: "Account Ledger",
                          dateText:
                              "${DateFormat('MMM dd').format(_fromDate)} - ${DateFormat('MMM dd').format(_toDate)}",
                          child: Column(
                            children: [
                              _buildSummaryCard(),
                              const SizedBox(height: 16),
                              _buildTransactionList(transactions),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final opBal =
        double.tryParse(_data?['opening_balance']?.toString() ?? '0') ?? 0;
    final clBal =
        double.tryParse(_data?['closing_balance']?.toString() ?? '0') ?? 0;
    final dr = double.tryParse(_data?['period_debit']?.toString() ?? '0') ?? 0;
    final cr = double.tryParse(_data?['period_credit']?.toString() ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSummaryRow("Opening Balance", opBal),
              const Divider(),
              _buildSummaryRow("Period Debit", dr, color: Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : Colors.blue),
              _buildSummaryRow("Period Credit", cr, color: Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red),
              const Divider(),
              _buildSummaryRow("Closing Balance", clBal, isBold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            NumberFormat.currency(symbol: '₹').format(value),
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<dynamic> txs) {
    if (txs.isEmpty) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.landmark,
                    size: 48, color: theme.primaryColor),
              ),
              const SizedBox(height: 24),
              Text("No Ledger Activity",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color)),
              const SizedBox(height: 8),
              Text("No transactions found for the selected period",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txs.length,
      itemBuilder: (context, index) {
        final tx = txs[index];
        final dr = double.tryParse(tx['debit']?.toString() ?? '0') ?? 0;
        final cr = double.tryParse(tx['credit']?.toString() ?? '0') ?? 0;

        return ListTile(
          isThreeLine: true,
          leading: CircleAvatar(
            backgroundColor: dr > 0
                ? Colors.blue.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
                dr > 0 ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                size: 16,
                color: dr > 0 ? (Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : Colors.blue) : (Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red)),
          ),
          title: Text(tx['voucher_number'] ?? 'Voucher'),
          subtitle: Text(
              "${tx['voucher_date']}\n${tx['narration'] ?? tx['description'] ?? ''}"),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dr > 0 ? "Dr ₹$dr" : "Cr ₹$cr",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dr > 0 ? (Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : Colors.blue) : (Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red)),
              ),
              Text(
                "Bal ₹${tx['running_balance']}",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
