import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  var accountsStart = content.indexOf("// --- ACCOUNTS PAGE ---");
  if (accountsStart != -1) {
    var accountsEnd = content.indexOf(
        "  }", content.indexOf("Widget _buildAccountsContent() {"));

    // Look for return Column( inside AccountsContent
    var colStart = content.indexOf("return Column(", accountsStart);
    if (colStart != -1) {
      if (!content.substring(accountsStart).contains("return Stack(")) {
        content = content.replaceRange(
            colStart,
            colStart + "return Column(".length,
            "return Stack(\n      children: [\n        Column(");

        // Find the matching end of Column, which is just before the end of the method
        var lastBracket = content.lastIndexOf("  }\n}");
        if (lastBracket != -1) {
          var colEnd = content.lastIndexOf("    );\n  }", lastBracket);
          if (colEnd != -1 && colEnd > colStart) {
            content = content.replaceRange(
                colEnd,
                colEnd + "    );\n  }".length,
                "    ),\n" "        Positioned(\n" "          bottom: 16,\n" "          right: 16,\n" +
                    "          child: FloatingActionButton(\n" +
                    "            backgroundColor: const Color(0xFF1E88E5),\n" +
                    "            shape: const CircleBorder(),\n" +
                    "            child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),\n" +
                    "            onPressed: () async {\n" +
                    "              final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AddAccountScreen()));\n" +
                    "              if (result == true) _loadUserData();\n" +
                    "            }\n" +
                    "          )\n" +
                    "        )\n" +
                    "      ]\n" +
                    "    );\n  }");
            file.writeAsStringSync(content);
            print("Accounts FAB added successfully.");
            return;
          }
        }
      } else {
        print("Stack already exists.");
        return;
      }
    }
  }
  print("Failed to add FAB");
}
