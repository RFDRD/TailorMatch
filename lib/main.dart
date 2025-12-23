// =============================================================
// TAILORMATCH - Chevarlar va mijozlar uchun mobil ilova
// =============================================================
// Bu fayl ilovaning asosiy kirish nuqtasi hisoblanadi.
// Firebase bilan bog'lanish va asosiy konfiguratsiya shu yerda.
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/tailor/tailor_home.dart';
import 'screens/client/client_home.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Ilovaning asosiy funksiyasi
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Firestore sozlamalari - web uchun persistence o'chiriladi
  if (!kIsWeb) {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const TailorMatchApp(),
    ),
  );
}

/// Asosiy ilova widget'i
class TailorMatchApp extends StatelessWidget {
  const TailorMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return MaterialApp(
      title: 'TailorMatch',
      debugShowCheckedModeBanner: false,
      locale: localeProvider.locale,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE91E63),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const AuthWrapper(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('uz'),
        Locale('ru'),
        Locale('en'),
      ],
    );
  }
}

/// Auth holati wrapper - avtomatik yo'naltirish
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;
  bool _isLoading = true;
  String? _userRole;
  late final Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) async {
    if (!mounted) return;

    if (user == null) {
      setState(() {
        _user = null;
        _userRole = null;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (mounted) {
        setState(() {
          _user = user;
          _userRole = doc.exists ? (doc.data()?['role'] ?? 'client') : 'client';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _user = user;
          _userRole = 'client';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE91E63)),
        ),
      );
    }

    if (_user == null) {
      return const LoginScreen();
    }

    if (_userRole == 'tailor') {
      return const TailorHomeScreen();
    } else {
      return const ClientHomeScreen();
    }
  }
}
