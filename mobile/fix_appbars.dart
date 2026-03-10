
import 'dart:io';
void main() {
  var files= [
    r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\trial_balance_screen.dart',
    r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\profit_loss_screen.dart',
    r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\ledger_screen.dart',
    r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\balance_sheet_screen.dart',
    r'c:\xampp\htdocs\finsight\mobile\lib\screens\add_user_screen.dart',
    r'c:\xampp\htdocs\finsight\mobile\lib\screens\notifications_screen.dart',
    r'c:\xampp\htdocs\finsight\mobile\lib\screens\settings\company_settings_screen.dart',
  ];

  for (var file_path in files) {
    var file = File(file_path);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();
    
    var importStr = "import 'package:finsight_mobile/widgets/theme_toggle_button.dart';\n";
    if (!content.contains(importStr)) {
      content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n$importStr");
    }
    
    if (!content.contains("ThemeToggleButton")) {
        if (!content.contains("actions:")) {
            content = content.replaceFirst("appBar: AppBar(", "appBar: AppBar(actions: const [ThemeToggleButton()], ");
        } else if (content.contains("actions: const [")) {
            content = content.replaceFirst("actions: const [", "actions: const [ThemeToggleButton(), ");
        } else if (content.contains("actions: [")) {
            content = content.replaceFirst("actions: [", "actions: [const ThemeToggleButton(), ");
        }
    }

    file.writeAsStringSync(content);
  }
}

