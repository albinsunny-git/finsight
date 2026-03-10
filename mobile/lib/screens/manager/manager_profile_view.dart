import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';

class ManagerProfileView extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<dynamic> vouchers;
  final int unreadNotificationsCount;
  final String? profileImagePath;
  final bool isDark;
  final VoidCallback onLogout;

  final VoidCallback onRefresh;

  const ManagerProfileView({
    super.key,
    required this.userData,
    required this.vouchers,
    required this.unreadNotificationsCount,
    this.profileImagePath,
    required this.isDark,
    required this.onLogout,
    required this.onRefresh,
  });

  @override
  State<ManagerProfileView> createState() => _ManagerProfileViewState();
}

class _ManagerProfileViewState extends State<ManagerProfileView> {
  double _approvalThreshold = 50000;
  bool _teamNotifications = true;
  final ApiService _apiService = ApiService();
  bool _isUploading = false;

  Future<void> _changeProfilePhoto() async {
    try {
      // Check Permissions
      if (Platform.isAndroid) {
        if (await Permission.photos.isDenied) {
          await Permission.photos.request();
        }
        if (await Permission.storage.isDenied) {
          await Permission.storage.request();
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
          source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Profile Photo',
                toolbarColor: const Color(0xFFFFC107),
                toolbarWidgetColor: Colors.black,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
            IOSUiSettings(title: 'Crop Profile Photo'),
          ],
        );

        if (croppedFile != null) {
          setState(() => _isUploading = true);

          final result = await _apiService.uploadProfileImage(croppedFile.path);

          setState(() => _isUploading = false);

          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile picture updated!"),
                backgroundColor: Colors.green,
              ),
            );
            widget.onRefresh();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Upload failed. Try again."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.isDark ? const Color(0xFF191813) : Colors.white;
    Color textColor = widget.isDark ? Colors.white : const Color(0xFF1A1D23);
    Color cardColor = widget.isDark ? const Color(0xFF2E2C23) : Colors.white;

    String userName = widget.userData['first_name'] ?? 'Manager';
    String roleStr = widget.userData['role'] ?? 'Manager';
    String idStr = widget.userData['id']?.toString() ?? '9921';

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Gold Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC107),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5), width: 4),
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: (widget.profileImagePath != null &&
                                      widget.profileImagePath!.isNotEmpty)
                                  ? (widget.profileImagePath!
                                              .startsWith('http') ||
                                          widget.profileImagePath!
                                              .startsWith('uploads/'))
                                      ? NetworkImage(widget.profileImagePath!
                                              .startsWith('http')
                                          ? widget.profileImagePath!
                                          : "${ApiService.baseUrl.replaceAll('/api', '')}/${widget.profileImagePath}")
                                      : FileImage(
                                              File(widget.profileImagePath!))
                                          as ImageProvider
                                  : const NetworkImage(
                                          "https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?ixlib=rb-1.2.1&auto=format&fit=crop&w=150&q=80")
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _changeProfilePhoto,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: _isUploading
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFFFC107)))
                                  : const Icon(LucideIcons.edit2,
                                      size: 14, color: Color(0xFFFFC107)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Senior $roleStr | Finsight HQ",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.briefcase,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            "MGR-$idStr",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            widget.vouchers.length.toString(),
                            "APPROVALS",
                            cardColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            widget.unreadNotificationsCount.toString(),
                            "ALERTS",
                            cardColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "15",
                            "TEAM",
                            cardColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Contact Information
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Contact Information",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.grey.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(LucideIcons.mail,
                                color: Color(0xFFFFC107), size: 20),
                            title: Text("Email",
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, color: Colors.grey)),
                            subtitle: Text(widget.userData['email'] ?? "N/A",
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                          ),
                          const Divider(height: 1, indent: 56),
                          ListTile(
                            leading: const Icon(LucideIcons.phone,
                                color: Color(0xFFFFC107), size: 20),
                            title: Text("Phone",
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, color: Colors.grey)),
                            subtitle: Text(widget.userData['phone'] ?? "N/A",
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Managerial Settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Managerial Settings",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFC107),
                          ),
                        ),
                        Text(
                          "Section 5/5",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.grey.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.banknote,
                                            color: Color(0xFFFFC107), size: 18),
                                        const SizedBox(width: 12),
                                        Text(
                                          "Approval Threshold",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "₹${_approvalThreshold.toInt().toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: const Color(0xFFFFC107),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: const Color(0xFFFFC107),
                                    inactiveTrackColor: Colors.grey[800],
                                    thumbColor: const Color(0xFFFFC107),
                                    overlayColor: const Color(0xFFFFC107)
                                        .withOpacity(0.2),
                                    trackHeight: 2,
                                  ),
                                  child: Slider(
                                    value: _approvalThreshold,
                                    min: 10000,
                                    max: 500000,
                                    divisions: 49,
                                    onChanged: (value) => setState(
                                        () => _approvalThreshold = value),
                                  ),
                                ),
                                Text(
                                  "Transactions above this limit require multi-factor verification.",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                              height: 1, color: Colors.grey.withOpacity(0.1)),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            leading: const Icon(LucideIcons.bell,
                                color: Color(0xFFFFC107), size: 20),
                            title: Text(
                              "Team Notifications",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            trailing: Switch(
                              value: _teamNotifications,
                              onChanged: (val) =>
                                  setState(() => _teamNotifications = val),
                              activeColor: const Color(0xFFFFC107),
                            ),
                          ),
                          Divider(
                              height: 1, color: Colors.grey.withOpacity(0.1)),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            leading: const Icon(LucideIcons.users,
                                color: Color(0xFFFFC107), size: 20),
                            title: Text(
                              "Direct Report Visibility",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            trailing: const Icon(LucideIcons.chevronRight,
                                size: 20, color: Colors.grey),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: widget.onLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        side: const BorderSide(color: Colors.redAccent),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.logOut, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            "Logout",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFFC107), // Yellow
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
