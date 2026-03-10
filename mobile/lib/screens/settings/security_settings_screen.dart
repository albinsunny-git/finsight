import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool _twoFactorEnabled = false;
  bool _biometricsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(actions: const [ThemeToggleButton()], 
        title: Text("Security Settings",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Authentication",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(LucideIcons.key, color: theme.primaryColor),
                    title: Text("Change Password",
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text("Update your account password",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey, fontSize: 12)),
                    trailing: const Icon(LucideIcons.chevronRight,
                        size: 18, color: Colors.grey),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Password reset link sent to your email.")),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  SwitchListTile(
                    secondary: Icon(LucideIcons.shieldCheck,
                        color: theme.primaryColor),
                    title: Text("Two-Factor Authentication",
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text("Add an extra layer of security",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey, fontSize: 12)),
                    value: _twoFactorEnabled,
                    activeThumbColor: theme.primaryColor,
                    onChanged: (val) {
                      setState(() => _twoFactorEnabled = val);
                    },
                  ),
                  const Divider(height: 1, indent: 60),
                  SwitchListTile(
                    secondary: Icon(LucideIcons.fingerprint,
                        color: theme.primaryColor),
                    title: Text("Biometric Login",
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text("Use fingerprint or Face ID",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey, fontSize: 12)),
                    value: _biometricsEnabled,
                    activeThumbColor: theme.primaryColor,
                    onChanged: (val) {
                      setState(() => _biometricsEnabled = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text("Active Sessions",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(LucideIcons.monitor, color: Colors.green),
                    title: Text("MacBook Pro 16\"",
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text("Chrome - New York, USA",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey, fontSize: 12)),
                    trailing: Text("Current",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                  const Divider(height: 1, indent: 60),
                  ListTile(
                    leading:
                        const Icon(LucideIcons.smartphone, color: Colors.grey),
                    title: Text("iPhone 14 Pro",
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text("App - London, UK",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey, fontSize: 12)),
                    trailing: Text("Last active 2d ago",
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey, fontSize: 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}