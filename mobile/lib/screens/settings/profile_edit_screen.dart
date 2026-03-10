import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileEditScreen({super.key, required this.userData});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  String? _profileImagePath;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.userData['first_name'] ?? '');
    _lastNameController =
        TextEditingController(text: widget.userData['last_name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.userData['phone'] ?? '');
    _departmentController =
        TextEditingController(text: widget.userData['department'] ?? '');
    _userId = widget.userData['id']?.toString() ?? '';
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (widget.userData['profile_image'] != null &&
        widget.userData['profile_image'].toString().isNotEmpty) {
      if (mounted) {
        setState(() {
          _profileImagePath = widget.userData['profile_image'];
        });
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString('profile_image_path_$_userId');
      if (mounted && imagePath != null) {
        setState(() {
          _profileImagePath = imagePath;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      if (Platform.isAndroid) {
        final status = await Permission.photos.status;
        if (status.isDenied) {
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
                toolbarColor: const Color(0xFFFF6B00),
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
            IOSUiSettings(
              title: 'Crop Profile Photo',
            ),
          ],
        );

        if (croppedFile != null) {
          if (mounted) {
            setState(() {
              _isLoading = true;
            });
          }

          final uploadedPath =
              await _apiService.uploadProfileImage(croppedFile.path);

          if (mounted) {
            setState(() {
              _isLoading = false;
              if (uploadedPath != null) {
                _profileImagePath = uploadedPath;
                widget.userData['profile_image'] = uploadedPath;
              } else {
                _profileImagePath = croppedFile.path;
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(uploadedPath != null
                      ? 'Profile photo updated and saved'
                      : 'Photo cropped but upload failed')),
            );

            if (uploadedPath != null) {
              final prefs = await SharedPreferences.getInstance();
              final userDataString = prefs.getString('user_data');
              if (userDataString != null) {
                final userData = jsonDecode(userDataString);
                userData['profile_image'] = uploadedPath;
                await prefs.setString('user_data', jsonEncode(userData));
              }
            } else {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(
                  'profile_image_path_$_userId', croppedFile.path);
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error picking/cropping: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final profileData = {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'phone': _phoneController.text,
          'department': _departmentController.text,
        };

        final success = await _apiService.updateProfile(profileData);

        if (success && mounted) {
          // Update local storage
          final prefs = await SharedPreferences.getInstance();
          final userData = Map<String, dynamic>.from(widget.userData);
          userData.addAll(profileData);
          await prefs.setString('user_data', jsonEncode(userData));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, true); // Return true to indicate update
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        title: Text('Edit Profile', style: GoogleFonts.plusJakartaSans()),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                theme.primaryColor.withOpacity(0.1),
                            backgroundImage: _profileImagePath != null &&
                                    _profileImagePath!.isNotEmpty
                                ? (_profileImagePath!.startsWith('http') ||
                                        _profileImagePath!
                                            .startsWith('uploads/'))
                                    ? NetworkImage(_profileImagePath!
                                                .startsWith('http')
                                            ? _profileImagePath!
                                            : "${ApiService.baseUrl.replaceAll('/api', '')}/$_profileImagePath")
                                        as ImageProvider
                                    : FileImage(File(_profileImagePath!))
                                : null,
                            child: _profileImagePath == null ||
                                    _profileImagePath!.isEmpty
                                ? Text(
                                    widget.userData['first_name'] != null &&
                                            widget.userData['first_name']
                                                .toString()
                                                .isNotEmpty
                                        ? widget.userData['first_name'][0]
                                            .toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.plusJakartaSans(
                                        color: theme.primaryColor,
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold))
                                : null,
                          ),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 2),
                              ),
                              child: const Icon(LucideIcons.camera,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _departmentController,
                      label: 'Department',
                      icon: Icons.work_outline,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
