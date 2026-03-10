import 'dart:io';

void main() async {
  var file = File(r'lib/screens/dashboard_screen.dart');
  var content = await file.readAsString();

  // We want to replace the dashboard tab appbar content block
  // First, let's replace the whole block inside _buildMobileLayout for currentTab == 'dashboard'
  
  String oldDashboardAppBar = '''    if (currentTab == 'dashboard') {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFDE6D2),
                backgroundImage:
                    _profileImagePath != null && _profileImagePath!.isNotEmpty
                        ? FileImage(File(_profileImagePath!))
                        : null,
                radius: 20,
                child: _profileImagePath == null || _profileImagePath!.isEmpty
                    ? const Icon(LucideIcons.user, color: Colors.orange)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    _userName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const ThemeToggleButton(),
              const SizedBox(width: 8),
              IconButton(
                icon: Stack(children: [
                  const Icon(LucideIcons.bell),
                  if (_unreadNotifCount > 0)
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle)))
                ]),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                  _loadUserData();
                },
                style: IconButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.grey[800] : const Color(0xFFF1F5F9),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8)),
              ),
            ],
          ),
        ],
      );
    }''';

  String newDashboardAppBar = '''    if (currentTab == 'dashboard') {
      appBarContent = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.wallet, color: isDark ? const Color(0xFF3B82F6) : Colors.blue[600], size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FY 2023-24',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Financial Overview',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.search, size: 20),
                onPressed: () {},
                style: IconButton.styleFrom(
                    backgroundColor:
                        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                    foregroundColor: isDark ? Colors.grey[400] : Colors.black87),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Stack(children: [
                  const Icon(LucideIcons.bell, size: 20),
                  if (_unreadNotifCount > 0)
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle)))
                ]),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsScreen()),
                  );
                  _loadUserData();
                },
                style: IconButton.styleFrom(
                    backgroundColor:
                        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                    foregroundColor: isDark ? Colors.grey[400] : Colors.black87),
              ),
              const SizedBox(width: 4),
              const ThemeToggleButton(color: Colors.grey),
            ],
          ),
        ],
      );
    }''';

  content = content.replaceFirst(oldDashboardAppBar, newDashboardAppBar);
  
  await file.writeAsString(content);
}

