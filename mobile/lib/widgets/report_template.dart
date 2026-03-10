import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class ReportTemplate extends StatelessWidget {
  final String title;
  final String dateText;
  final Widget child;

  const ReportTemplate({
    super.key,
    required this.title,
    required this.dateText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Company Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
                bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
          ),
          child: Column(
            children: [
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(LucideIcons.landmark,
                      color: theme.primaryColor, size: 30),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                settings.companyName.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                settings.companyTagline,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, indent: 40, endIndent: 40),
            ],
          ),
        ),

        // Report Title & Date
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          color: isDark
              ? Colors.blueGrey[900]!.withOpacity(0.2)
              : Colors.blue[50]!.withOpacity(0.5),
          child: Column(
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.calendar, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    dateText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Content
        child,

        // Footer
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Center(
            child: Text(
              "Generated via FinSight Mobile",
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 10, color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }
}
