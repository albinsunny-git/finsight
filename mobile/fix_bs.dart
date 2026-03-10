
import 'dart:io';
void main() {
  var bs = File(r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\balance_sheet_screen.dart');
  if (bs.existsSync()) {
    var content = bs.readAsStringSync();
    content = content.replaceAll(
      "_buildSection(context, \"Assets\", assets,\n                                  totalAssets, Colors.green),",
      "_buildSection(context, \"Assets\", assets,\n                                  totalAssets, theme.brightness == Brightness.dark ? Colors.greenAccent : Colors.green),");
    content = content.replaceAll(
      "_buildSection(context, \"Liabilities\", liabilities,\n                                  totalLiabilities, Colors.red),",
      "_buildSection(context, \"Liabilities\", liabilities,\n                                  totalLiabilities, theme.brightness == Brightness.dark ? Colors.redAccent : Colors.red),");
    content = content.replaceAll(
      "_buildSection(context, \"Equity\", equity,\n                                  totalEquity, Colors.blue),",
      "_buildSection(context, \"Equity\", equity,\n                                  totalEquity, theme.brightness == Brightness.dark ? Colors.blueAccent : Colors.blue),");
      
    content = content.replaceAll(
      "_buildTotalRow(\"Total Assets\", totalAssets,\n                                        Colors.green),",
      "_buildTotalRow(\"Total Assets\", totalAssets,\n                                        theme.brightness == Brightness.dark ? Colors.greenAccent : Colors.green),");
    content = content.replaceAll(
      "_buildTotalRow(\n                                        \"Total Liab. + Equity\",\n                                        totalLiabilities + totalEquity,\n                                        Colors.blue),",
      "_buildTotalRow(\n                                        \"Total Liab. + Equity\",\n                                        totalLiabilities + totalEquity,\n                                        theme.brightness == Brightness.dark ? Colors.blueAccent : Colors.blue),");
    
    bs.writeAsStringSync(content);
    print("Fixed balance sheet");
  }
}

