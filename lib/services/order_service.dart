// =============================================================
// ORDER SERVICE - Buyurtma xizmati
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Yangi buyurtma yaratish
  Future<String> createOrder({
    required String clientId,
    required String tailorId,
    required String serviceId,
    required String serviceName,
    String? notes,
  }) async {
    final order = {
      'clientId': clientId,
      'tailorId': tailorId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'status': 'pending',
      'dates': {},
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final doc = await _firestore.collection('orders').add(order);
    return doc.id;
  }

  /// Mijoz buyurtmalarini olish
  Stream<List<OrderModel>> getClientOrders(String clientId) {
    return _firestore
        .collection('orders')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  /// Chevar buyurtmalarini olish
  Stream<List<OrderModel>> getTailorOrders(String tailorId) {
    return _firestore
        .collection('orders')
        .where('tailorId', isEqualTo: tailorId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  /// Buyurtma holatini yangilash
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    String statusStr;
    switch (status) {
      case OrderStatus.pending: statusStr = 'pending'; break;
      case OrderStatus.meetingScheduled: statusStr = 'meeting_scheduled'; break;
      case OrderStatus.inProgress: statusStr = 'in_progress'; break;
      case OrderStatus.fittingScheduled: statusStr = 'fitting_scheduled'; break;
      case OrderStatus.ready: statusStr = 'ready'; break;
      case OrderStatus.completed: statusStr = 'completed'; break;
      case OrderStatus.cancelled: statusStr = 'cancelled'; break;
    }

    await _firestore.collection('orders').doc(orderId).update({
      'status': statusStr,
    });
  }

  /// Buyurtmani qabul qilish va uchrashuv sanasini belgilash
  Future<void> acceptOrder(String orderId, DateTime meetingDate) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'meeting_scheduled',
      'dates.meeting': Timestamp.fromDate(meetingDate),
    });
  }

  /// Ishni boshlash
  Future<void> startWork(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'in_progress',
    });
  }

  /// Primerka sanasini belgilash
  Future<void> scheduleFitting(String orderId, DateTime fittingDate) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'fitting_scheduled',
      'dates.fitting': Timestamp.fromDate(fittingDate),
    });
  }

  /// Tayyor deb belgilash
  Future<void> markAsReady(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'ready',
      'dates.ready': FieldValue.serverTimestamp(),
    });
  }

  /// Yakunlash
  Future<void> completeOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'completed',
      'dates.completed': FieldValue.serverTimestamp(),
    });
  }

  /// Bekor qilish
  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'cancelled',
    });
  }

  /// Narxni belgilash
  Future<void> setAgreedPrice(String orderId, double price) async {
    await _firestore.collection('orders').doc(orderId).update({
      'agreedPrice': price,
    });
  }
}
