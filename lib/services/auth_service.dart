// =============================================================
// AUTH SERVICE - Autentifikatsiya xizmati
// =============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Hozirgi foydalanuvchi
  User? get currentUser => _auth.currentUser;

  /// Auth holati oqimi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Email va parol bilan ro'yxatdan o'tish
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    String? address,
    int? experienceYears,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        address: address,
        experienceYears: experienceYears,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    } catch (e) {
      throw 'Xatolik yuz berdi: $e';
    }
  }

  /// Email va parol bilan kirish
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) {
        final newUser = UserModel(
          id: credential.user!.uid,
          name: credential.user!.displayName ?? email.split('@').first,
          email: email,
          phone: '',
          role: UserRole.client,
          createdAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(newUser.id).set(newUser.toFirestore());
        return newUser;
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e.code);
    } catch (e) {
      throw 'Xatolik yuz berdi: $e';
    }
  }

  /// Chiqish
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Hozirgi foydalanuvchi ma'lumotlarini olish
  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Xato xabarlarini o'zbek tiliga tarjima qilish
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu email allaqachon ro\'yxatdan o\'tgan';
      case 'invalid-email':
        return 'Email formati noto\'g\'ri';
      case 'weak-password':
        return 'Parol juda oddiy';
      case 'user-not-found':
        return 'Bunday foydalanuvchi topilmadi';
      case 'wrong-password':
        return 'Parol noto\'g\'ri';
      case 'user-disabled':
        return 'Foydalanuvchi bloklangan';
      default:
        return 'Xatolik: $code';
    }
  }
}
