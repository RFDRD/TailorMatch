// =============================================================
// ORDER MODEL - Buyurtma modeli
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Buyurtma holati
enum OrderStatus {
  pending,           // Kutilmoqda
  meetingScheduled,  // Uchrashuv belgilandi
  inProgress,        // Ishlanmoqda
  fittingScheduled,  // Primerka belgilandi
  ready,             // Tayyor
  completed,         // Yakunlandi
  cancelled,         // Bekor qilindi
}

/// Buyurtma sanalar
class OrderDates {
  final DateTime? meeting;    // Uchrashuv sanasi
  final DateTime? fitting;    // Primerka sanasi
  final DateTime? ready;      // Tayyor bo'lish sanasi
  final DateTime? completed;  // Yakunlangan sana

  OrderDates({
    this.meeting,
    this.fitting,
    this.ready,
    this.completed,
  });

  factory OrderDates.fromMap(Map<String, dynamic>? data) {
    if (data == null) return OrderDates();
    return OrderDates(
      meeting: (data['meeting'] as Timestamp?)?.toDate(),
      fitting: (data['fitting'] as Timestamp?)?.toDate(),
      ready: (data['ready'] as Timestamp?)?.toDate(),
      completed: (data['completed'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (meeting != null) 'meeting': Timestamp.fromDate(meeting!),
      if (fitting != null) 'fitting': Timestamp.fromDate(fitting!),
      if (ready != null) 'ready': Timestamp.fromDate(ready!),
      if (completed != null) 'completed': Timestamp.fromDate(completed!),
    };
  }
}

/// Buyurtma modeli
class OrderModel {
  final String id;
  final String clientId;
  final String tailorId;
  final String serviceId;
  final String serviceName;
  final String? clientName;  // Mijoz ismi
  final String? tailorName;  // Chevar ismi
  final OrderStatus status;
  final OrderDates dates;
  final String? notes;
  final double? agreedPrice;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.tailorId,
    required this.serviceId,
    required this.serviceName,
    this.clientName,
    this.tailorName,
    required this.status,
    required this.dates,
    this.notes,
    this.agreedPrice,
    required this.createdAt,
  });

  /// Firestore'dan o'qish
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      clientId: data['clientId'] ?? '',
      tailorId: data['tailorId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      clientName: data['clientName'],
      tailorName: data['tailorName'],
      status: _parseStatus(data['status']),
      dates: OrderDates.fromMap(data['dates']),
      notes: data['notes'],
      agreedPrice: (data['agreedPrice'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Status ni parse qilish
  static OrderStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending': return OrderStatus.pending;
      case 'meeting_scheduled': return OrderStatus.meetingScheduled;
      case 'in_progress': return OrderStatus.inProgress;
      case 'fitting_scheduled': return OrderStatus.fittingScheduled;
      case 'ready': return OrderStatus.ready;
      case 'completed': return OrderStatus.completed;
      case 'cancelled': return OrderStatus.cancelled;
      default: return OrderStatus.pending;
    }
  }

  /// Status ni string ga
  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'pending';
      case OrderStatus.meetingScheduled: return 'meeting_scheduled';
      case OrderStatus.inProgress: return 'in_progress';
      case OrderStatus.fittingScheduled: return 'fitting_scheduled';
      case OrderStatus.ready: return 'ready';
      case OrderStatus.completed: return 'completed';
      case OrderStatus.cancelled: return 'cancelled';
    }
  }

  /// Firestore'ga yozish uchun Map
  Map<String, dynamic> toFirestore() {
    return {
      'clientId': clientId,
      'tailorId': tailorId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'clientName': clientName,
      'tailorName': tailorName,
      'status': _statusToString(status),
      'dates': dates.toMap(),
      'notes': notes,
      'agreedPrice': agreedPrice,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Status o'zbek tilida
  String get statusText {
    switch (status) {
      case OrderStatus.pending: return 'Kutilmoqda';
      case OrderStatus.meetingScheduled: return 'Uchrashuv belgilandi';
      case OrderStatus.inProgress: return 'Ishlanmoqda';
      case OrderStatus.fittingScheduled: return 'Primerka belgilandi';
      case OrderStatus.ready: return 'Tayyor';
      case OrderStatus.completed: return 'Yakunlandi';
      case OrderStatus.cancelled: return 'Bekor qilindi';
    }
  }

  /// Nusxa yaratish
  OrderModel copyWith({
    OrderStatus? status,
    OrderDates? dates,
    String? notes,
    double? agreedPrice,
  }) {
    return OrderModel(
      id: id,
      clientId: clientId,
      tailorId: tailorId,
      serviceId: serviceId,
      serviceName: serviceName,
      status: status ?? this.status,
      dates: dates ?? this.dates,
      notes: notes ?? this.notes,
      agreedPrice: agreedPrice ?? this.agreedPrice,
      createdAt: createdAt,
    );
  }
}
