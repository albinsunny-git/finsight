import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finsight_mobile/services/api_service.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final settings = await _apiService.getCompanySettings();
    if (settings.isNotEmpty) {
      _nameController.text = settings['company_name'] ?? '';
      _addressController.text = settings['address'] ?? '';
      _phoneController.text = settings['phone'] ?? '';
      _emailController.text = settings['email'] ?? '';
      _taxIdController.text = settings['tax_id'] ?? '';
      _gstController.text = settings['gst_number'] ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final success = await _apiService.updateCompanySettings({
      'company_name': _nameController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'tax_id': _taxIdController.text,
      'gst_number': _gstController.text,
    });

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Settings updated" : "Update failed"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Company Details",
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Basic Information", isDark),
                  const SizedBox(height: 16),
                  _buildTextField(_nameController, "Company Name",
                      LucideIcons.building, isDark),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _addressController, "Address", LucideIcons.mapPin, isDark,
                      maxLines: 3),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Contact Details", isDark),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _phoneController, "Phone", LucideIcons.phone, isDark),
                  const SizedBox(height: 16),
                  _buildTextField(
                      _emailController, "Email", LucideIcons.mail, isDark),
                  const SizedBox(height: 32),
                  _buildSectionHeader("Tax & Compliance", isDark),
                  const SizedBox(height: 16),
                  _buildTextField(_taxIdController, "Tax ID / PAN",
                      LucideIcons.fileText, isDark),
                  const SizedBox(height: 16),
                  _buildTextField(_gstController, "GST Number",
                      LucideIcons.shieldCheck, isDark),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Save Changes",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.grey[500],
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isDark,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B00), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
