import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/screens/edit_account_screen.dart';

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
  String? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    // Amethyst theme colors
    const Color bgColor = Color(0xFF0D0D17);
    const Color cardColor = Color(0xFF161625);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color accentPurple = Color(0xFFA855F7);
    const Color borderColor = Color(0xFF1F1F35);

    // Group accounts by category
    final assets = widget.accounts.where((a) => a['type'] == 'Asset').toList();
    final liabilities = widget.accounts.where((a) => a['type'] == 'Liability').toList();
    final equity = widget.accounts.where((a) => a['type'] == 'Equity').toList();
    final income = widget.accounts.where((a) => a['type'] == 'Income').toList();
    final expenses = widget.accounts.where((a) => a['type'] == 'Expense').toList();

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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => widget.onNavigate('dashboard'),
        ),
        title: Text(
          "Chart of Accounts",
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
      body: RefreshIndicator(
        onRefresh: () async => widget.onRefresh(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricTile("Total Assets", totalAssets, "+2.4%", const Color(0xFF10B981), primaryPurple, 1.0, cardColor, borderColor),
              const SizedBox(height: 16),
              _buildMetricTile("Total Liabilities", totalLiabilities, "-1.2%", const Color(0xFFF43F5E), accentPurple, totalAssets > 0 ? (totalLiabilities / totalAssets).clamp(0.0, 1.0) : 0.0, cardColor, borderColor),
              const SizedBox(height: 16),
              _buildMetricTile("Total Equity", totalEquity, "+5.1%", const Color(0xFF10B981), primaryPurple, totalAssets > 0 ? (totalEquity / totalAssets).clamp(0.0, 1.0) : 0.0, cardColor, borderColor),
              
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.layers, color: primaryPurple, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "Account Categories",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "${widget.accounts.length} total",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              _buildCategoryTile("Assets", "${assets.length} accounts", totalAssets, LucideIcons.briefcase, assets, cardColor, borderColor, primaryPurple),
              _buildCategoryTile("Liabilities", "${liabilities.length} accounts", totalLiabilities, LucideIcons.creditCard, liabilities, cardColor, borderColor, primaryPurple),
              _buildCategoryTile("Equity", "${equity.length} accounts", totalEquity, LucideIcons.pieChart, equity, cardColor, borderColor, primaryPurple),
              _buildCategoryTile("Income", "${income.length} accounts", widget.totalIncome, LucideIcons.trendingUp, income, cardColor, borderColor, primaryPurple),
              _buildCategoryTile("Expenses", "${expenses.length} accounts", widget.totalExpense, LucideIcons.trendingDown, expenses, cardColor, borderColor, primaryPurple),
              
              const SizedBox(height: 32),
              _buildGenerateReportCard(primaryPurple),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, double value, String trend, Color trendColor, Color barColor, double progress, Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
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
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(trend.startsWith('+') ? LucideIcons.trendingUp : LucideIcons.trendingDown, color: trendColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      trend,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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
            "₹${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFF1F1F35),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String title, String subtitle, double amount, IconData icon, List<dynamic> subAccounts, Color cardColor, Color borderColor, Color primaryPurple) {
    bool isExpanded = _expandedCategory == title;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategory = isExpanded ? null : title;
              });
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: primaryPurple, size: 22),
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
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${(amount.abs() / 1000).toStringAsFixed(1)}k",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, color: Colors.white.withOpacity(0.2), size: 18),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF1F1F35), height: 1),
            const SizedBox(height: 12),
            if (subAccounts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("No accounts in this category", style: TextStyle(color: Colors.white.withOpacity(0.2))),
              )
            else
              ...subAccounts.map((acc) => _buildSubCategoryItem(context, acc, "₹${(double.tryParse(acc['balance']?.toString() ?? '0') ?? 0).abs().toStringAsFixed(0)}")),
          ]
        ],
      ),
    );
  }

  Widget _buildSubCategoryItem(BuildContext context, Map<String, dynamic> account, String amount) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => EditAccountScreen(account: account)),
        );
        if (result == true) widget.onRefresh();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 150,
                  child: Text(
                    account['name'] ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  amount,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(LucideIcons.edit3, color: Colors.white.withOpacity(0.2), size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateReportCard(Color primaryPurple) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.fileText, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                "Account Audit",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Generate a professional PDF report of your current financial structure.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryPurple,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Export as PDF",
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 8),
                const Icon(LucideIcons.download, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
