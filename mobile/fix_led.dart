
import 'dart:io';
void main() {
  var bs = File(r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\ledger_screen.dart');
  if (bs.existsSync()) {
    var content = bs.readAsStringSync();
    
    // Replace in summary row usage
    content = content.replaceAll(
      "_buildSummaryRow(\"Period Debit\", dr, color: Colors.blue),",
      "_buildSummaryRow(\"Period Debit\", dr, color: Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : Colors.blue),");
    content = content.replaceAll(
      "_buildSummaryRow(\"Period Credit\", cr, color: Colors.red),",
      "_buildSummaryRow(\"Period Credit\", cr, color: Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red),");
      
    // Replace in list tile trailing
    content = content.replaceAll(
      "color: dr > 0 ? Colors.blue : Colors.red),",
      "color: dr > 0 ? (Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : Colors.blue) : (Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red)),");
    
    bs.writeAsStringSync(content);
    print("Fixed ledger");
  }
}

