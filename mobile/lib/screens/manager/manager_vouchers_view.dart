import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';

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
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  Future<void> _handleVoucherAction(int id, bool approve) async {
    setState(() => _isProcessing = true);
    try {
      final res = approve 
        ? await _apiService.approveVoucher(id)
        : await _apiService.rejectVoucher(id, "Rejected by manager");
      
      if (mounted) {
        if (res['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(approve ? "Voucher Approved" : "Voucher Rejected"), backgroundColor: approve ? Colors.green : Colors.red),
          );
          widget.onRefresh();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? "Action failed"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0D0D17);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color accentPurple = Color(0xFFA855F7);
    const Color cardColor = Color(0xFF161625);
    const Color borderColor = Color(0xFF1F1F35);

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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => widget.onNavigate('dashboard'),
        ),
        title: Text(
          "Voucher Approvals",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.search, color: Colors.white, size: 20), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTabs(primaryPurple, accentPurple),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => widget.onRefresh(),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedTab == 0 && filteredVouchers.isNotEmpty) ...[
                            _buildSectionHeader("Prioritized Queue", "URGENT", const Color(0xFFF43F5E)),
                            const SizedBox(height: 16),
                            ...filteredVouchers.take(1).map((v) => _buildVoucherCard(v, isPrioritized: true, cardColor: cardColor, borderColor: borderColor, primaryPurple: primaryPurple)),
                            const SizedBox(height: 32),
                            _buildSectionHeader("Standard Queue", null, null),
                            const SizedBox(height: 16),
                            ...filteredVouchers.skip(1).map((v) => _buildVoucherCard(v, isPrioritized: false, cardColor: cardColor, borderColor: borderColor, primaryPurple: primaryPurple)),
                          ] else if (filteredVouchers.isEmpty) ...[
                            const SizedBox(height: 100),
                            Center(
                              child: Column(
                                children: [
                                  Icon(LucideIcons.checkCircle2, color: Colors.white.withOpacity(0.1), size: 80),
                                  const SizedBox(height: 16),
                                  Text(
                                    "All Caught Up!",
                                    style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No vouchers awaiting your approval.",
                                    style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.4)),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            ...filteredVouchers.map((v) => _buildVoucherCard(v, isPrioritized: false, cardColor: cardColor, borderColor: borderColor, primaryPurple: primaryPurple)),
                          ],
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator(color: primaryPurple)),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => widget.onRefresh(),
        backgroundColor: primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(LucideIcons.refreshCcw, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTabs(Color primaryPurple, Color accentPurple) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF161625),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem("Pending", 0, primaryPurple, accentPurple)),
          Expanded(child: _buildTabItem("Posted", 1, primaryPurple, accentPurple)),
          Expanded(child: _buildTabItem("Rejected", 2, primaryPurple, accentPurple)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, Color primaryPurple, Color accentPurple) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? tag, Color? tagColor) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        if (tag != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor!.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: tagColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVoucherCard(Map<String, dynamic> voucher, {required bool isPrioritized, required Color cardColor, required Color borderColor, required Color primaryPurple}) {
    final String type = (voucher['voucher_type_name'] ?? "Expense").toString();
    final String date = voucher['voucher_date'] ?? "N/A";
    final double amount = double.tryParse(voucher['total_debit']?.toString() ?? '0') ?? 0;
    final String narration = voucher['narration'] ?? "No description";
    final String requester = "${voucher['first_name'] ?? 'User'} ${voucher['last_name'] ?? ''}";
    final int id = int.tryParse(voucher['id']?.toString() ?? '0') ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isPrioritized ? primaryPurple.withOpacity(0.5) : borderColor),
        boxShadow: isPrioritized ? [
          BoxShadow(color: primaryPurple.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: primaryPurple,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                date,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "₹${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      narration,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isPrioritized)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryPurple.withOpacity(0.2)),
                  ),
                  child: const Icon(LucideIcons.fileText, color: Colors.white54, size: 24),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: primaryPurple.withOpacity(0.2),
                child: Text(requester[0], style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "By $requester",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_selectedTab == 0) // Only show actions for Pending
                Row(
                  children: [
                    _buildActionButton(LucideIcons.x, Colors.redAccent, () => _handleVoucherAction(id, false)),
                    const SizedBox(width: 12),
                    _buildActionButton(LucideIcons.check, const Color(0xFF10B981), () => _handleVoucherAction(id, true)),
                  ],
                )
              else 
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(
                     color: (_selectedTab == 1 ? Colors.green : Colors.red).withOpacity(0.1),
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(
                     _selectedTab == 1 ? "APPROVED" : "REJECTED",
                     style: GoogleFonts.plusJakartaSans(
                       fontSize: 10,
                       fontWeight: FontWeight.w800,
                       color: _selectedTab == 1 ? Colors.green : Colors.red,
                     ),
                   ),
                 ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
