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
  @override
  Widget build(BuildContext context) {
    // Amethyst theme colors
    final Color bgColor = const Color(0xFF0D0D17);
    final Color primaryPurple = const Color(0xFF8B5CF6);

    // Group accounts by category (simplified for now)
    final assets = widget.accounts.where((a) => a['type'] == 'Asset' || a['type'] == 'Bank' || a['type'] == 'Cash').toList();
    final liabilities = widget.accounts.where((a) => a['type'] == 'Liability').toList();
    final equity = widget.accounts.where((a) => a['type'] == 'Equity').toList();

    double totalAssets = 0;
    for (var a in assets) totalAssets += double.tryParse(a['balance']?.toString() ?? '0') ?? 0;
    
    double totalLiabilities = 0;
    for (var a in liabilities) totalLiabilities += double.tryParse(a['balance']?.toString() ?? '0') ?? 0;

    double totalEquity = 0;
    for (var a in equity) totalEquity += double.tryParse(a['balance']?.toString() ?? '0') ?? 0;

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
          "Chart of Accounts",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.filter, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricTile("Total Assets", totalAssets, "+5.2%", const Color(0xFF10B981), primaryPurple, 0.7),
            const SizedBox(height: 16),
            _buildMetricTile("Total Liabilities", totalLiabilities, "-1.8%", const Color(0xFFF43F5E), primaryPurple, 0.3),
            const SizedBox(height: 16),
            _buildMetricTile("Total Equity", totalEquity, "+8.4%", const Color(0xFF10B981), primaryPurple, 0.6),
            const SizedBox(height: 32),
            Row(
              children: [
                const Icon(LucideIcons.wallet, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 8),
                Text(
                  "Account Categories",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCategoryTile("Assets", "${assets.length} Sub-accounts", totalAssets, LucideIcons.box, true),
            _buildCategoryTile("Liabilities", "${liabilities.length} Sub-accounts", totalLiabilities, LucideIcons.creditCard, false),
            _buildCategoryTile("Equity", "${equity.length} Sub-accounts", totalEquity, LucideIcons.pieChart, false),
            const SizedBox(height: 32),
            _buildGenerateReportCard(primaryPurple),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMetricTile(String title, double value, String trend, Color trendColor, Color barColor, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161625),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(trend.startsWith('+') ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: trendColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\$${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF1F1F35),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String title, String subtitle, double amount, IconData icon, bool isExpanded) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "\$${amount.toStringAsFixed(2)}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 8),
              Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, color: Colors.grey[600], size: 20),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF1F1F35)),
            const SizedBox(height: 16),
            _buildSubCategoryItem("Current Assets", "\$200,000.00"),
            _buildSubCategoryItem("Fixed Assets", "\$250,000.00"),
            _buildSubCategoryItem("Inventory", "\$50,000.00"),
          ]
        ],
      ),
    );
  }

  Widget _buildSubCategoryItem(String title, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateReportCard(Color primaryPurple) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryPurple,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Generate Report",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Export your full Chart of Accounts for auditing purposes.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "Export as PDF",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
