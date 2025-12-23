// =============================================================
// MESSAGE MODEL - Xabar modeli
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

class ChatModel {
  final String id;
  final String clientId;
  final String tailorId;
  final String clientName;
  final String tailorName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatModel({
    required this.id,
    required this.clientId,
    required this.tailorId,
    required this.clientName,
    required this.tailorName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      tailorId: data['tailorId'] ?? '',
      clientName: data['clientName'] ?? '',
      tailorName: data['tailorName'] ?? '',
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'tailorId': tailorId,
      'clientName': clientName,
      'tailorName': tailorName,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null 
          ? Timestamp.fromDate(lastMessageAt!) 
          : FieldValue.serverTimestamp(),
      'unreadCount': unreadCount,
    };
  }

  /// Chat ID generatsiya qilish (client va tailor ID laridan)
  static String generateChatId(String clientId, String tailorId) {
    // Tartibli ID yaratish uchun
    final ids = [clientId, tailorId]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
