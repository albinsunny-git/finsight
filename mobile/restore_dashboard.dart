import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  var dashboardCode = r'''
  Widget _buildDashboardContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double safeRevenue =
        (double.tryParse(_stats['revenue']?.toString() ?? '0') ?? 0);
    double safeExpense =
        (double.tryParse(_stats['expenses']?.toString() ?? '0') ?? 0);
    double balance = safeRevenue - safeExpense;

    return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Balance",
                          style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70, fontSize: 13)),
                      const Icon(LucideIcons.landmark, color: Colors.white70, size: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${balance.toStringAsFixed(2)}",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Income", style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11)),
                            Text("₹${safeRevenue.toStringAsFixed(2)}", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: Colors.white24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Expense", style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11)),
                            Text("₹${safeExpense.toStringAsFixed(2)}", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text("Financial Trends",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (safeRevenue > safeExpense ? safeRevenue : safeExpense) * 1.2 + 100,
                  barGroups: [
                    _makeGroupData(0, safeRevenue * 0.7, safeExpense * 0.5, isDark),
                    _makeGroupData(1, safeRevenue * 0.8, safeExpense * 0.6, isDark),
                    _makeGroupData(2, safeRevenue, safeExpense, isDark),
                    _makeGroupData(3, safeRevenue * 0.9, safeExpense * 0.4, isDark),
                    _makeGroupData(4, safeRevenue * 1.1, safeExpense * 0.8, isDark),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                          if (value.toInt() >= days.length) return const SizedBox();
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.grey));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text("Quick Actions",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildQuickActionCard("New Voucher", LucideIcons.scrollText, const Color(0xFF2563EB), const Color(0xFFDBEAFE), () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const AddVoucherScreen()));
                }),
                _buildQuickActionCard("Add Account", LucideIcons.folderPlus, const Color(0xFF16A34A), const Color(0xFFDCFCE7), () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const AddAccountScreen()));
                }),
                _buildQuickActionCard("View Reports", LucideIcons.barChartBig, const Color(0xFF9333EA), const Color(0xFFF3E8FF), () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => const ReportsHomeScreen()));
                }),
                _buildQuickActionCard("My Profile", LucideIcons.userCircle, const Color(0xFFEAB308), const Color(0xFFFEF9C3), () {
                  setState(() => _selectedIndex = 5); // Switch to profile tab
                }),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Transactions",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 3), // Vouchers tab
                  child: Text("View All",
                      style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            if (_vouchers.isEmpty)
              _buildEmptyState("No Activity", "You have no transactions", LucideIcons.history)
            else
              ..._vouchers.take(3).map((v) {
                final type = v['voucher_type_name']?.toString().toLowerCase() ?? 'general';
                final amt = double.tryParse(v['total_debit']?.toString() ?? '0') ?? 0;
                return _buildRecentTransactionItem(
                  v['narration'] ?? 'Transaction',
                  "${v['voucher_date']} • ${v['account_name']}",
                  "${type == 'payment' ? '-' : '+'}₹${amt.toStringAsFixed(2)}",
                  type == 'payment' ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
                  type.toUpperCase(),
                  type == 'payment' ? Colors.redAccent : Colors.greenAccent,
                  isDark
                );
              }),
          ],
        ));
  }
''';

  // Find the place to insert it (before _buildUsersContent)
  var insertionPoint = content.indexOf('  Widget _buildUsersContent() {');
  if (insertionPoint != -1) {
    content =
        content.replaceRange(insertionPoint, insertionPoint, dashboardCode);
  }

  file.writeAsStringSync(content);
}
