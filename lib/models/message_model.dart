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
  final int clientUnreadCount;
  final int tailorUnreadCount;
  final List<String> participants; // Qidiruv uchun [clientId, tailorId]

  ChatModel({
    required this.id,
    required this.clientId,
    required this.tailorId,
    required this.clientName,
    required this.tailorName,
    this.lastMessage,
    this.lastMessageAt,
    this.clientUnreadCount = 0,
    this.tailorUnreadCount = 0,
    List<String>? participants,
  }) : participants = participants ?? [clientId, tailorId];

  // O'ziga tegishli unread countni olish uchun helper
  int getUnreadCount(String userId) {
    if (userId == clientId) return clientUnreadCount;
    if (userId == tailorId) return tailorUnreadCount;
    return 0;
  }
  
  // Backward compatibility uchun (eski kodlarni buzmaslik uchun)
  int get unreadCount => clientUnreadCount + tailorUnreadCount;

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final clientId = data['clientId'] ?? '';
    final tailorId = data['tailorId'] ?? '';
    
    // Eski unreadCount ni tekshirish
    final oldUnreadCount = data['unreadCount'] ?? 0;
    
    return ChatModel(
      id: doc.id,
      clientId: clientId,
      tailorId: tailorId,
      clientName: data['clientName'] ?? '',
      tailorName: data['tailorName'] ?? '',
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      clientUnreadCount: data['clientUnreadCount'] ?? 0,
      tailorUnreadCount: data['tailorUnreadCount'] ?? 0,
      participants: List<String>.from(data['participants'] ?? [clientId, tailorId]),
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
      'clientUnreadCount': clientUnreadCount,
      'tailorUnreadCount': tailorUnreadCount,
      'participants': participants,
    };
  }

  /// Chat ID generatsiya qilish (client va tailor ID laridan)
  static String generateChatId(String clientId, String tailorId) {
    // Tartibli ID yaratish uchun
    final ids = [clientId, tailorId]..sort();
    return '${ids[0]}_${ids[1]}';
  }
}
