import 'dart:io';

void replaceCurrencyInDir(Directory dir) {
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      var original = content;

      // Escape literal dollar signs first (\$)
      // We search for the literal character sequence '\$'
      content = content.replaceAll(r'\$', '₹');

      // Temporarily swap out interpolation delimiters to avoid accidental hits
      content = content.replaceAll(r'${', '___INTERPOLATION_START___');

      // Now replace the standalone '$' symbols (this usually captures what's in strings)
      // Some developers write "\$" or "($".
      // But in Dart most strings use '$' as special.
      // Let's replace common occurrences.
      content = content.replaceAll(r'"$', r'"₹');
      content = content.replaceAll(r"'$", r"'₹");
      content = content.replaceAll(r'($', r'(₹');
      content = content.replaceAll(r'-$', r'-₹');
      content = content.replaceAll(r'+$', r'+₹');
      content = content.replaceAll(r' $', r' ₹');

      // Finally, restore interpolation
      content = content.replaceAll('___INTERPOLATION_START___', r'${');

      if (content != original) {
        file.writeAsStringSync(content);
        print("Updated ${file.path}");
      }
    }
  }
}

void main() {
  replaceCurrencyInDir(Directory(r'C:\xampp\htdocs\finsight\mobile\lib'));
}
