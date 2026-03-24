import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class VoucherDetailScreen extends StatefulWidget {
  final Map<String, dynamic> voucher;
  final String userRole;
  final String currentUserId;

  const VoucherDetailScreen({
    super.key,
    required this.voucher,
    required this.userRole,
    required this.currentUserId,
  });

  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreenState();
}

class _VoucherDetailScreenState extends State<VoucherDetailScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late String _status;
  List<dynamic> _details = [];

  @override
  void initState() {
    super.initState();
    _status = (widget.voucher['status'] ?? 'Unknown').toString();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    final sysId = int.tryParse(widget.voucher['id'].toString()) ?? 0;
    final data = await _apiService.getVoucherDetails(sysId);
    if (!mounted) return;
    if (data.containsKey('details')) {
      _details = data['details'];
    }
    setState(() => _isLoading = false);
  }

  Future<void> _requestApproval() async {
    setState(() => _isLoading = true);
    final sysId = int.tryParse(widget.voucher['id'].toString()) ?? 0;

    final result = await _apiService.requestApproval(sysId);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnack("Request sent successfully!", Colors.green);
      setState(() => _status = 'Pending Approval');
      Navigator.pop(context, true); // Return true to refresh list
    } else {
      _showSnack(result['message'] ?? "Failed to send request", Colors.red);
    }
  }

  Future<void> _approveVoucher() async {
    setState(() => _isLoading = true);
    final sysId = int.tryParse(widget.voucher['id'].toString()) ?? 0;

    final result = await _apiService.approveVoucher(sysId);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      _showSnack("Voucher approved & posted!", Colors.green);
      setState(() => _status = 'Posted');
      Navigator.pop(context, true);
    } else {
      _showSnack(result['message'] ?? "Approval failed", Colors.red);
    }
  }

  Future<void> _rejectVoucher() async {
    // Show dialog to get reason
    TextEditingController reasonController = TextEditingController();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Reject Voucher",
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1D23))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Please provide a reason for rejecting this voucher.",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: "Reason for rejection...",
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey[400]),
                filled: true,
                fillColor: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: GoogleFonts.plusJakartaSans(color: Colors.grey[500])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                _showSnack("Reason is required", Colors.red);
                return;
              }
              Navigator.pop(context); // Close dialog

              setState(() => _isLoading = true);
              final sysId = int.tryParse(widget.voucher['id'].toString()) ?? 0;
              final result =
                  await _apiService.rejectVoucher(sysId, reasonController.text);
              setState(() => _isLoading = false);

              if (result['success'] == true) {
                _showSnack("Voucher rejected", Colors.orange);
                setState(() => _status = 'Rejected');
                // ignore: use_build_context_synchronously
                Navigator.pop(context, true);
              } else {
                _showSnack(result['message'] ?? "Rejection failed", Colors.red);
              }
            },
            child: Text("Reject",
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final voucher = widget.voucher;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Status Colors
    Color statusBg;
    Color statusText;
    if (_status == 'Posted' ||
        _status == 'VERIFIED' ||
        _status == 'APPROVED' ||
        _status == 'POSTED' ||
        _status == 'SUCCESS') {
      statusBg = const Color(0xFFE6FFFA);
      statusText = const Color(0xFF38A169);
    } else if (_status == 'Draft') {
      statusBg = Colors.grey.withOpacity(0.1);
      statusText = Colors.grey;
    } else if (_status == 'Rejected') {
      statusBg = const Color(0xFFFFF5F5);
      statusText = const Color(0xFFE53E3E);
    } else {
      statusBg = const Color(0xFFFFF7E6);
      statusText = const Color(0xFFD69E2E);
    }

    // Check Permissions
    final isOwner =
        (voucher['created_by'].toString() == widget.currentUserId.toString());
    final isAdminOrManager = ['manager']
        .contains(widget.userRole.toLowerCase());

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        title: Text("Voucher Details",
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1D23))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF1A1D23)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF2E6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                voucher['voucher_number'] ?? 'N/A',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF6B00),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _status.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: statusText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          voucher['narration'] ?? 'No Description',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color:
                                isDark ? Colors.white : const Color(0xFF1A1D23),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(LucideIcons.calendar,
                                size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Text(
                              voucher['voucher_date'] ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey[500], fontSize: 13),
                            ),
                            const SizedBox(width: 20),
                            Icon(LucideIcons.user,
                                size: 14, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Text(
                              voucher['first_name'] ?? 'Unknown',
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey[500], fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Funds Flow Card
                  if (voucher['from_account'] != null ||
                      voucher['to_account'] != null) ...[
                    Text(
                      "FUNDS FLOW",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.grey.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("FROM",
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w800)),
                                Text(
                                    voucher['from_account'] ??
                                        'Multiple Source',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1D23))),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Color(0xFFFFF2E6),
                                shape: BoxShape.circle),
                            child: const Icon(LucideIcons.arrowRight,
                                size: 16, color: Color(0xFFFF6B00)),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("TO",
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w800)),
                                Text(
                                    voucher['to_account'] ??
                                        'Multiple Destination',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1D23))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  Text(
                    "LINE ITEMS",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Items List
                  if (_details.isNotEmpty) ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _details.length,
                      itemBuilder: (context, index) {
                        final detail = _details[index];
                        final d =
                            double.tryParse(detail['debit'].toString()) ?? 0.0;
                        final c =
                            double.tryParse(detail['credit'].toString()) ?? 0.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (d > 0 &&
                                              (detail['type'] == 'Expense' ||
                                                  detail['type'] ==
                                                      'Income')) ||
                                          (c > 0 && detail['type'] == 'Asset')
                                      ? const Color(0xFFFEE2E2) // Red bg if -
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(LucideIcons.list,
                                    size: 18,
                                    color: (d > 0 &&
                                                (detail['type'] == 'Expense' ||
                                                    detail['type'] ==
                                                        'Income')) ||
                                            (c > 0 && detail['type'] == 'Asset')
                                        ? const Color(0xFFEF4444)
                                        : Colors.grey[600]),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail['name'] ?? 'Account',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1D23),
                                      ),
                                    ),
                                    Text(
                                      "${detail['type'] ?? 'Account'} • ${detail['description'] ?? 'Entry'}",
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey[500]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (d > 0)
                                    Text(
                                        "${(detail['type'] == 'Expense' || detail['type'] == 'Income') ? '-' : (detail['type'] == 'Asset' ? '+' : '')}₹${d.toStringAsFixed(2)}",
                                        style: GoogleFonts.plusJakartaSans(
                                            color: (detail['type'] ==
                                                        'Expense' ||
                                                    detail['type'] == 'Income')
                                                ? const Color(0xFFE53E3E)
                                                : (detail['type'] == 'Asset'
                                                    ? const Color(0xFF38A169)
                                                    : Colors.grey),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14)),
                                  if (c > 0)
                                    Text(
                                        "${(detail['type'] == 'Income' || detail['type'] == 'Expense') ? '+' : (detail['type'] == 'Asset' ? '-' : '')}₹${c.toStringAsFixed(2)}",
                                        style: GoogleFonts.plusJakartaSans(
                                            color: (detail['type'] ==
                                                        'Income' ||
                                                    detail['type'] == 'Expense')
                                                ? const Color(0xFF38A169)
                                                : (detail['type'] == 'Asset'
                                                    ? const Color(0xFFE53E3E)
                                                    : Colors.grey),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14)),
                                  Text(
                                    d > 0 ? "DEBIT" : "CREDIT",
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey[400]),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ] else if (!_isLoading) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                          child: Text("No line items found.",
                              style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey))),
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Totals Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D23),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("TOTAL DEBIT",
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(
                                  "₹${NumberFormat('#,##0.00').format(double.tryParse(voucher['total_debit']?.toString() ?? '0') ?? 0)}",
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.1)),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("TOTAL CREDIT",
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text(
                                  "₹${NumberFormat('#,##0.00').format(double.tryParse(voucher['total_credit']?.toString() ?? '0') ?? 0)}",
                                  style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Globalized Actions
                  if (_status == 'Draft' && isOwner)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _requestApproval,
                        child: Text("Request Approval",
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),

                  if (_status == 'Pending Approval' && isAdminOrManager)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: const BorderSide(color: Color(0xFFE53E3E)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _rejectVoucher,
                            child: Text("Reject",
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFE53E3E))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38A169),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: _approveVoucher,
                            child: Text("Approve",
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}
