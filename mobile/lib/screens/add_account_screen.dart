import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finsight_mobile/services/api_service.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');

  String _selectedType = 'Asset';
  final List<String> _types = [
    'Asset',
    'Liability',
    'Equity',
    'Income',
    'Expense'
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'code': _codeController.text,
      'name': _nameController.text,
      'description': _descController.text,
      'type': _selectedType,
      'sub_type': 'General', // Default for now
      'opening_balance': double.tryParse(_balanceController.text) ?? 0.0,
    };

    final result = await _apiService.createAccount(data);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully')));
        Navigator.pop(context, true); // Return true to refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to create')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgDark = Color(0xFF0F141A);
    const cardDark = Color(0xFF1C242F);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(actions: const [ThemeToggleButton()], 
        title: Text('New Account',
            style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        backgroundColor: bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Account Code', _codeController, true),
              const SizedBox(height: 16),
              _buildTextField('Account Name', _nameController, true),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                dropdownColor: cardDark,
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Account Type',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: cardDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              _buildTextField('Opening Balance', _balanceController, true,
                  isNumber: true),
              const SizedBox(height: 16),
              _buildTextField('Description', _descController, false,
                  maxLines: 3),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF168194),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Create Account',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool required,
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1C242F),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      validator: required
          ? (val) => val == null || val.isEmpty ? '$label is required' : null
          : null,
    );
  }
}
