import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  const ChatScreen({super.key, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "Hello! How can I help you today?", "isMe": false, "time": "10:00 AM"},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "text": _messageController.text.trim(),
        "isMe": true,
        "time": "10:05 AM",
      });
      _messageController.clear();
    });
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: primaryPurple.withOpacity(0.1),
              child: Text(widget.userName[0], style: const TextStyle(color: primaryPurple, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userName, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Online", style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF10B981), fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isMe'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg['isMe'] ? primaryPurple : cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(msg['isMe'] ? 16 : 0),
                        bottomRight: Radius.circular(msg['isMe'] ? 0 : 16),
                      ),
                      border: Border.all(color: msg['isMe'] ? primaryPurple : const Color(0xFF1F1F35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'],
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: GoogleFonts.plusJakartaSans(color: Colors.white.withOpacity(0.5), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: cardColor,
              border: Border(top: BorderSide(color: Color(0xFF1F1F35))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1F1F35)),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
