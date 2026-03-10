import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  // Fix Profile navigation in Quick Actions
  var profileTapped = 'setState(() => _selectedIndex = 5);';
  var correctTapped =
      'setState(() => _selectedIndex = _currentPages.indexWhere((p) => p["id"] == "profile"));';
  content = content.replaceAll(profileTapped, correctTapped);

  // Fix View All navigation to Vouchers
  var vouchersTapped = 'setState(() => _selectedIndex = 3);';
  var correctVouchersTapped =
      'setState(() => _selectedIndex = _currentPages.indexWhere((p) => p["id"] == "vouchers"));';
  content = content.replaceAll(vouchersTapped, correctVouchersTapped);

  file.writeAsStringSync(content);
}
