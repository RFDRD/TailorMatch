// =============================================================
// RO'YXATDAN O'TISH EKRANI - RegisterScreen
// =============================================================
// Bu ekran yangi foydalanuvchilarni ro'yxatdan o'tkazadi.
// Firebase Authentication + Firestore bilan ishlaydi.
// Foydalanuvchi Mijoz yoki Chevar sifatida ro'yxatdan o'tishi mumkin.
// =============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

/// Ro'yxatdan o'tish ekrani widget'i
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ==================== O'ZGARUVCHILAR ====================
  
  /// Email kiritish uchun controller
  final _emailController = TextEditingController();
  
  /// Parol kiritish uchun controller
  final _passwordController = TextEditingController();
  
  /// Ism kiritish uchun controller
  final _nameController = TextEditingController();
  
  /// Telefon raqami uchun controller
  final _phoneController = TextEditingController();
  
  /// Form kaliti - validatsiya uchun
  final _formKey = GlobalKey<FormState>();
  
  /// Tanlangan rol (Mijoz yoki Chevar)
  String _selectedRole = 'Mijoz';
  
  /// Xato xabari
  String? _errorMessage;
  
  /// Yuklanayotgan holati
  bool _isLoading = false;
  
  /// Parolni ko'rsatish/yashirish
  bool _obscurePassword = true;

  // ==================== METODLAR ====================

  /// Ro'yxatdan o'tish funksiyasi
  Future<void> _register() async {
    // Form validatsiyasini tekshirish
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1-qadam: Firebase'da yangi foydalanuvchi yaratish
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2-qadam: Firestore'ga foydalanuvchi ma'lumotlarini saqlash
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'rating': 0.0,
        'ratingCount': 0,
      });

      // Home ekraniga o'tish
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getUzbekErrorMessage(e.code);
      });
    } on FirebaseException catch (e) {
      // Firestore xatolari
      setState(() {
        _errorMessage = 'Firebase xatosi: ${e.message ?? e.code}';
      });
    } catch (e) {
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
      case 'email-already-in-use':
        return 'Bu email allaqachon ro\'yxatdan o\'tgan';
      case 'invalid-email':
        return 'Email formati noto\'g\'ri';
      case 'weak-password':
        return 'Parol juda oddiy. Murakkab parol kiriting';
      case 'operation-not-allowed':
        return 'Email bilan ro\'yxatdan o\'tish o\'chirilgan';
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
              Color(0xFFFCE4EC),
              Color(0xFFF8BBD0),
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
                        size: 60,
                        color: Color(0xFFff00ae),
                      ),
                      const SizedBox(height: 8),
                      
                      // ===== SARLAVHA =====
                      const Text(
                        "Ro'yxatdan o'tish",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFff00ae),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // ===== ISM MAYDONI =====
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Ism va familiya",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFff00ae)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ism kiritish shart';
                          }
                          if (value.length < 3) {
                            return 'Ism kamida 3 ta harf bo\'lishi kerak';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // ===== TELEFON MAYDONI =====
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: "Telefon raqam",
                          hintText: "+998 90 123 45 67",
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.phone, color: Color(0xFFff00ae)),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Telefon raqam kiritish shart';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
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
                      
                      // ===== ROL TANLASH =====
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(
                            labelText: "Siz kimsiz?",
                            labelStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.work, color: Color(0xFFff00ae)),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Mijoz',
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Mijoz - Kiyim tiktirgim keladi'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Chevar',
                              child: Row(
                                children: [
                                  Icon(Icons.checkroom, color: Colors.pink),
                                  SizedBox(width: 8),
                                  Text('Chevar - Kiyim tikaman'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value ?? 'Mijoz';
                            });
                          },
                        ),
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
                      
                      // ===== RO'YXATDAN O'TISH TUGMASI =====
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
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFff00ae),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  "Ro'yxatdan o'tish",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      
                      // ===== KIRISH HAVOLASI =====
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Hisobingiz bormi? Kirish",
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

  /// Resurslarni tozalash
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}