// =============================================================
// CHAT SERVICE - Chat xizmati
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Chat yaratish yoki mavjudini olish
  Future<ChatModel> getOrCreateChat({
    required String clientId,
    required String tailorId,
    required String clientName,
    required String tailorName,
  }) async {
    final chatId = ChatModel.generateChatId(clientId, tailorId);
    final docRef = _firestore.collection('chats').doc(chatId);
    final doc = await docRef.get();

    if (doc.exists) {
      return ChatModel.fromFirestore(doc);
    }

    // Yangi chat yaratish
    final chat = ChatModel(
      id: chatId,
      clientId: clientId,
      tailorId: tailorId,
      clientName: clientName,
      tailorName: tailorName,
    );

    await docRef.set(chat.toFirestore());
    return chat;
  }

  /// Foydalanuvchi chatlari
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where(Filter.or(
          Filter('clientId', isEqualTo: userId),
          Filter('tailorId', isEqualTo: userId),
        ))
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  /// Chat xabarlari
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  /// Xabar yuborish
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final message = MessageModel(
      id: '',
      chatId: chatId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );

    // Xabarni qo'shish
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toFirestore());

    // Chat so'nggi xabarini yangilash
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  /// Xabarlarni o'qilgan deb belgilash
  Future<void> markMessagesAsRead(String chatId, String readerId) async {
    // Barcha o'qilmagan xabarlarni olish
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();

    // Faqat boshqa foydalanuvchidan kelgan xabarlarni filtrlash
    final unreadFromOthers = messages.docs.where((doc) {
      final data = doc.data();
      return data['senderId'] != readerId;
    }).toList();

    if (unreadFromOthers.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unreadFromOthers) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
