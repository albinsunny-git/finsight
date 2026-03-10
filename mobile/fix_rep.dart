
import 'dart:io';
void main() {
  var file = File(r'c:\xampp\htdocs\finsight\mobile\lib\screens\reports\reports_home_screen.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    
    content = content.replaceAll(
      "'color': Colors.green,",
      "'color': isDark ? Colors.greenAccent : Colors.green,");
    content = content.replaceAll(
      "'color': Colors.blue,",
      "'color': isDark ? Colors.blueAccent : Colors.blue,");
    content = content.replaceAll(
      "'color': Colors.deepOrange,",
      "'color': isDark ? Colors.deepOrangeAccent : Colors.deepOrange,");
    content = content.replaceAll(
      "'color': Colors.red,",
      "'color': isDark ? Colors.redAccent : Colors.red,");
    content = content.replaceAll(
      "'color': Colors.indigo,",
      "'color': isDark ? Colors.indigoAccent : Colors.indigo,");
    
    file.writeAsStringSync(content);
    print("Fixed reports home");
  }
}

