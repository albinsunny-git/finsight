import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:finsight_mobile/screens/settings/profile_edit_screen.dart';
import 'package:finsight_mobile/screens/manager/manager_access_logs_screen.dart';
import 'package:finsight_mobile/screens/settings/security_settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:finsight_mobile/providers/theme_provider.dart';

class ManagerProfileView extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<dynamic> vouchers;
  final int unreadNotificationsCount;
  final String? profileImagePath;
  final bool isDark;
  final VoidCallback onLogout;
  final VoidCallback onRefresh;
  final Function(String) onNavigate;

  const ManagerProfileView({
    super.key,
    required this.userData,
    required this.vouchers,
    required this.unreadNotificationsCount,
    this.profileImagePath,
    required this.isDark,
    required this.onLogout,
    required this.onRefresh,
    required this.onNavigate,
  });

  @override
  State<ManagerProfileView> createState() => _ManagerProfileViewState();
}

class _ManagerProfileViewState extends State<ManagerProfileView> {
  bool _approvalNotifs = true;
  bool _teamAlerts = false;

  Future<void> _changeProfilePhoto() async {
    try {
      if (Platform.isAndroid) {
        await Permission.photos.request();
        await Permission.storage.request();
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Profile Photo',
                toolbarColor: const Color(0xFF8B5CF6),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
          ],
        );

        if (croppedFile != null) {
          final ApiService apiService = ApiService();
          final result = await apiService.uploadProfileImage(croppedFile.path);

          if (result != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!"), backgroundColor: Colors.green));
              widget.onRefresh();
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFF0D0D17);
    final Color primaryPurple = const Color(0xFF8B5CF6);

    final String name = "${widget.userData['first_name'] ?? 'Alex'} ${widget.userData['last_name'] ?? ''}";
    final String role = widget.userData['role'] ?? "Senior Operations Manager";
    final String dept = widget.userData['department'] ?? "Management";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), 
          onPressed: () => widget.onNavigate('dashboard')
        ),
        title: Text(
          "Manager Profile",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, color: Colors.white), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SecuritySettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(primaryPurple, name, role, dept),
            const SizedBox(height: 32),
            _buildActionButtons(primaryPurple),
            const SizedBox(height: 32),
            _buildStatsRow(),
            const SizedBox(height: 32),
            _buildBioCard(),
            const SizedBox(height: 32),
            _buildPreferencesSection(primaryPurple),
            const SizedBox(height: 48),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Color primaryPurple, String name, String role, String dept) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            GestureDetector(
              onTap: _changeProfilePhoto,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryPurple, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: (widget.profileImagePath != null && widget.profileImagePath!.isNotEmpty)
                    ? NetworkImage(widget.profileImagePath!.startsWith('http') ? widget.profileImagePath! : "${ApiService.baseUrl.replaceAll('/api', '')}/${widget.profileImagePath}")
                    : const NetworkImage("https://i.pravatar.cc/150?u=alex"),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0D0D17), width: 3),
              ),
              child: const Icon(LucideIcons.check, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dept,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Color primaryPurple) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => ProfileEditScreen(userData: widget.userData)),
              );
              if (result == true) widget.onRefresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              "Edit Profile",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ManagerAccessLogsScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F1F35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              "Access Logs",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem("15", "Team Size"),
        _buildStatItem("1.2k", "Approvals"),
        _buildStatItem("98%", "KPI Score"),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildBioCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161625),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1F1F35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manager Bio",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Focused on optimizing operational efficiency and driving team performance through data-driven financial oversight.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(Color primaryPurple) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Preferences & Controls",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildPreferenceToggle("Approval Notifications", _approvalNotifs, (val) => setState(() => _approvalNotifs = val)),
        _buildPreferenceToggle("Team Activity Alerts", _teamAlerts, (val) => setState(() => _teamAlerts = val)),
        const SizedBox(height: 16),
        Text(
          "App Appearance",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildAppearanceChip(
              "Dark Amethyst", 
              context.watch<ThemeProvider>().isDarkMode, 
              primaryPurple,
              onTap: () {
                if (!context.read<ThemeProvider>().isDarkMode) {
                  context.read<ThemeProvider>().toggleTheme();
                }
              }
            ),
            const SizedBox(width: 12),
            _buildAppearanceChip(
              "Light Royal", 
              !context.watch<ThemeProvider>().isDarkMode, 
              primaryPurple,
              onTap: () {
                if (context.read<ThemeProvider>().isDarkMode) {
                  context.read<ThemeProvider>().toggleTheme();
                }
              }
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferenceToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[300],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF8B5CF6),
            activeTrackColor: const Color(0xFF8B5CF6).withOpacity(0.3),
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: const Color(0xFF1F1F35),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceChip(String label, bool isSelected, Color primaryPurple, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryPurple.withOpacity(0.1) : const Color(0xFF161625),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? primaryPurple : const Color(0xFF1F1F35)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: widget.onLogout,
      icon: const Icon(LucideIcons.logOut, size: 20),
      label: const Text("Logout Session"),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF43F5E).withOpacity(0.1),
        foregroundColor: const Color(0xFFF43F5E),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }
}
