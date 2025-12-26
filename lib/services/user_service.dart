// =============================================================
// USER SERVICE - Foydalanuvchi xizmati
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Foydalanuvchi ma'lumotlarini olish
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Foydalanuvchi ma'lumotlarini yangilash
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  /// Barcha chevarlarni olish
  Stream<List<UserModel>> getTailors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'tailor')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  /// Chevarlarni qidirish
  Future<List<UserModel>> searchTailors({
    String? query,
    double? minRating,
    String? address,
  }) async {
    Query<Map<String, dynamic>> ref = _firestore
        .collection('users')
        .where('role', isEqualTo: 'tailor');

    if (minRating != null) {
      ref = ref.where('rating', isGreaterThanOrEqualTo: minRating);
    }

    final snapshot = await ref.get();
    var tailors = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

    // Qidiruv filtrini qo'llash
    if (query != null && query.isNotEmpty) {
      tailors = tailors.where((t) =>
          t.name.toLowerCase().contains(query.toLowerCase()) ||
          (t.address?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }

    return tailors;
  }

  /// Chevar xizmatlarini olish
  Stream<List<ServiceModel>> getTailorServices(String tailorId) {
    return _firestore
        .collection('services')
        .where('tailorId', isEqualTo: tailorId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
  }

  /// Yangi xizmat qo'shish
  Future<String> addService(ServiceModel service) async {
    final doc = await _firestore.collection('services').add(service.toFirestore());
    return doc.id;
  }

  /// Xizmatni yangilash
  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    await _firestore.collection('services').doc(serviceId).update(data);
  }

  /// Xizmatni o'chirish
  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
  }

  /// Chevarga baho berish
  Future<void> rateTailor(String tailorId, double rating) async {
    final docRef = _firestore.collection('users').doc(tailorId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentRating = (data['rating'] ?? 0.0).toDouble();
      final ratingCount = (data['ratingCount'] ?? 0) + 1;
      final newRating = ((currentRating * (ratingCount - 1)) + rating) / ratingCount;

      transaction.update(docRef, {
        'rating': newRating,
        'ratingCount': ratingCount,
      });
    });
  }

  // ==================== FAVORITLAR ====================

  /// Sevimliga qo'shish
  Future<void> addToFavorites(String clientId, String tailorId) async {
    await _firestore
        .collection('users')
        .doc(clientId)
        .collection('favorites')
        .doc(tailorId)
        .set({
      'tailorId': tailorId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Sevimlilardan o'chirish
  Future<void> removeFromFavorites(String clientId, String tailorId) async {
    await _firestore
        .collection('users')
        .doc(clientId)
        .collection('favorites')
        .doc(tailorId)
        .delete();
  }

  /// Sevimli ekanligini tekshirish
  Stream<bool> isFavorite(String clientId, String tailorId) {
    return _firestore
        .collection('users')
        .doc(clientId)
        .collection('favorites')
        .doc(tailorId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Barcha sevimli chevarlarni olish
  Stream<List<UserModel>> getFavorites(String clientId) {
    return _firestore
        .collection('users')
        .doc(clientId)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final tailorIds = snapshot.docs.map((doc) => doc.id).toList();
      if (tailorIds.isEmpty) return <UserModel>[];

      final tailors = <UserModel>[];
      for (final id in tailorIds) {
        final user = await getUser(id);
        if (user != null) tailors.add(user);
      }
      return tailors;
    });
  }

  // ==================== KALENDAR ====================

  /// Band kunlarni olish
  Stream<List<DateTime>> getBusyDays(String tailorId) {
    return _firestore
        .collection('users')
        .doc(tailorId)
        .collection('busy_days')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final timestamp = doc.data()['date'] as Timestamp?;
              return timestamp?.toDate() ?? DateTime.now();
            }).toList());
  }

  /// Band kunni qo'shish
  Future<void> addBusyDay(String tailorId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final docId = '${dateOnly.year}-${dateOnly.month}-${dateOnly.day}';
    
    await _firestore
        .collection('users')
        .doc(tailorId)
        .collection('busy_days')
        .doc(docId)
        .set({
      'date': Timestamp.fromDate(dateOnly),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Band kunni o'chirish
  Future<void> removeBusyDay(String tailorId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final docId = '${dateOnly.year}-${dateOnly.month}-${dateOnly.day}';
    
    await _firestore
        .collection('users')
        .doc(tailorId)
        .collection('busy_days')
        .doc(docId)
        .delete();
  }

  /// Kun band ekanligini tekshirish
  Future<bool> isDayBusy(String tailorId, DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final docId = '${dateOnly.year}-${dateOnly.month}-${dateOnly.day}';
    
    final doc = await _firestore
        .collection('users')
        .doc(tailorId)
        .collection('busy_days')
        .doc(docId)
        .get();
    
    return doc.exists;
  }
}
