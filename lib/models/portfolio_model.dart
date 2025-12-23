// =============================================================
// PORTFOLIO MODEL - Portfolio modeli
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Portfolio rasmi
class PortfolioImage {
  final String id;
  final String url;
  final String? caption;
  final DateTime createdAt;

  PortfolioImage({
    required this.id,
    required this.url,
    this.caption,
    required this.createdAt,
  });

  factory PortfolioImage.fromMap(Map<String, dynamic> data, String id) {
    return PortfolioImage(
      id: id,
      url: data['url'] ?? '',
      caption: data['caption'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'caption': caption,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Portfolio modeli - Chevar uchun maksimum 10 ta rasm
class PortfolioModel {
  final String tailorId;
  final List<PortfolioImage> images;
  
  static const int maxImages = 10;

  PortfolioModel({
    required this.tailorId,
    required this.images,
  });

  /// Yangi rasm qo'shish mumkinmi
  bool get canAddImage => images.length < maxImages;

  /// Qolgan joy
  int get remainingSlots => maxImages - images.length;
}
