// =============================================================
// CHATS LIST SCREEN - Chatlar ro'yxati
// =============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/message_model.dart';
import '../../services/chat_service.dart';
import 'chat_screen.dart';

const Color primaryColor = Color(0xFFE91E63);

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return const Center(child: Text('Xatolik'));

    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Xabarlar', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: chatService.getUserChats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Hali xabarlar yo\'q',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chevar profilidan xabar yozing',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final isClient = chat.clientId == userId;
              final otherName = isClient ? chat.tailorName : chat.clientName;
              final otherId = isClient ? chat.tailorId : chat.clientId;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  chat.lastMessage ?? 'Xabar yo\'q',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: chat.lastMessageAt != null
                    ? Text(
                        _formatDate(chat.lastMessageAt!),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chat.id,
                        otherUserName: otherName,
                        otherUserId: otherId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}.${date.month}';
  }
}
