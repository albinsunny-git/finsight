import 'dart:io';

void main() {
  // 1. Update AppTheme
  var themeFile =
      File(r'c:\xampp\htdocs\finsight\mobile\lib\theme\app_theme.dart');
  var themeContent = themeFile.readAsStringSync();

  if (!themeContent.contains('primaryOrange')) {
    themeContent = themeContent.replaceFirst(
        'static const Color accentNeon = Color(0xFF14B8A6); // Vibrant Teal',
        'static const Color accentNeon = Color(0xFF14B8A6); // Vibrant Teal\n\n  static const Color primaryOrange = Color(0xFFFF6B00);\n  static const Color primaryOrangeDeep = Color(0xFFE65100);\n  static const Color accentOrange = Color(0xFFFF9800);');
  }

  // Update lightTheme properties to use Orange
  themeContent = themeContent.replaceAll(
      'primaryColor: primaryBlue,', 'primaryColor: primaryOrange,');
  themeContent = themeContent.replaceAll('primaryColorDark: primaryBlueDeep,',
      'primaryColorDark: primaryOrangeDeep,');
  themeContent = themeContent.replaceFirst(
      'primary: primaryBlue,', 'primary: primaryOrange,');
  themeContent = themeContent.replaceFirst(
      'secondary: accentNeon,', 'secondary: accentOrange,');
  themeContent = themeContent.replaceFirst(
      'shadowColor: primaryBlue.withOpacity(0.08),',
      'shadowColor: primaryOrange.withOpacity(0.08),');
  themeContent = themeContent.replaceFirst(
      'selectedItemColor: primaryBlue,', 'selectedItemColor: primaryOrange,');

  themeFile.writeAsStringSync(themeContent);

  // 2. Update DashboardScreen
  var dashFile = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var dashContent = dashFile.readAsStringSync();

  // Add logout icon to appbar (Top Right beside toggle button)
  // Look for:
  /*
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                      ),
                      const SizedBox(width: 8),
  */
  if (!dashContent.contains('LucideIcons.logOut')) {
    var searchStr = '''
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                      ),
                      const SizedBox(width: 8),
''';
    var replacement = '''$searchStr                      IconButton(
                        icon: const Icon(LucideIcons.logOut, color: Colors.redAccent),
                        onPressed: _logout,
                      ),
                      const SizedBox(width: 8),
''';
    dashContent = dashContent.replaceFirst(searchStr, replacement);
  }

  // Add Logout button in profile section
  // It might be in _buildProfileContent or similar. For now, let's look for "CompanyDetails"
  var profileEndSearch = '''
                      _buildProfileOption(
                          context, LucideIcons.building, "Company Details",
                          isDark: isDark, onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CompanySettingsScreen()));
                      }),
                      const SizedBox(height: 16),
''';
  if (dashContent.contains('LucideIcons.building, "Company Details"')) {
    if (!dashContent.contains('LucideIcons.logOut, "Logout"')) {
      var profileReplacement = '''$profileEndSearch                      _buildProfileOption(
                          context, LucideIcons.logOut, "Logout",
                          isDark: isDark, isDestructive: true, onTap: _logout),
                      const SizedBox(height: 16),
''';
      dashContent =
          dashContent.replaceFirst(profileEndSearch, profileReplacement);
    }
  }

  // Update _buildProfileOption signature if isDestructive doesn't exist
  if (!dashContent.contains('bool isDestructive = false')) {
    var buildProfileOptionSearch = '''
  Widget _buildProfileOption(BuildContext context, IconData icon, String title,
      {required bool isDark, required VoidCallback onTap}) {
''';
    var buildProfileOptionReplacement = '''
  Widget _buildProfileOption(BuildContext context, IconData icon, String title,
      {required bool isDark, required VoidCallback onTap, bool isDestructive = false}) {
''';
    dashContent = dashContent.replaceFirst(
        buildProfileOptionSearch, buildProfileOptionReplacement);

    var colorSearch = 'color: isDark ? Colors.white : Colors.black87,';
    var colorReplacement =
        'color: isDestructive ? Colors.redAccent : (isDark ? Colors.white : Colors.black87),';
    // Replace only within _buildProfileOption method
    var splitContent = dashContent.split('Widget _buildProfileOption');
    if (splitContent.length > 1) {
      splitContent[1] =
          splitContent[1].replaceFirst(colorSearch, colorReplacement);
      var iconColorSearch = 'color: theme.primaryColor,';
      var iconColorReplacement =
          'color: isDestructive ? Colors.redAccent : theme.primaryColor,';
      splitContent[1] =
          splitContent[1].replaceFirst(iconColorSearch, iconColorReplacement);
      dashContent =
          '${splitContent[0]}Widget _buildProfileOption${splitContent[1]}';
    }
  }

  // Update _buildVoucherListItem to show Arrow with from/to
  String updatedVoucherItem = '''
  Widget _buildVoucherListItem(Map<String, dynamic> v, bool isDark) {
    final type = (v['voucher_type_name'] ?? 'Journal').toString().toLowerCase();

    Color typeColor = Colors.grey;
    Color typeBg = Colors.grey.withValues(alpha: 0.1);
    
    // In Flow vs Out Flow
    bool isInflow = false;
    bool isOutflow = false;
    
    if (type == 'payment') {
      typeColor = const Color(0xFFEF4444); // Red
      typeBg = const Color(0xFFEF4444).withValues(alpha: 0.1);
      isOutflow = true;
    } else if (type == 'sales') {
      typeColor = const Color(0xFF10B981); // Emerald
      typeBg = const Color(0xFF10B981).withValues(alpha: 0.1);
      isInflow = true;
    } else if (type == 'purchase') {
      typeColor = const Color(0xFFF59E0B); // Amber
      typeBg = const Color(0xFFF59E0B).withValues(alpha: 0.1);
      isOutflow = true;
    } else if (type == 'receipt') {
      typeColor = const Color(0xFF3B82F6); // Blue
      typeBg = const Color(0xFF3B82F6).withValues(alpha: 0.1);
      isInflow = true;
    }

    String dateStr = v['voucher_date'] ?? '';
    if (dateStr.isNotEmpty) {
      try {
        dateStr = DateFormat('MMM dd').format(DateTime.parse(dateStr));
      } catch (_) {}
    }

    double dr = double.tryParse(v['total_debit']?.toString() ?? '0') ?? 0;
    
    String fromAcc = v['from_account'] ?? 'Unknown';
    String toAcc = v['to_account'] ?? 'Unknown';

    return InkWell(
        onTap: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => VoucherDetailScreen(
                      voucher: v,
                      userRole: _userRole,
                      currentUserId: _userId)));
          if (result == true) _loadUserData();
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              // Date & Type
              SizedBox(
                  width: 60,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateStr,
                            style: GoogleFonts.plusJakartaSans(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: typeBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: typeColor.withValues(alpha: 0.3))),
                          child: Text(type.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                  color: typeColor,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ])),
              const SizedBox(width: 12),
              
              // Arrow and Accounts
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                      children: [
                         Expanded(
                           child: Text(fromAcc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: Colors.grey)),
                         ),
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 8),
                           child: Icon(LucideIcons.arrowRight, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                         ),
                         Expanded(
                           child: Text(toAcc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87)),
                         ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(v['narration'] ?? 'No description',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontStyle: FontStyle.italic)),
                  ])),
                  
              const SizedBox(width: 8),
              
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      "\$dr",
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isInflow ? Colors.green : (isOutflow ? Colors.red : (isDark ? Colors.white : Colors.black87)))
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isInflow) ...[
                        Icon(LucideIcons.arrowDownLeft, color: Colors.green, size: 12),
                        const SizedBox(width: 2),
                        Text("IN", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))
                      ] else if (isOutflow) ...[
                        Icon(LucideIcons.arrowUpRight, color: Colors.red, size: 12),
                        const SizedBox(width: 2),
                        Text("OUT", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))
                      ] else ...[
                        Text("TRANSFER", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))
                      ]
                    ]
                  )
                ]
              )
            ])));
  }
''';

  final regexVoucher = RegExp(
      r'Widget _buildVoucherListItem\(Map<String, dynamic> v, bool isDark\) \{.*?\}(?=\n\n  // --- ACCOUNTS PAGE ---)',
      dotAll: true);
  if (regexVoucher.hasMatch(dashContent)) {
    dashContent =
        dashContent.replaceFirst(regexVoucher, updatedVoucherItem.trim());
    // Re-fix ₹ if needed
    dashContent =
        dashContent.replaceAll('"\$dr"', '"₹\${dr.toStringAsFixed(2)}"');
  }

  dashFile.writeAsStringSync(dashContent);
}
