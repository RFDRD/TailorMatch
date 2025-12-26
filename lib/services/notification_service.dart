// =============================================================
// NOTIFICATION SERVICE - Bildirish tovushi xizmati
// =============================================================

import 'package:audioplayers/audioplayers.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;

  /// Bildirish tovushini yoqish/o'chirish
  bool get isSoundEnabled => _isSoundEnabled;
  set isSoundEnabled(bool value) => _isSoundEnabled = value;

  /// Yangi xabar tovushini ijro etish
  Future<void> playMessageSound() async {
    if (!_isSoundEnabled) return;

    try {
      // Standart tizim tovushi
      await _audioPlayer.play(
        AssetSource('sounds/message.mp3'),
        volume: 0.5,
      );
    } catch (e) {
      // Agar asset topilmasa, URL dan ijro etish
      try {
        await _audioPlayer.play(
          UrlSource('https://assets.mixkit.co/active_storage/sfx/2354/2354-preview.mp3'),
          volume: 0.5,
        );
      } catch (_) {
        // Tovush ijro etilmasa, xatolik chiqarmaylik
      }
    }
  }

  /// Yuborilgan xabar tovushi
  Future<void> playSentSound() async {
    if (!_isSoundEnabled) return;

    try {
      await _audioPlayer.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2356/2356-preview.mp3'),
        volume: 0.3,
      );
    } catch (_) {
      // Xatolik chiqarmaylik
    }
  }

  /// Xatolik tovushi
  Future<void> playErrorSound() async {
    if (!_isSoundEnabled) return;

    try {
      await _audioPlayer.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2955/2955-preview.mp3'),
        volume: 0.4,
      );
    } catch (_) {
      // Xatolik chiqarmaylik
    }
  }

  /// Resurslarni tozalash
  void dispose() {
    _audioPlayer.dispose();
  }
}
