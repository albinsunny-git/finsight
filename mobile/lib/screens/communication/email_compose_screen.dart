import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EmailComposeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  const EmailComposeScreen({super.key, required this.userName, required this.userEmail});

  @override
  State<EmailComposeScreen> createState() => _EmailComposeScreenState();
}

class _EmailComposeScreenState extends State<EmailComposeScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _sendEmail() {
    // In a real app, this would use an email service or url_launcher with mailto
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email sent successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0D0D17);
    const Color primaryPurple = Color(0xFF8B5CF6);
    const Color cardColor = Color(0xFF161625);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Text("New Email", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.send, color: primaryPurple),
            onPressed: _sendEmail,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField("TO", widget.userEmail, readOnly: true),
            const SizedBox(height: 20),
            _buildField("SUBJECT", "", controller: _subjectController, hint: "Enter subject"),
            const SizedBox(height: 20),
            Text("MESSAGE", style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 1)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1F1F35)),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 10,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Write your message here...",
                  hintStyle: TextStyle(color: Colors.white12, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, {bool readOnly = false, TextEditingController? controller, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF161625),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1F1F35)),
          ),
          child: TextField(
            controller: controller ?? TextEditingController(text: value),
            readOnly: readOnly,
            style: TextStyle(color: readOnly ? Colors.white54 : Colors.white, fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white12, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
