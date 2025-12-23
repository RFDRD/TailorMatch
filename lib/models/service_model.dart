// =============================================================
// SERVICE MODEL - Xizmat modeli
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Xizmat modeli - Chevar tomonidan taqdim etiladigan xizmatlar
class ServiceModel {
  final String id;
  final String tailorId;
  final String type; // Ko'ylak, Kostyum, Shim, etc.
  final double minPrice;
  final double maxPrice;
  final String avgTime; // "5 kun", "1 hafta", etc.
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.tailorId,
    required this.type,
    required this.minPrice,
    required this.maxPrice,
    required this.avgTime,
    this.description,
    this.isActive = true,
    required this.createdAt,
  });

  /// Firestore'dan o'qish
  factory ServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      tailorId: data['tailorId'] ?? '',
      type: data['type'] ?? '',
      minPrice: (data['minPrice'] ?? 0.0).toDouble(),
      maxPrice: (data['maxPrice'] ?? 0.0).toDouble(),
      avgTime: data['avgTime'] ?? '',
      description: data['description'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore'ga yozish uchun Map
  Map<String, dynamic> toFirestore() {
    return {
      'tailorId': tailorId,
      'type': type,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'avgTime': avgTime,
      'description': description,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Narx diapazoni
  String get priceRange => '${minPrice.toInt()} - ${maxPrice.toInt()} so\'m';

  /// Nusxa yaratish
  ServiceModel copyWith({
    String? type,
    double? minPrice,
    double? maxPrice,
    String? avgTime,
    String? description,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id,
      tailorId: tailorId,
      type: type ?? this.type,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      avgTime: avgTime ?? this.avgTime,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
