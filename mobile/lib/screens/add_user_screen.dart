import 'package:flutter/material.dart';
import 'package:finsight_mobile/widgets/theme_toggle_button.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:finsight_mobile/services/api_service.dart';

class AddUserScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  const AddUserScreen({super.key, this.user});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;

  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'User';
  final List<String> _roles = [
    'Admin',
    'Manager',
    'Accountant',
    'User',
    'Viewer'
  ];

  String _selectedDept = 'General';

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _firstController.text = widget.user!['first_name'] ?? '';
      _lastController.text = widget.user!['last_name'] ?? '';
      _emailController.text = widget.user!['email'] ?? '';
      _usernameController.text = widget.user!['username'] ?? '';

      // Handle case-sensitivity issues for dropdowns
      String incomingRole = widget.user!['role'] ?? 'User';
      // Capitalize first letter to match _roles list ['Admin', 'Manager', ...]
      if (incomingRole.isNotEmpty) {
        incomingRole = incomingRole[0].toUpperCase() +
            incomingRole.substring(1).toLowerCase();
      }

      if (_roles.contains(incomingRole)) {
        _selectedRole = incomingRole;
      } else {
        _selectedRole = 'User';
      }

      _selectedDept = widget.user!['department'] ?? 'General';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'first_name': _firstController.text,
      'last_name': _lastController.text,
      'email': _emailController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'role': _selectedRole,
      'department': _selectedDept,
    };

    dynamic result;
    if (widget.user != null) {
      data['id'] = widget.user!['id'].toString();
      result = await _apiService.updateUser(data);
    } else {
      result = await _apiService.createUser(data);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(widget.user != null
                ? 'User updated successfully'
                : 'User created successfully')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to save')));
      }
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: Text(
            "Are you sure you want to delete ${widget.user!['first_name']}? This action cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final result =
          await _apiService.deleteUser(widget.user!['id'].toString());
      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User deleted successfully')));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result['message'] ?? 'Failed to delete user')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.user != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit User' : 'New User',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        actions: [const ThemeToggleButton(), 
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _isLoading ? null : _deleteUser,
              tooltip: "Delete User",
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Avatar Placeholder
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.person, size: 40, color: theme.primaryColor),
                ),
              ),
              const SizedBox(height: 32),

              Row(children: [
                Expanded(
                    child: _buildTextField(
                        'First Name', _firstController, true, theme)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField(
                        'Last Name', _lastController, true, theme)),
              ]),
              const SizedBox(height: 16),
              _buildTextField('Email', _emailController, true, theme,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Username', _usernameController, true, theme),
              const SizedBox(height: 16),
              _buildTextField(
                isEditing ? 'New Password (Optional)' : 'Password',
                _passwordController,
                !isEditing,
                theme,
                obscure: true,
              ),
              const SizedBox(height: 24),

              Text("Access Level & Role",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                dropdownColor: theme.cardTheme.color,
                style: GoogleFonts.plusJakartaSans(
                    color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  labelText: 'User Role',
                  prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.05),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: _roles
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(isEditing ? 'Save Changes' : 'Create User',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      bool required, ThemeData theme,
      {bool obscure = false, TextInputType? keyboardType}) {
    final isDark = theme.brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: required
          ? (val) => val == null || val.isEmpty ? '$label is required' : null
          : null,
    );
  }
}
