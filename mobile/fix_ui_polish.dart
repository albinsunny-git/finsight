import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add "Edit Profile" button to the top of profile content
  var profileStart = content.indexOf('Widget _buildProfileContent() {');
  var roleText = 'Text(_userRole,';
  var editProfileButton = '''
          Text(_userRole,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => ProfileEditScreen(userData: {'id': _userId, 'first_name': _userName, 'email': _email, 'role': _userRole})));
            },
            icon: const Icon(LucideIcons.user, size: 16, color: Colors.white),
            label: Text("Edit Profile", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
''';
  content = content.replaceFirst(roleText, editProfileButton);

  // 2. Reduce padding/whitespace in Dashboard
  content = content.replaceAll(
      'const SizedBox(height: 24)', 'const SizedBox(height: 12)');
  content = content.replaceAll(
      'const SizedBox(height: 32)', 'const SizedBox(height: 16)');
  content = content.replaceAll(
      'const SizedBox(height: 100)', 'const SizedBox(height: 50)');
  content = content.replaceAll(
      'padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 8)',
      'padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 4)');

  file.writeAsStringSync(content);
}
