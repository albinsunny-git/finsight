import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ManagerAccountsView extends StatefulWidget {
  final List<dynamic> accounts;
  final bool isDark;
  final double totalIncome;
  final double totalExpense;

  final Function(String) onNavigate;
  final VoidCallback onRefresh;

  const ManagerAccountsView({
    super.key,
    required this.accounts,
    required this.isDark,
    required this.totalIncome,
    required this.totalExpense,
    required this.onNavigate,
    required this.onRefresh,
  });

  @override
  State<ManagerAccountsView> createState() => _ManagerAccountsViewState();
}

class _ManagerAccountsViewState extends State<ManagerAccountsView> {
  Widget _buildBusinessUnitCard(String title, String subtitle, String amount,
      String trend, bool isPositive, IconData icon) {
    Color cardColor =
        widget.isDark ? const Color(0xFF1E293B) : const Color(0xFF2E2C23);
    Color textColor = Colors.white;
    Color subtextColor = Colors.grey[400]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.black87, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trend,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPositive
                          ? Colors.greenAccent
                          : (trend == 'Stable'
                              ? Colors.greenAccent
                              : Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onNavigate('reports'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "Manage",
                    style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onNavigate('reports'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(LucideIcons.trendingUp, size: 16),
                  label: Text(
                    "Quick View",
                    style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.isDark ? const Color(0xFF191813) : Colors.white;
    Color textColor = widget.isDark ? Colors.white : const Color(0xFF1A1D23);

    double totalBalance = 0;
    for (var acc in widget.accounts) {
      totalBalance += double.tryParse(acc['balance']?.toString() ?? '0') ?? 0;
    }

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
                      // Total Balance Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF2E2C23),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFFC107).withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "TOTAL BALANCE",
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFFFC107),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const Icon(LucideIcons.wallet,
                                    color: Color(0xFFFFC107), size: 20),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "₹${(totalBalance / 10000000).toStringAsFixed(2)} Cr",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: Colors.white,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Updated: Just now • ${widget.accounts.length} Business Units",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Business Units",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onNavigate('vouchers'),
                            child: Text(
                              "View All",
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (widget.accounts.isEmpty)
                        Center(
                            child: Text("No accounts found",
                                style: TextStyle(color: textColor)))
                      else
                        ...widget.accounts
                            .take(5)
                            .map((acc) => _buildBusinessUnitCard(
                                  acc['name'] ?? 'Primary Account',
                                  "ACC: **** ${acc['code']?.toString().padLeft(4).substring(0, 4) ?? '0000'}",
                                  "₹${((double.tryParse(acc['balance']?.toString() ?? '0') ?? 0) / 10000000).toStringAsFixed(1)} Cr",
                                  acc['is_active']?.toString() == '1' ||
                                          acc['is_active']?.toString() == 'true'
                                      ? "Active"
                                      : "Inactive",
                                  acc['is_active']?.toString() == '1' ||
                                      acc['is_active']?.toString() == 'true',
                                  LucideIcons.landmark,
                                )),
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
