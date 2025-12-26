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
      // Agar participants maydoni yo'q bo'lsa, qo'shish
      final data = doc.data() as Map<String, dynamic>;
      if (data['participants'] == null) {
        await docRef.update({
          'participants': [clientId, tailorId],
        });
      }
      return ChatModel.fromFirestore(await docRef.get());
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
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
      // Client-side saralash - indeks talab qilinmaydi
      chats.sort((a, b) => (b.lastMessageAt ?? DateTime(2000)).compareTo(a.lastMessageAt ?? DateTime(2000)));
      return chats;
    });
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

    // Chatni yangilash
    final chatDocRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatDocRef.get();
    
    if (chatDoc.exists) {
      final data = chatDoc.data() as Map<String, dynamic>;
      final clientId = data['clientId'] as String;
      final tailorId = data['tailorId'] as String;
      
      print('DEBUG: sendMessage: senderId=$senderId, clientId=$clientId, tailorId=$tailorId');
      
      // Kimga yuborilayotganini aniqlash va unread countni oshirish
      final Map<String, dynamic> updates = {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      };
      
      if (senderId == clientId) {
        updates['tailorUnreadCount'] = FieldValue.increment(1);
      } else if (senderId == tailorId) {
        updates['clientUnreadCount'] = FieldValue.increment(1);
      }
      
      await chatDocRef.update(updates);
    }
  }

  /// Xabarlarni o'qilgan deb belgilash
  Future<void> markMessagesAsRead(String chatId, String readerId) async {
    // 1. Chatdagi o'qilmagan xabarlarni o'qilgan deb belgilash
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

    if (unreadFromOthers.isNotEmpty) {
      final batch = _firestore.batch();
      for (final doc in unreadFromOthers) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    }
    
    // 2. Chatdagi unread countni 0 ga tushirish
    final chatDocRef = _firestore.collection('chats').doc(chatId);
    final chatDoc = await chatDocRef.get();
    
    if (chatDoc.exists) {
      final data = chatDoc.data() as Map<String, dynamic>;
      final clientId = data['clientId'] as String;
      final tailorId = data['tailorId'] as String;
      
      final Map<String, dynamic> updates = {};
      
      if (readerId == clientId) {
        // Agar o'quvchi client bo'lsa, uning countini 0 qilamiz
        updates['clientUnreadCount'] = 0;
      } else if (readerId == tailorId) {
        // Agar o'quvchi tailor bo'lsa, uning countini 0 qilamiz
        updates['tailorUnreadCount'] = 0;
      }
      
      if (updates.isNotEmpty) {
        await chatDocRef.update(updates);
      }
    }
  }
}
