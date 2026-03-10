import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:finsight_mobile/screens/voucher_detail_screen.dart';

class ManagerVouchersView extends StatefulWidget {
  final List<dynamic> vouchers;
  final bool isDark;
  final double totalIncome;
  final double totalExpense;
  final String currentUserId;

  final Function(String) onNavigate;
  final VoidCallback onRefresh;

  const ManagerVouchersView({
    super.key,
    required this.vouchers,
    required this.isDark,
    required this.totalIncome,
    required this.totalExpense,
    required this.currentUserId,
    required this.onNavigate,
    required this.onRefresh,
  });

  @override
  State<ManagerVouchersView> createState() => _ManagerVouchersViewState();
}

class _ManagerVouchersViewState extends State<ManagerVouchersView> {
  int _selectedTab = 0;

  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? const Color(0xFFFFC107) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFFFFC107) : Colors.grey[500],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final ApiService _apiService = ApiService();

  void _navigateToDetail(Map<String, dynamic> voucher) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoucherDetailScreen(
          voucher: voucher,
          userRole: 'manager',
          currentUserId: widget.currentUserId,
        ),
      ),
    );

    if (result == true) {
      widget.onRefresh();
    }
  }

  Future<void> _handleApprove(Map<String, dynamic> voucher) async {
    final sysId = int.tryParse(voucher['id'].toString()) ?? 0;
    final result = await _apiService.approveVoucher(sysId);
    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Voucher Approved"), backgroundColor: Colors.green),
        );
        widget.onRefresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? "Approval failed"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleReject(Map<String, dynamic> voucher) async {
    TextEditingController reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Voucher"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: "Reason for rejection"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Reject")),
        ],
      ),
    );

    if (result == true) {
      final sysId = int.tryParse(voucher['id'].toString()) ?? 0;
      final apiResult =
          await _apiService.rejectVoucher(sysId, reasonController.text);
      if (mounted) {
        if (apiResult['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Voucher Rejected"),
                backgroundColor: Colors.orange),
          );
          widget.onRefresh();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(apiResult['message'] ?? "Rejection failed"),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Widget _buildVoucherCard(Map<String, dynamic> voucher) {
    final String title =
        voucher['voucher_type_name']?.toString().toUpperCase() ?? "GENERAL";
    final String subtitle = voucher['narration'] ?? "No description provided";
    final String price =
        "\$${double.tryParse(voucher['total_debit']?.toString() ?? '0')?.toStringAsFixed(2) ?? '0.00'}";
    final String imgUrl =
        "https://images.unsplash.com/photo-1554224155-6726b3ff858f?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80";
    final String user =
        "${voucher['first_name'] ?? 'Rajesh'} ${voucher['last_name'] ?? 'Kumar'}"
            .trim();
    final String id = "#${voucher['voucher_number'] ?? voucher['id']}";
    final String date =
        voucher['voucher_date']?.toString().split(' ')[0] ?? "24 OCT";
    final String status = voucher['status']?.toString() ?? "pending";

    Color cardColor = widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = widget.isDark ? Colors.white : Colors.black87;
    Color subtextColor = Colors.grey[500]!;

    return GestureDetector(
      onTap: () => _navigateToDetail(voucher),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(imgUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            date.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: subtextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: subtextColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "Submitted by $user",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: subtextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text("•", style: TextStyle(color: subtextColor)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: subtextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (status.toLowerCase() == 'pending' || status == '0') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleReject(voucher),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE53E3E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Reject",
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFE53E3E),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApprove(voucher),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38A169),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Approve",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Builder(builder: (context) {
                    Color statusBg;
                    Color statusColor;
                    if (status.toLowerCase() == 'posted' || status == '1') {
                      statusBg = Colors.green.withOpacity(0.1);
                      statusColor = Colors.greenAccent;
                    } else {
                      statusBg = Colors.red.withOpacity(0.1);
                      statusColor = Colors.redAccent;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (status.toLowerCase() == 'posted' || status == '1')
                            ? "APPROVED"
                            : "REJECTED",
                        style: GoogleFonts.plusJakartaSans(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _navigateToDetail(voucher),
                    icon: const Icon(LucideIcons.edit, size: 14),
                    label: Text(
                      "Edit",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B00),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor =
        widget.isDark ? const Color(0xFF141414) : const Color(0xFFF5F5F5);

    // Filter logic
    final statusMap = {0: 'pending', 1: 'posted', 2: 'rejected'};
    final currentStatus = statusMap[_selectedTab] ?? 'pending';

    final filteredVouchers = widget.vouchers.where((v) {
      final s = v['status']?.toString().toLowerCase() ?? 'pending';
      return s == currentStatus;
    }).toList();

    int pendingCount = widget.vouchers
        .where((v) => v['status']?.toString().toLowerCase() == 'pending')
        .length;

    String sectionTitle = "AWAITING ACTION";
    if (_selectedTab == 1) sectionTitle = "RECENTLY APPROVED";
    if (_selectedTab == 2) sectionTitle = "REJECTED VOUCHERS";

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_back_ios_new,
                          color: widget.isDark ? Colors.white : Colors.black87,
                          size: 20),
                      const SizedBox(width: 16),
                      Text(
                        "Voucher Review",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.notifications,
                      color: widget.isDark ? Colors.white : Colors.black87,
                      size: 24),
                ],
              ),
            ),

            // Tabs
            Row(
              children: [
                _buildTab("Pending ($pendingCount)", 0),
                _buildTab("Approved", 1),
                _buildTab("Rejected", 2),
              ],
            ),
            Divider(
                height: 1,
                color: widget.isDark ? Colors.white12 : Colors.black12),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  widget.onRefresh();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.green.withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "TOTAL INCOME",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${(widget.totalIncome / 100000).toStringAsFixed(1)} L",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.red.withOpacity(0.1)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "TOTAL EXPENSE",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "₹${(widget.totalExpense / 100000).toStringAsFixed(1)} L",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sectionTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                              letterSpacing: 1,
                            ),
                          ),
                          if (_selectedTab == 0)
                            Row(
                              children: [
                                Text(
                                  "Select All",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFFFC107),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.checklist,
                                    color: Color(0xFFFFC107), size: 18),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (filteredVouchers.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Column(
                              children: [
                                Icon(LucideIcons.inbox,
                                    size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text("No vouchers in this category",
                                    style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredVouchers.map((v) => _buildVoucherCard(v)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
