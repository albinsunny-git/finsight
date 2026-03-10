import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\reports_home_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add CashFlow import and link it correctly
  if (!content.contains(
      'import \'package:finsight_mobile/screens/reports/cash_flow_screen.dart\';')) {
    content = content.replaceFirst(
        'import \'package:finsight_mobile/screens/reports/analytics_screen.dart\';',
        'import \'package:finsight_mobile/screens/reports/analytics_screen.dart\';\nimport \'package:finsight_mobile/screens/reports/cash_flow_screen.dart\';');
  }

  content = content.replaceFirst(
      '\'title\': \'Cash Flow\',\n        \'subtitle\': \'Inflows and outflows of cash over time\',\n        \'icon\': LucideIcons.banknote,\n        \'color\': Colors.purpleAccent,\n        \'route\': (context) => const AnalyticsScreen(),',
      '\'title\': \'Cash Flow\',\n        \'subtitle\': \'Cash inflows and outflows\',\n        \'icon\': LucideIcons.banknote,\n        \'color\': Colors.purpleAccent,\n        \'route\': (context) => const CashFlowScreen(),');

  // 2. Add Sort/Filter icon to AppBar (if AppBar is in build)
  // Wait, build() returns Scaffold. Let's add an appBar if it doesn't have one or update it.
  if (!content.contains('appBar:')) {
    content = content.replaceFirst('return Scaffold(',
        'return Scaffold(\n      appBar: AppBar(\n        title: Text("Reports", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),\n        backgroundColor: Colors.transparent,\n        elevation: 0,\n        actions: [\n          IconButton(icon: const Icon(LucideIcons.filter, size: 20), onPressed: () {}),\n          IconButton(icon: const Icon(LucideIcons.sortDesc, size: 20), onPressed: () {}),\n        ],\n      ),');
  }

  file.writeAsStringSync(content);
}
