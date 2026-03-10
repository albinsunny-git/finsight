import 'dart:io';

void main() {
  final file = File(
      r'c:\xampp\htdocs\finsight\mobile\lib\screens\dashboard_screen.dart');
  var content = file.readAsStringSync();

  // 1. Add _logout method if missing
  if (!content.contains('void _logout() async {')) {
    const logoutMethodCode = '''
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _updateNavigationForRole(String role) {''';
    content = content.replaceAll(
        '  void _updateNavigationForRole(String role) {', logoutMethodCode);
  }

  // 2. Desktop app bar (Top Right next to toggleTheme)
  const desktopAppBarSearch = '''
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Stack(children: [''';

  const desktopAppBarReplace = '''
                      IconButton(
                        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: () {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.logOut, color: Colors.redAccent),
                        onPressed: _logout,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Stack(children: [''';

  if (content.contains(desktopAppBarSearch)) {
    content = content.replaceFirst(desktopAppBarSearch, desktopAppBarReplace);
    print("Injected into Desktop App Bar");
  } else if (!content.contains('Icon(LucideIcons.logOut,')) {
    print("Warning: Could not find Desktop app bar anchor");
  }

  // 3. Profile Content Bottom Button
  const profileContentEndSearch = '''
        const SizedBox(height: 50), // pad for bottom nav
      ],
    ));
  }''';

  const profileContentEndReplace = '''
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(LucideIcons.logOut, size: 18, color: Colors.white),
            label: Text("Logout",
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              elevation: 0,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 50), // pad for bottom nav
      ],
    ));
  }''';

  // ensure we only replace it if it's not already there
  if (!content.contains('label: Text("Logout"')) {
    int idx = content.lastIndexOf(profileContentEndSearch);
    if (idx != -1) {
      content = content.replaceRange(
          idx, idx + profileContentEndSearch.length, profileContentEndReplace);
      print("Injected into Profile Content");
    } else {
      print("Warning: Could not find Profile content end anchor");
    }
  }

  // 4. Mobile layout App bar
  const mobileAppBarSearch = '''
          Row(
            children: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : LucideIcons.moon),
                onPressed: () => themeProvider.toggleTheme(),
                style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).cardTheme.color,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8)),
              ),
            ],
          ),
        ],
      );''';

  const mobileAppBarAlternateSearch = '''
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : LucideIcons.moon),
            onPressed: () => themeProvider.toggleTheme(),
            style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).cardTheme.color,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(8)),
          ),
        ],
      );''';

  const mobileAppBarReplace = '''
          Row(
            children: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : LucideIcons.moon),
                onPressed: () => themeProvider.toggleTheme(),
                style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).cardTheme.color,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8)),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(LucideIcons.logOut, color: Colors.redAccent),
                onPressed: _logout,
                style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withAlpha(25),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8)),
              ),
            ],
          ),
        ],
      );''';

  if (content.contains(mobileAppBarAlternateSearch)) {
    content =
        content.replaceFirst(mobileAppBarAlternateSearch, mobileAppBarReplace);
    print("Injected into Mobile App Bar (Alternate)");
  } else if (content.contains(mobileAppBarSearch)) {
    content = content.replaceFirst(mobileAppBarSearch, mobileAppBarReplace);
    print("Injected into Mobile App Bar");
  }

  file.writeAsStringSync(content);
  print('Done.');
}
