
import 'dart:io';

void main() {
  var file = File(r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  // 1. Fix _selectedVoucherType and create _selectedAccountType
  content = content.replaceFirst(
    "final String _selectedVoucherType = \"All Types\";",
    "String _selectedVoucherType = \"All Entries\";\n  String _selectedAccountType = \"All Accounts\";"
  );
  
  // 2. Replace everything from // --- VOUCHERS PAGE --- to the end of the file
  var startIdx = content.indexOf("// --- VOUCHERS PAGE ---");
  if (startIdx == -1) {
    print("Could not find start index");
    return;
  }
  
  var newText = """// --- VOUCHERS PAGE ---
  Widget _buildVouchersContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredVouchers = _vouchers.where((v) {
      final matchesSearch = (v['voucher_number'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_voucherSearchQuery.toLowerCase()) ||
          (v['narration'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_voucherSearchQuery.toLowerCase());
      final voucherType = (v['voucher_type_name'] ?? '').toString();
      bool matchesType = _selectedVoucherType == "All Entries" || _selectedVoucherType == "All Types" ||
          voucherType.toLowerCase() == _selectedVoucherType.toLowerCase();
      // Notice: "All Entries" maps correctly if mapped.
      return matchesSearch && matchesType;
    }).toList();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ["All Entries", "Sales", "Purchase", "Payment"].map((f) {
                  bool sel = _selectedVoucherType == f || (_selectedVoucherType == "All Types" && f == "All Entries");
                  return GestureDetector(
                    onTap: () => setState(() => _selectedVoucherType = f == "All Entries" ? "All Types" : f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? const Color(0xFF1E88E5) : (isDark ? Colors.grey[800] : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? Colors.transparent : Colors.grey.withOpacity(0.2)),
                      ),
                      child: Text(f, style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : (isDark ? Colors.white70 : Colors.blueGrey[700]),
                      )),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(width: 60, child: Text("DATE", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                  Expanded(child: Text("PARTICULARS", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                  SizedBox(width: 80, child: Text("DEBIT", textAlign: TextAlign.right, style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                  SizedBox(width: 80, child: Text("CREDIT", textAlign: TextAlign.right, style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                ]
              )
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey.withOpacity(0.2), height: 1),
            Expanded(
              child: filteredVouchers.isEmpty ? Center(child: Text("No entries found.", style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.grey : Colors.grey[700]))) : ListView.separated(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: filteredVouchers.length,
                separatorBuilder: (c, i) => Divider(color: Colors.grey.withOpacity(0.1), height: 1),
                itemBuilder: (context, index) {
                  return _buildVoucherListItem(filteredVouchers[index], isDark);
                }
              )
            )
          ]
        ),
        Positioned(
          bottom: 16, right: 16,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF1E88E5),
            shape: const CircleBorder(),
            child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddVoucherScreen()));
              if (result == true) _loadUserData();
            }
          )
        )
      ]
    );
  }

  Widget _buildVoucherListItem(Map<String, dynamic> v, bool isDark) {
    final type = (v['voucher_type_name'] ?? 'Journal').toString().toLowerCase();
    
    Color typeColor = Colors.grey;
    Color typeBg = Colors.grey.withOpacity(0.1);
    if (type == 'payment') { typeColor = const Color(0xFF1E88E5); typeBg = const Color(0xFF1E88E5).withOpacity(0.1); }
    else if (type == 'sales') { typeColor = const Color(0xFF16A34A); typeBg = const Color(0xFF16A34A).withOpacity(0.1); }
    else if (type == 'purchase') { typeColor = const Color(0xFF9333EA); typeBg = const Color(0xFF9333EA).withOpacity(0.1); }
    else if (type == 'receipt') { typeColor = const Color(0xFFEA580C); typeBg = const Color(0xFFEA580C).withOpacity(0.1); }

    String dateStr = v['voucher_date'] ?? '';
    if (dateStr.isNotEmpty) {
      try { dateStr = DateFormat('MMM dd').format(DateTime.parse(dateStr)); } catch (_) {}
    }
    
    double dr = double.tryParse(v['total_debit']?.toString() ?? '0') ?? 0;
    double cr = double.tryParse(v['total_credit']?.toString() ?? '0') ?? 0;

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => VoucherDetailScreen(voucher: v, userRole: _userRole, currentUserId: _userId)));
        if (result == true) _loadUserData();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 60, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr, style: GoogleFonts.plusJakartaSans(color: isDark?Colors.white:Colors.black87, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(v['voucher_number'] ?? '#000', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11)),
              ]
            )),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor.withOpacity(0.5))),
                    child: Text(type.toUpperCase(), style: GoogleFonts.plusJakartaSans(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(v['account_name'] ?? 'Account', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: isDark?Colors.white:Colors.black87))),
                ]),
                const SizedBox(height: 4),
                Text(v['narration'] ?? 'Description', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
              ]
            )),
            SizedBox(width: 80, child: Text(dr > 0 ? dr.toStringAsFixed(2) : '—', textAlign: TextAlign.right, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: isDark?Colors.white:Colors.black87))),
            SizedBox(width: 80, child: Text(cr > 0 ? cr.toStringAsFixed(2) : '—', textAlign: TextAlign.right, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 14, color: isDark?Colors.white70:Colors.grey))),
          ]
        )
      )
    );
  }

  // --- ACCOUNTS PAGE ---
  Widget _buildAccountsContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    var filtered = _accounts.where((a) {
      if (_selectedAccountType != "All Accounts" && _selectedAccountType != "All") {
        String t = a['type']?.toString().toLowerCase() ?? '';
        if (_selectedAccountType.toLowerCase() == 'assets' && t != 'asset' && t != 'bank' && t != 'cash') return false;
        if (_selectedAccountType.toLowerCase() == 'liabilities' && t != 'liability') return false;
        if (_selectedAccountType.toLowerCase() == 'equity' && t != 'equity') return false;
        // else matching logic...
      }
      return (a['name']?.toString().toLowerCase().contains(_voucherSearchQuery.toLowerCase()) ?? false) ||
             (a['code']?.toString().toLowerCase().contains(_voucherSearchQuery.toLowerCase()) ?? false);
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (val) => setState(() => _voucherSearchQuery = val),
            decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                hintText: "Search by name or category",
                hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ["All Accounts", "Assets", "Liabilities", "Equity"].map((f) {
              bool sel = _selectedAccountType == f || (_selectedAccountType == "" && f == "All Accounts");
              return GestureDetector(
                onTap: () => setState(() => _selectedAccountType = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.transparent,
                    border: Border.all(color: sel ? Colors.transparent : Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(f, style: GoogleFonts.plusJakartaSans(
                    fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                    color: sel ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white70 : Colors.blueGrey[800]),
                  )),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ACCOUNT & CATEGORY", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              Text("BALANCE", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ]
          )
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey.withOpacity(0.2), height: 1),
        Expanded(
          child: filtered.isEmpty ? Center(child: Text("No accounts found.", style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.grey : Colors.grey[700]))) : ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: filtered.length,
            separatorBuilder: (c, i) => Divider(color: Colors.grey.withOpacity(0.1), height: 1),
            itemBuilder: (context, index) {
              var a = filtered[index];
              var b = double.tryParse(a['balance']?.toString() ?? '0') ?? 0;
              Color dotColor = const Color(0xFF16A34A);
              if (a['type'] == 'Liability') dotColor = const Color(0xFFEF4444);
              else if (a['type'] == 'Equity') dotColor = const Color(0xFF2563EB);
              else if (a['type'] == 'Expense') dotColor = Colors.orange;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['name'] ?? 'Account', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15, color: isDark?Colors.white:Colors.black87)),
                        Text("${a['type']} • ${a['sub_type'] ?? a['type']}", style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 13)),
                      ]
                    )),
                    Text("\$${b.toStringAsFixed(2)}", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: a['type'] == 'Liability' ? (isDark ? Colors.redAccent : const Color(0xFFEF4444)) : (isDark ? Colors.white : Colors.black87))),
                  ]
                )
              );
            },
          )
        ),
        Divider(color: Colors.grey.withOpacity(0.2), height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text("${filtered.length} ACCOUNTS FOUND", style: GoogleFonts.plusJakartaSans(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0))
        ),
      ]
    );
  }
}
""";

  content = content.substring(0, startIdx) + newText;
  file.writeAsStringSync(content);
  print("Tabs updated successfully.");
}

