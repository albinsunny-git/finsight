import 'dart:io';

void main() {
  var dir = Directory(r'c:\xampp\htdocs\finsight\mobile\lib');
  var files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  var re = RegExp(r'₹([a-zA-Z_]\w*)');
  var reBrace = RegExp(r'₹\{');

  for (var file in files) {
    var content = file.readAsStringSync();
    var original = content;

    // Replace ₹var with $var
    // BUT only if it looks like it was meant to be an interpolation.
    // In this project, it's very likely they were all $ before.
    content = content.replaceAllMapped(re, (m) {
      return '\$${m.group(1)}';
    });

    // Replace ₹{ with ${
    content = content.replaceAll(reBrace, '\${');

    if (content != original) {
      print('Fixed interpolations in: ${file.path}');
      file.writeAsStringSync(content);
    }
  }
}
