// =============================================================
// ASOSIY EKRAN - HomeScreen va boshqa sahifalar
// =============================================================
// Bu fayl ilovaning asosiy sahifalarini o'z ichiga oladi:
// - HomeScreen: Asosiy navigatsiya
// - HomePage: Bosh sahifa
// - CatalogPage: Katalog
// - OrderPage: Buyurtmalar
// - ProfilePage: Foydalanuvchi profili
// - ChevarListPage: Chevarlar ro'yxati
// - ServicesListPage: Xizmatlar ro'yxati
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

/// =====================================================
/// ASOSIY EKRAN - Navigatsiya bilan
/// =====================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Hozirgi tanlangan sahifa indeksi
  int _selectedIndex = 0;
  
  /// Qidiruv maydoni ko'rinishini boshqarish
  bool _isSearching = false;
  
  /// Qidiruv matni
  final _searchController = TextEditingController();

  /// Sahifalar ro'yxati
  static const List<Widget> _pages = [
    HomePage(),      // 0 - Asosiy
    CatalogPage(),   // 1 - Katalog
    OrderPage(),     // 2 - Buyurtmalar
    ProfilePage(),   // 3 - Profil
  ];

  /// Navigatsiya tugmasi bosilganda
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== APP BAR =====
      appBar: AppBar(
        // Sarlavha yoki qidiruv maydoni
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Qidirish...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : Text(
                'Seamstress',
                style: GoogleFonts.pacifico(
                  fontSize: 24,
                  fontWeight: FontWeight.normal,
                ),
              ),
        backgroundColor: const Color(0xFFff00ae),
        foregroundColor: Colors.white,
        // Amallar tugmalari
        actions: [
          // Qidiruv tugmasi
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      
      // ===== ASOSIY CONTENT =====
      body: _pages[_selectedIndex],
      
      // ===== PASTKI NAVIGATSIYA =====
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Asosiy',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Katalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Buyurtmalar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFff00ae),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// =====================================================
/// MENYU ELEMENTI MODELI
/// =====================================================
class MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isAnimated;
  final Color color;

  const MenuItem({
    required this.title, 
    required this.icon, 
    this.onTap, 
    this.isAnimated = false,
    this.color = const Color(0xFFff00ae),
  });
}

/// =====================================================
/// ASOSIY SAHIFA - HomePage
/// =====================================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Menyu elementlari
  static const List<MenuItem> menuItems = [
    MenuItem(
      title: 'Chevarlar',
      icon: Icons.people_outline,
      isAnimated: true,
      color: Color(0xFFE91E63),
    ),
    MenuItem(
      title: 'Xizmatlar',
      icon: Icons.design_services,
      isAnimated: true,
      color: Color(0xFF9C27B0),
    ),
    MenuItem(
      title: 'Mashhur',
      icon: Icons.star_outline,
      isAnimated: true,
      color: Color(0xFFFF9800),
    ),
    MenuItem(
      title: 'Yangi',
      icon: Icons.fiber_new,
      isAnimated: true,
      color: Color(0xFF4CAF50),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== BANNER =====
          Container(
            height: 180,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFff00ae), Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFff00ae).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Orqa fon naqshi
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Icon(
                    Icons.checkroom,
                    size: 150,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                // Matn
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Eng yaxshi chevarlar',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'O\'zingizga mos chevar toping\nva buyurtma bering',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChevarListPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFff00ae),
                        ),
                        child: const Text('Chevarlarni ko\'rish'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // ===== BO'LIMLAR SARLAVHASI =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Bo\'limlar',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // ===== MENYU KARTALARI =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StaggeredGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: menuItems.asMap().entries.map((entry) {
                return StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: AnimatedMenuCard(
                    title: entry.value.title,
                    icon: entry.value.icon,
                    color: entry.value.color,
                    onTap: () {
                      if (entry.value.title == 'Chevarlar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChevarListPage()),
                        );
                      } else if (entry.value.title == 'Xizmatlar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ServicesListPage()),
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// =====================================================
/// ANIMATSIYALI MENYU KARTASI
/// =====================================================
class AnimatedMenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const AnimatedMenuCard({
    super.key, 
    required this.title, 
    required this.icon, 
    this.onTap,
    this.color = const Color(0xFFff00ae),
  });

  @override
  State<AnimatedMenuCard> createState() => _AnimatedMenuCardState();
}

class _AnimatedMenuCardState extends State<AnimatedMenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, size: 32, color: widget.color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// =====================================================
/// XIZMATLAR RO'YXATI SAHIFASI
/// =====================================================
class ServicesListPage extends StatelessWidget {
  const ServicesListPage({super.key});

  /// Xizmatlar ro'yxati
  static const List<Map<String, dynamic>> services = [
    {'name': 'Kostyum tikish', 'icon': Icons.business_center, 'price': '300 000 - 800 000'},
    {'name': 'Shim tikish', 'icon': Icons.checkroom, 'price': '100 000 - 250 000'},
    {'name': 'Ko\'ylak tikish', 'icon': Icons.dry_cleaning, 'price': '150 000 - 350 000'},
    {'name': 'Palto tikish', 'icon': Icons.layers, 'price': '400 000 - 1 000 000'},
    {'name': 'Kurtka tikish', 'icon': Icons.shield, 'price': '250 000 - 600 000'},
    {'name': 'Ko\'ylak-libos', 'icon': Icons.woman, 'price': '200 000 - 500 000'},
    {'name': 'Bolalar kiyimi', 'icon': Icons.child_care, 'price': '80 000 - 200 000'},
    {'name': 'Ta\'mirlash', 'icon': Icons.build, 'price': '20 000 - 100 000'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xizmatlar', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFFff00ae),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFff00ae).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(service['icon'], color: const Color(0xFFff00ae)),
              ),
              title: Text(
                service['name'],
                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${service['price']} so\'m',
                style: GoogleFonts.lato(color: Colors.grey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceDetailPage(
                      serviceName: service['name'],
                      price: service['price'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// =====================================================
/// XIZMAT TAFSILOTLARI SAHIFASI
/// =====================================================
class ServiceDetailPage extends StatelessWidget {
  final String serviceName;
  final String price;

  const ServiceDetailPage({
    super.key, 
    required this.serviceName,
    this.price = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName, style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFFff00ae),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sarlavha
            Text(
              serviceName,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Narx
            if (price.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFff00ae).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$price so\'m',
                  style: GoogleFonts.lato(
                    color: const Color(0xFFff00ae),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // Tavsif
            Text(
              'Bu xizmat haqida batafsil ma\'lumot. Bu yerda xizmat qanday bajarilishi, qancha vaqt ketishi va boshqa ma\'lumotlar ko\'rsatiladi.',
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Buyurtma tugmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateOrderPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff00ae),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Buyurtma berish',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================================================
/// CHEVARLAR RO'YXATI SAHIFASI
/// =====================================================
class ChevarListPage extends StatelessWidget {
  const ChevarListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chevarlar', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFFff00ae),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore'dan chevarlarni olish
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Chevar')
            .snapshots(),
        builder: (context, snapshot) {
          // Yuklanmoqda
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFff00ae)),
            );
          }
          
          // Xato
          if (snapshot.hasError) {
            return Center(
              child: Text('Xatolik: ${snapshot.error}'),
            );
          }
          
          // Ma'lumot yo'q
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Hozircha chevarlar yo\'q',
                    style: GoogleFonts.lato(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          // Chevarlar ro'yxati
          final chevars = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chevars.length,
            itemBuilder: (context, index) {
              final chevar = chevars[index].data() as Map<String, dynamic>;
              final rating = (chevar['rating'] ?? 0.0).toDouble();
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFff00ae).withValues(alpha: 0.1),
                    child: Text(
                      (chevar['name'] ?? 'C')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFff00ae),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    chevar['name'] ?? 'Noma\'lum',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.lato(color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${chevar['phone'] ?? ''}',
                        style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChevarProfilePage(
                          chevarId: chevars[index].id,
                          chevarData: chevar,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// =====================================================
/// CHEVAR PROFIL SAHIFASI
/// =====================================================
class ChevarProfilePage extends StatefulWidget {
  final String chevarId;
  final Map<String, dynamic> chevarData;

  const ChevarProfilePage({
    super.key, 
    required this.chevarId,
    required this.chevarData,
  });

  @override
  State<ChevarProfilePage> createState() => _ChevarProfilePageState();
}

class _ChevarProfilePageState extends State<ChevarProfilePage> {
  double _userRating = 0;

  /// Baho berish dialogi
  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double tempRating = _userRating;
        return AlertDialog(
          title: const Text('Baho bering'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < tempRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        tempRating = index + 1.0;
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Bahoni saqlash
                await _submitRating(tempRating);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Baho qabul qilindi!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff00ae),
              ),
              child: const Text('Saqlash'),
            ),
          ],
        );
      },
    );
  }

  /// Bahoni Firebase'ga saqlash
  Future<void> _submitRating(double rating) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(widget.chevarId);
    
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final currentRating = (data['rating'] ?? 0.0).toDouble();
      final ratingCount = (data['ratingCount'] ?? 0) + 1;
      final newRating = ((currentRating * (ratingCount - 1)) + rating) / ratingCount;
      
      transaction.update(docRef, {
        'rating': newRating,
        'ratingCount': ratingCount,
      });
    });
    
    setState(() {
      _userRating = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.chevarData['name'] ?? 'Noma\'lum';
    final rating = (widget.chevarData['rating'] ?? 0.0).toDouble();
    final phone = widget.chevarData['phone'] ?? '';
    final email = widget.chevarData['email'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFFff00ae),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== PROFIL HEADER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFff00ae), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFff00ae),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Ism
                  Text(
                    name,
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Reyting
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < rating.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // ===== MA'LUMOTLAR =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Telefon
                  if (phone.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.phone, color: Color(0xFFff00ae)),
                      title: const Text('Telefon'),
                      subtitle: Text(phone),
                    ),
                  
                  // Email
                  if (email.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFFff00ae)),
                      title: const Text('Email'),
                      subtitle: Text(email),
                    ),
                  
                  const Divider(),
                  
                  // Baho berish tugmasi
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('Baho berish'),
                    subtitle: const Text('Chevarni baholang'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _showRatingDialog,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buyurtma berish tugmasi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateOrderPage(chevarId: widget.chevarId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Buyurtma berish'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFff00ae),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================================================
/// KATALOG SAHIFASI
/// =====================================================
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  /// Namuna mahsulotlar
  static const List<Product> products = [
    Product(
      imageUrl: 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400',
      title: 'Erkaklar kostyumi',
      price: '500 000',
    ),
    Product(
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      title: 'Ayollar libosi',
      price: '350 000',
    ),
    Product(
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      title: 'Klassik shim',
      price: '180 000',
    ),
    Product(
      imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400',
      title: 'Ko\'ylak',
      price: '200 000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _buildProductCard(context, products[index]),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rasm
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
          // Ma'lumot
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.price} so\'m',
                  style: GoogleFonts.lato(
                    color: const Color(0xFFff00ae),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// =====================================================
/// BUYURTMALAR SAHIFASI
/// =====================================================
class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Center(child: Text('Tizimga kiring'));
    }

    return Column(
      children: [
        // Yangi buyurtma tugmasi
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateOrderPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Yangi buyurtma'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFff00ae),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        
        // Buyurtmalar ro'yxati
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('userId', isEqualTo: user.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFff00ae)),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Buyurtmalaringiz bo\'sh',
                        style: GoogleFonts.lato(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              
              final orders = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index].data() as Map<String, dynamic>;
                  final status = order['status'] ?? 'pending';
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                        ),
                      ),
                      title: Text(
                        order['serviceName'] ?? 'Buyurtma',
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _getStatusText(status),
                        style: TextStyle(color: _getStatusColor(status)),
                      ),
                      trailing: Text(
                        '${order['price'] ?? 0} so\'m',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFff00ae),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.access_time;
      case 'in_progress': return Icons.build;
      case 'completed': return Icons.check_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Kutilmoqda';
      case 'in_progress': return 'Tayyorlanmoqda';
      case 'completed': return 'Tayyor';
      case 'cancelled': return 'Bekor qilingan';
      default: return 'Noma\'lum';
    }
  }
}

/// =====================================================
/// YANGI BUYURTMA YARATISH SAHIFASI
/// =====================================================
class CreateOrderPage extends StatefulWidget {
  final String? chevarId;
  
  const CreateOrderPage({super.key, this.chevarId});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedService = 'Ko\'ylak tikish';
  bool _isLoading = false;

  /// Buyurtmani saqlash
  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Foydalanuvchi topilmadi');
      
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'chevarId': widget.chevarId,
        'serviceName': _selectedService,
        'description': _descriptionController.text.trim(),
        'status': 'pending',
        'price': 0,
        'createdAt': Timestamp.now(),
      });
      
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buyurtma yuborildi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xatolik: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yangi buyurtma', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFFff00ae),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Xizmat tanlash
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: InputDecoration(
                labelText: 'Xizmat turi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.checkroom, color: Color(0xFFff00ae)),
              ),
              items: const [
                DropdownMenuItem(value: 'Ko\'ylak tikish', child: Text('Ko\'ylak tikish')),
                DropdownMenuItem(value: 'Shim tikish', child: Text('Shim tikish')),
                DropdownMenuItem(value: 'Kostyum tikish', child: Text('Kostyum tikish')),
                DropdownMenuItem(value: 'Palto tikish', child: Text('Palto tikish')),
                DropdownMenuItem(value: 'Ta\'mirlash', child: Text('Ta\'mirlash')),
              ],
              onChanged: (value) {
                setState(() => _selectedService = value ?? _selectedService);
              },
            ),
            const SizedBox(height: 16),
            
            // Tavsif
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Tavsif',
                hintText: 'Buyurtma haqida batafsil yozing...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tavsif kiritish shart';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Yuborish tugmasi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff00ae),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Buyurtma yuborish',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}

/// =====================================================
/// PROFIL SAHIFASI
/// =====================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return const Center(child: Text('Tizimga kiring'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFff00ae)),
          );
        }
        
        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final name = userData['name'] ?? 'Foydalanuvchi';
        final email = userData['email'] ?? user.email ?? '';
        final role = userData['role'] ?? 'Mijoz';
        final phone = userData['phone'] ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ===== PROFIL KARTASI =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFff00ae), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFff00ae),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Ism
                    Text(
                      name,
                      style: GoogleFonts.lato(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Rol
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // ===== MA'LUMOTLAR RO'YXATI =====
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email, color: Color(0xFFff00ae)),
                      title: const Text('Email'),
                      subtitle: Text(email),
                    ),
                    if (phone.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.phone, color: Color(0xFFff00ae)),
                        title: const Text('Telefon'),
                        subtitle: Text(phone),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ===== AMALLAR =====
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Color(0xFFff00ae)),
                      title: const Text('Buyurtmalarim'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Buyurtmalar sahifasiga o'tish
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings, color: Color(0xFFff00ae)),
                      title: const Text('Sozlamalar'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help, color: Color(0xFFff00ae)),
                      title: const Text('Yordam'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // ===== CHIQISH TUGMASI =====
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Chiqish',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Chiqish tasdiqlash dialogi
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text('Haqiqatan ham tizimdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Ha, chiqish'),
          ),
        ],
      ),
    );
  }
}

/// =====================================================
/// MAHSULOT MODELI
/// =====================================================
class Product {
  final String imageUrl;
  final String title;
  final String price;
  
  const Product({
    required this.imageUrl, 
    required this.title, 
    required this.price,
  });
}