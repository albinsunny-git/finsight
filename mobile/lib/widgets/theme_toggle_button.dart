import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final Color? color;
  const ThemeToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    return IconButton(
      icon: Icon(
        isDark ? LucideIcons.sun : LucideIcons.moon,
        color: color ?? (isDark ? Colors.white : Colors.black87),
      ),
      onPressed: () {
        themeProvider.toggleTheme();
      },
      tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
    );
  }
}

