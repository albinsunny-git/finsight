import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  // Replace Accounts AppBar
  var accountsStart = content.indexOf("} else if (currentTab == 'accounts') {");
  var accountsEnd =
      content.indexOf("} else if (currentTab == 'vouchers') {", accountsStart);

  if (accountsStart != -1 && accountsEnd != -1) {
    var accountsCode = "} else if (currentTab == 'accounts') {\n" "      appBarContent = Row(\n" "        mainAxisAlignment: MainAxisAlignment.spaceBetween,\n" "        children: [\n" +
        "          Text(\n" +
        "            'Accounts',\n" +
        "            style: GoogleFonts.plusJakartaSans(\n" +
        "              fontSize: 32,\n" +
        "              fontWeight: FontWeight.bold,\n" +
        "              color: isDark ? Colors.white : const Color(0xFF0F172A),\n" +
        "            ),\n" +
        "          ),\n" +
        "          Row(\n" +
        "            mainAxisSize: MainAxisSize.min,\n" +
        "            children: [\n" +
        "              const ThemeToggleButton(),\n" +
        "              TextButton(\n" +
        "                onPressed: () {},\n" +
        "                child: Text('Edit', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16)),\n" +
        "              )\n" +
        "            ],\n" +
        "          ),\n" +
        "        ],\n" +
        "      );\n    ";

    content = content.replaceRange(accountsStart, accountsEnd, accountsCode);
  }

  // Replace Vouchers AppBar
  var vouchersStart = content.indexOf("} else if (currentTab == 'vouchers') {");
  var vouchersEnd =
      content.indexOf("} else if (currentTab == 'reports') {", vouchersStart);

  if (vouchersStart != -1 && vouchersEnd != -1) {
    var vouchersCode = "} else if (currentTab == 'vouchers') {\n" "      appBarContent = Row(\n" "        mainAxisAlignment: MainAxisAlignment.spaceBetween,\n" "        children: [\n" +
        "          TextButton.icon(\n" +
        "            icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF2563EB), size: 28),\n" +
        "            label: Text(\"Back\", style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2563EB), fontSize: 16)),\n" +
        "            onPressed: () => setState(() => _selectedIndex = 0),\n" +
        "          ),\n" +
        "          Text(\n" +
        "            'Voucher Ledger',\n" +
        "            style: GoogleFonts.plusJakartaSans(\n" +
        "              fontSize: 18,\n" +
        "              fontWeight: FontWeight.bold,\n" +
        "              color: isDark ? Colors.white : Colors.black87,\n" +
        "            ),\n" +
        "          ),\n" +
        "          Row(\n" +
        "            mainAxisSize: MainAxisSize.min,\n" +
        "            children: [\n" +
        "              const ThemeToggleButton(),\n" +
        "              IconButton(\n" +
        "                icon: const Icon(LucideIcons.search, color: Color(0xFF2563EB), size: 24),\n" +
        "                onPressed: () {},\n" +
        "              )\n" +
        "            ],\n" +
        "          ),\n" +
        "        ],\n" +
        "      );\n    ";

    content = content.replaceRange(vouchersStart, vouchersEnd, vouchersCode);
  }

  file.writeAsStringSync(content);
  print("App Bars updated successfully.");
}
