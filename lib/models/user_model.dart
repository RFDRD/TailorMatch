// =============================================================
// USER MODEL - Foydalanuvchi modeli
// =============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

/// Foydalanuvchi roli
enum UserRole { client, tailor }

/// Foydalanuvchi modeli
class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? avatar;
  final String? address;
  final int? experienceYears;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.address,
    this.experienceYears,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
  });

  /// Firestore'dan o'qish
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] == 'tailor' ? UserRole.tailor : UserRole.client,
      avatar: data['avatar'],
      address: data['address'],
      experienceYears: data['experienceYears'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore'ga yozish uchun Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role == UserRole.tailor ? 'tailor' : 'client',
      'avatar': avatar,
      'address': address,
      'experienceYears': experienceYears,
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Nusxa yaratish
  UserModel copyWith({
    String? name,
    String? phone,
    String? avatar,
    String? address,
    int? experienceYears,
    double? rating,
    int? ratingCount,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      avatar: avatar ?? this.avatar,
      address: address ?? this.address,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt,
    );
  }

  /// Chevarmi?
  bool get isTailor => role == UserRole.tailor;

  /// Mijozmi?
  bool get isClient => role == UserRole.client;
}
