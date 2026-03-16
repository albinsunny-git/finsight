import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF0D0D17);
    final Color primaryPurple = const Color(0xFF8B5CF6);

    // Filter logic
    final statusMap = {0: 'pending', 1: 'posted', 2: 'rejected'};
    final currentStatus = statusMap[_selectedTab] ?? 'pending';

    final filteredVouchers = widget.vouchers.where((v) {
      final s = v['status']?.toString().toLowerCase() ?? 'pending';
      return s == currentStatus;
    }).toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => widget.onNavigate('dashboard'),
        ),
        title: Text(
          "Voucher Approvals",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.history, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.filter, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(primaryPurple),
          const Divider(color: Color(0xFF1F1F35), height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedTab == 0) ...[
                    _buildSectionHeader("Prioritized Queue", "URGENT", const Color(0xFFF43F5E)),
                    const SizedBox(height: 16),
                    ...filteredVouchers.take(2).map((v) => _buildVoucherCard(v, isPrioritized: true)),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Standard Queue", null, null),
                    const SizedBox(height: 16),
                    ...filteredVouchers.skip(2).map((v) => _buildVoucherCard(v, isPrioritized: false)),
                  ] else ...[
                    ...filteredVouchers.map((v) => _buildVoucherCard(v, isPrioritized: false)),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(LucideIcons.ticket, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildTabs(Color primaryPurple) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem("Pending (12)", 0, primaryPurple),
          _buildTabItem("Approved", 1, primaryPurple),
          _buildTabItem("Rejected", 2, primaryPurple),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, Color primaryPurple) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? primaryPurple : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? tag, Color? tagColor) {
    return Row(
      children: [
        if (title == "Prioritized Queue") 
          const Icon(LucideIcons.alertCircle, color: Color(0xFFF59E0B), size: 20),
        if (title == "Standard Queue")
          const Icon(LucideIcons.layoutList, color: Color(0xFF8B5CF6), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        if (tag != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor!.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              tag,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: tagColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> voucher, {required bool isPrioritized}) {
    final String type = voucher['voucher_type_name']?.toString() ?? "Marketing";
    final String time = "2h ago"; // Placeholder
    final double amount = double.tryParse(voucher['total_debit']?.toString() ?? '0') ?? 450.0;
    final String narration = voucher['narration'] ?? "Q3 Campaign Social Assets";
    final String requester = "${voucher['first_name'] ?? 'Sarah'} ${voucher['last_name'] ?? 'Jenkins'}";
    
    // Receipt image placeholder
    final receiptImg = "https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=200&q=80";

    if (isPrioritized) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161625),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1F1F35)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              type,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "• $time",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "\$${amount.toStringAsFixed(2)}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        narration,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(receiptImg),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$requester"),
                ),
                const SizedBox(width: 8),
                Text(
                  "Requested by: ",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  requester,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.checkCircle, size: 16),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.eye, size: 16),
                    label: const Text("Review"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F1F35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Standard Queue Item
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161625),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1F1F35)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "\$${amount.toStringAsFixed(2)}",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        narration,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        requester,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E2344),
                      foregroundColor: const Color(0xFFA855F7),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F1F35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Review"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
