
import 'dart:io';

void main() {
  var plPath = r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\profit_loss_screen.dart';
  var plFile = File(plPath);
  if (!plFile.existsSync()) return;

  var content = plFile.readAsStringSync();

  content = content.replaceAll(
      "color: netProfit >= 0\n                                                ? Colors.green[800]\n                                                : Colors.red[800]",
      "color: netProfit >= 0\n                                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.green[300] : Colors.green[800])\n                                                : (Theme.of(context).brightness == Brightness.dark ? Colors.red[300] : Colors.red[800])");

  content = content.replaceAll(
      "color: netProfit >= 0\n                                                ? Colors.green[900]\n                                                : Colors.red[900]",
      "color: netProfit >= 0\n                                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green[900])\n                                                : (Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red[900])");

  content = content.replaceAll(
      "color: Colors.red[700]",
      "color: Theme.of(context).brightness == Brightness.dark ? Colors.red[300] : Colors.red[700]");

  plFile.writeAsStringSync(content);
  print("Updated P&L screen");
}

