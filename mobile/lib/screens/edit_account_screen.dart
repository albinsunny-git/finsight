import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsight_mobile/services/api_service.dart';

class EditAccountScreen extends StatefulWidget {
  final Map<String, dynamic> account;
  const EditAccountScreen({super.key, required this.account});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _balanceController;

  String _selectedType = 'Asset';
  final List<String> _types = [
    'Asset',
    'Liability',
    'Equity',
    'Income',
    'Expense'
  ];

  @override
  void initState() {
    super.initState();
    _codeController =
        TextEditingController(text: widget.account['code']?.toString() ?? '');
    _nameController =
        TextEditingController(text: widget.account['name']?.toString() ?? '');
    _descController = TextEditingController(
        text: widget.account['description']?.toString() ?? '');
    _balanceController = TextEditingController(
        text: widget.account['balance']?.toString() ?? '0.00');
    _selectedType = widget.account['type'] ?? 'Asset';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'account_id': widget.account['id'],
      'code': _codeController.text,
      'name': _nameController.text,
      'description': _descController.text,
      'type': _selectedType,
      'opening_balance': double.tryParse(_balanceController.text) ?? 0.0,
    };

    final result = await _apiService.updateAccount(data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account updated successfully')));
        Navigator.pop(context, true); // Return true to refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to update')));
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete this account? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final result = await _apiService
          .deleteAccount(int.tryParse(widget.account['id'].toString()) ?? 0);
      setState(() => _isLoading = false);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Account deleted')));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Failed to delete')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        actions: const [ThemeToggleButton()],
        title: Text('Edit Account',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Account Code', _codeController, true, isDark),
              const SizedBox(height: 16),
              _buildTextField('Account Name', _nameController, true, isDark),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                style: GoogleFonts.plusJakartaSans(
                    color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                  'Opening Balance', _balanceController, true, isDark,
                  isNumber: true),
              const SizedBox(height: 16),
              _buildTextField('Description', _descController, false, isDark,
                  maxLines: 3),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Update Account',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _isLoading ? null : _deleteAccount,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: Text('Delete Account',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      bool required, bool isDark,
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
      validator: required
          ? (val) => val == null || val.isEmpty ? '$label is required' : null
          : null,
    );
  }
}
