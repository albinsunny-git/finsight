import 'dart:io';

void main() {
  var dir = Directory(r'c:\xampp\htdocs\finsight\mobile\lib');
  var files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  // Hex for ₹ is \u20B9
  var re = RegExp('\u20B9([a-zA-Z_]\\w*)');
  var reBrace = RegExp('\u20B9\\{');

  for (var file in files) {
    try {
      var content = file.readAsStringSync();
      var original = content;

      content = content.replaceAllMapped(re, (m) {
        return '\$${m.group(1)}';
      });

      content = content.replaceAll(reBrace, '\${');

      if (content != original) {
        print('Fixed interpolations in: ${file.path}');
        file.writeAsStringSync(content);
      }
    } catch (e) {
      print('Could not read ${file.path}: $e');
    }
  }
}
