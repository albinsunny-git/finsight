import 'dart:io';

void main() {
  var file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add import
  if (!content.contains('company_settings_screen.dart')) {
    content = content.replaceFirst(
        "import 'package:finsight_mobile/screens/notifications_screen.dart';",
        "import 'package:finsight_mobile/screens/notifications_screen.dart';\nimport 'package:finsight_mobile/screens/settings/company_settings_screen.dart';");
  }

  // 2. Fix Profile Content messy block
  // We want to replace from line 882 to 904 approximately (the garbage part)

  var startMarker = 'Text(_userRole,';
  var endMarker = '// Personal Information';

  var startIndex = content.indexOf(
      startMarker, content.indexOf('Widget _buildProfileContent()'));
  var endIndex = content.indexOf(endMarker);

  if (startIndex != -1 && endIndex != -1) {
    var newProfileButtons = '''Text(_userRole,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (c) => ProfileEditScreen(userData: {
                            'id': _userId,
                            'first_name': _userName,
                            'email': _email,
                            'role': _userRole
                          })));
            },
            icon: const Icon(LucideIcons.user, size: 16, color: Colors.white),
            label: Text("Edit Profile",
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),

          // Organization Settings
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Organization",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? theme.cardTheme.color : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: const Icon(LucideIcons.building,
                      color: Colors.orange, size: 20),
                ),
                title: Text("Company Details",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text("Update business profile and info",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.grey)),
                trailing: const Icon(LucideIcons.chevronRight,
                    size: 18, color: Colors.grey),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CompanySettingsScreen()));
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          ''';
    content = content.replaceRange(startIndex, endIndex, newProfileButtons);
  }

  file.writeAsStringSync(content);
}
