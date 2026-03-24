import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:finsight_mobile/services/api_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  bool _isLoading = true;
  List<dynamic> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      final response = await api.get("\${ApiService.baseUrl}/reports.php?type=audit-logs");

      print("Audit Logs code: \${response.statusCode}");
      print("Audit Logs body: \${response.body}");

      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        setState(() => _logs = json['data'] ?? []);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(json['message'] ?? "Failed to load logs"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("Logs Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("System Audit Logs",
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
          : _logs.isEmpty
              ? Center(
                  child: Text("No audit logs found.",
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final action = log['action'].toString().replaceAll('_', ' ');
                      final date = log['created_at'] != null ? DateTime.tryParse(log['created_at']) : null;
                      final fDate = date != null ? "\${date.day}/\${date.month}/\${date.year} \${date.hour.toString().padLeft(2, '0')}:\${date.minute.toString().padLeft(2, '0')}" : "Unknown";

                      Color actionColor = Colors.grey;
                      IconData actionIcon = LucideIcons.activity;

                      if (action.contains('CREATED') || action.contains('POSTED')) {
                        actionColor = const Color(0xFF38A169);
                        actionIcon = LucideIcons.checkCircle;
                      } else if (action.contains('REJECTED') || action.contains('DELETED')) {
                        actionColor = const Color(0xFFE53E3E);
                        actionIcon = LucideIcons.xCircle;
                      } else if (action.contains('SUBMITTED') || action.contains('UPDATE')) {
                        actionColor = const Color(0xFFD69E2E);
                        actionIcon = LucideIcons.clock;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A1429) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: actionColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(actionIcon, color: actionColor, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    action,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "User: \${log['first_name'] ?? ''} \${log['last_name'] ?? ''}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Reference: \${log['voucher_number'] ?? log['entity_id']}",
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              fDate,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
