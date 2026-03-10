
import 'dart:io';
void main() {
  var file = File(r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\analytics_screen.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    
    content = content.replaceAll(
      "color: Colors.green,",
      "color: theme.brightness == Brightness.dark ? Colors.greenAccent : Colors.green,");
    content = content.replaceAll(
      "color: Colors.red,",
      "color: theme.brightness == Brightness.dark ? Colors.redAccent : Colors.red,");
    
    file.writeAsStringSync(content);
    print("Fixed analytics");
  }
}

