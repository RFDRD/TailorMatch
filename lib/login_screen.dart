// =============================================================
// KIRISH EKRANI - LoginScreen
// =============================================================
// Bu ekran foydalanuvchilarni tizimga kirishini ta'minlaydi.
// Firebase Authentication orqali email va parol bilan kirish.
// =============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'home_screen.dart';

/// Kirish ekrani widget'i
/// StatefulWidget - chunki holatni boshqarish kerak (loading, xatolar)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ==================== O'ZGARUVCHILAR ====================
  
  /// Email kiritish uchun controller
  final _emailController = TextEditingController();
  
  /// Parol kiritish uchun controller  
  final _passwordController = TextEditingController();
  
  /// Form kaliti - validatsiya uchun
  final _formKey = GlobalKey<FormState>();
  
  /// Xato xabari (agar bo'lsa)
  String? _errorMessage;
  
  /// Yuklanayotgan holatini ko'rsatish
  bool _isLoading = false;
  
  /// Parolni ko'rsatish/yashirish
  bool _obscurePassword = true;

  // ==================== METODLAR ====================

  /// Tizimga kirish funksiyasi
  /// Firebase Authentication orqali email/parol bilan kirish
  Future<void> _signIn() async {
    // Form validatsiyasini tekshirish
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Firebase'ga ulanish
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Agar widget hali ham mavjud bo'lsa, Home ekraniga o'tish
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Firebase Auth xatolari
      setState(() {
        _errorMessage = _getUzbekErrorMessage(e.code);
      });
    } on FirebaseException catch (e) {
      // Firebase umumiy xatolari
      setState(() {
        _errorMessage = _getUzbekErrorMessage(e.code);
      });
    } catch (e) {
      // Boshqa xatolar
      setState(() {
        _errorMessage = 'Xatolik: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  /// Firebase xato kodlarini o'zbek tiliga tarjima qilish
  String _getUzbekErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bunday foydalanuvchi topilmadi';
      case 'wrong-password':
        return 'Parol noto\'g\'ri';
      case 'invalid-email':
        return 'Email formati noto\'g\'ri';
      case 'user-disabled':
        return 'Foydalanuvchi bloklangan';
      case 'too-many-requests':
        return 'Juda ko\'p urinish. Keyinroq qaytadan urining';
      case 'invalid-credential':
        return 'Email yoki parol noto\'g\'ri';
      default:
        return 'Xatolik yuz berdi: $code';
    }
  }

  // ==================== UI QISMI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient fon
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFCE4EC), // Och pushti
              Color(0xFFF8BBD0), // To'q pushti
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ===== LOGOTIP =====
                      const Icon(
                        Icons.checkroom,
                        size: 80,
                        color: Color(0xFFff00ae),
                      ),
                      const SizedBox(height: 16),
                      
                      // ===== SARLAVHA =====
                      const Text(
                        "Seamstress",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFff00ae),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // ===== SLOGAN =====
                      const Text(
                        "Chevarlar va mijozlar uchun",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // ===== EMAIL MAYDONI =====
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email, color: Color(0xFFff00ae)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        // Email validatsiyasi
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email kiritish shart';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'To\'g\'ri email kiriting';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // ===== PAROL MAYDONI =====
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Parol",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFFff00ae)),
                          // Parolni ko'rsatish/yashirish tugmasi
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        // Parol validatsiyasi
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Parol kiritish shart';
                          }
                          if (value.length < 6) {
                            return 'Parol kamida 6 ta belgi bo\'lishi kerak';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // ===== XATO XABARI =====
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      
                      // ===== KIRISH TUGMASI =====
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff00ae)),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFff00ae),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  "Kirish",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      
                      // ===== RO'YXATDAN O'TISH HAVOLASI =====
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Ro'yxatdan o'tish",
                          style: TextStyle(
                            color: Color(0xFFff00ae),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Resurslarni tozalash (xotira sızmasını oldini olish)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}