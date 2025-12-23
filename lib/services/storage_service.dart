// =============================================================
// STORAGE SERVICE - Rasm saqlash xizmati
// =============================================================

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/portfolio_model.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  /// Galereyadan rasm tanlash
  Future<File?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// Kameradan rasm olish
  Future<File?> takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return null;
    return File(image.path);
  }

  /// Rasmni Firebase Storage'ga yuklash
  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  /// Avatar yuklash
  Future<String> uploadAvatar(String userId, File file) async {
    final path = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    return await uploadImage(file, path);
  }

  /// Portfolio rasmi yuklash
  Future<PortfolioImage?> uploadPortfolioImage({
    required String tailorId,
    required File file,
    String? caption,
  }) async {
    // Mavjud rasmlar sonini tekshirish
    final snapshot = await _firestore
        .collection('portfolios')
        .doc(tailorId)
        .collection('images')
        .get();

    if (snapshot.docs.length >= PortfolioModel.maxImages) {
      throw 'Portfolio to\'lgan! Maksimum ${PortfolioModel.maxImages} ta rasm';
    }

    // Rasmni yuklash
    final path = 'portfolios/$tailorId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final url = await uploadImage(file, path);

    // Firestore'ga saqlash
    final doc = await _firestore
        .collection('portfolios')
        .doc(tailorId)
        .collection('images')
        .add({
      'url': url,
      'caption': caption,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return PortfolioImage(
      id: doc.id,
      url: url,
      caption: caption,
      createdAt: DateTime.now(),
    );
  }

  /// Portfolio rasmlarini olish
  Stream<List<PortfolioImage>> getPortfolioImages(String tailorId) {
    return _firestore
        .collection('portfolios')
        .doc(tailorId)
        .collection('images')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PortfolioImage.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Portfolio rasmini o'chirish
  Future<void> deletePortfolioImage(String tailorId, String imageId, String url) async {
    // Firestore'dan o'chirish
    await _firestore
        .collection('portfolios')
        .doc(tailorId)
        .collection('images')
        .doc(imageId)
        .delete();

    // Storage'dan o'chirish
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      // Rasm allaqachon o'chirilgan bo'lishi mumkin
    }
  }
}
