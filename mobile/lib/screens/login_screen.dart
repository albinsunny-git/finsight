import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'dashboard_screen.dart';

import 'package:lucide_icons/lucide_icons.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (canAuthenticate) {
        String? savedEmail = await _storage.read(key: 'saved_email');
        String? savedPassword = await _storage.read(key: 'saved_password');

        if (savedEmail != null &&
            savedPassword != null &&
            savedEmail.isNotEmpty) {
          bool authenticated = await _auth.authenticate(
            localizedReason: 'Scan fingerprint to login to FinSight',
            biometricOnly: true,
            persistAcrossBackgrounding: true,
          );

          if (authenticated && mounted) {
            setState(() {
              _emailController.text = savedEmail;
              _passwordController.text = savedPassword;
            });
            // Automatically log them in after a slight delay
            Future.delayed(
                const Duration(milliseconds: 300), () => _handleLogin());
          }
        }
      }
    } catch (e) {
      debugPrint('Biometric Error: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        // Save credentials securely for future biometric logins
        await _storage.write(key: 'saved_email', value: _emailController.text);
        await _storage.write(
            key: 'saved_password', value: _passwordController.text);

        // Navigate to Dashboard
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showSettingsDialog() {
    final ipController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the base URL for the API (without /api/...)'),
            const SizedBox(height: 10),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                hintText: 'e.g. http://192.168.1.5',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
                'Current Default: http://localhost/finsight (Web)\nhttp://10.0.2.2/finsight (Emulator)\nhttp://127.0.0.1:8080/finsight (USB Reverse Bridge)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _testConnection();
            },
            child: const Text('Test Connection'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ipController.text.isNotEmpty) {
                String url = ipController.text.trim();
                if (url.endsWith('/')) url = url.substring(0, url.length - 1);
                ApiService.setCustomUrl(url);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server URL set to: $url')),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() => _isLoading = true);
    final url = '${ApiService.baseUrl}/auth.php?action=login';
    try {
      print("Testing connection to: $url");
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (!mounted) return;

      _showDiagnosticDialog(
        title: 'Connection Successful',
        message:
            'Server reached at:\n$url\n\nStatus Code: ${response.statusCode}',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      String errorMsg = e.toString();
      String suggestion = "";

      if (errorMsg.contains("SocketException") ||
          errorMsg.contains("timed out")) {
        suggestion =
            "\n\nPOSSIBLE CAUSES:\n1. Backend URL is unreachable.\n2. PC and Phone are not on the same Wi-Fi.\n3. Windows Firewall is blocking Port 80.\n\nSOLUTION:\nUse the Settings icon to configure the correct IP address of your PC.";
      }

      _showDiagnosticDialog(
        title: 'Connection Failed',
        message:
            'Could not reach server at:\n$url\n\nError: $errorMsg$suggestion',
        isError: true,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDiagnosticDialog(
      {required String title, required String message, required bool isError}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: TextStyle(color: isError ? Colors.red : Colors.green)),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtextColor = isDark ? Colors.grey[400] : const Color(0xFF6B7280);
    const primaryColor = Color(0xFF1A73E8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimal Setting Icon
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.settings,
                        color: Colors.grey.withOpacity(0.4)),
                    onPressed: _showSettingsDialog,
                  ),
                ),

                // Icon Header
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark
                          ? primaryColor.withOpacity(0.2)
                          : const Color(0xFFE2F0FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.1, end: 0),
                const SizedBox(height: 24),

                // Titles
                Text(
                  'Account Vouchers',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 8),
                Text(
                  'Secure login to your accounting dashboard',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: subtextColor,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.1, end: 0),
                const SizedBox(height: 40),

                // Form Block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Address',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'name@company.com',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1E293B) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.transparent
                                  : Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.transparent
                                  : Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Password',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF1E293B) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.transparent
                                  : Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.transparent
                                  : Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Actions
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Login',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.plusJakartaSans(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.plusJakartaSans(
                        color: subtextColor,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Create an Account",
                        style: GoogleFonts.plusJakartaSans(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 48),

                // Secure Access Divider
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color:
                                isDark ? Colors.grey[800] : Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'SECURE ACCESS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color:
                                isDark ? Colors.grey[800] : Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),

                // Footer Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.lock, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 24),
                    Icon(LucideIcons.shieldCheck,
                        color: Colors.grey[400], size: 20),
                    const SizedBox(width: 24),
                    Icon(LucideIcons.cloud, color: Colors.grey[400], size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
