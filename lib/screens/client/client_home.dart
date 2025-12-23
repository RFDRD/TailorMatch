// =============================================================
// CLIENT HOME SCREEN - Mijoz asosiy ekrani
// =============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/order_model.dart';
import '../../models/service_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/order_service.dart';
import '../../services/chat_service.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_screens.dart';
import '../chat/chat_screen.dart';
import '../chat/chats_list_screen.dart';

const Color primaryColor = Color(0xFFE91E63);

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _userService = UserService();
  final _orderService = OrderService();

  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUserData();
    if (mounted) setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _TailorsListPage(userService: _userService, orderService: _orderService),
          _FavoritesPage(userService: _userService, orderService: _orderService),
          const ChatsListScreen(),
          _MyOrdersPage(orderService: _orderService, userService: _userService),
          _ClientProfilePage(user: _user, authService: _authService),
        ],
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final l = AppLocalizations.of(context);
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: l.tr('tailors'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_border),
                activeIcon: const Icon(Icons.favorite),
                label: l.tr('favorites'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_bubble_outline),
                activeIcon: const Icon(Icons.chat_bubble),
                label: l.tr('messages'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.shopping_bag_outlined),
                activeIcon: const Icon(Icons.shopping_bag),
                label: l.tr('orders'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: l.tr('profile'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================== TAILORS LIST ====================
class _TailorsListPage extends StatefulWidget {
  final UserService userService;
  final OrderService orderService;

  const _TailorsListPage({required this.userService, required this.orderService});

  @override
  State<_TailorsListPage> createState() => _TailorsListPageState();
}

class _TailorsListPageState extends State<_TailorsListPage> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TailorMatch', style: GoogleFonts.pacifico(fontSize: 24)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor.withValues(alpha: 0.1),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Chevar qidirish...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Tailors list
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: widget.userService.getTailors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }

                var tailors = snapshot.data ?? [];

                // Filter by search
                if (_searchController.text.isNotEmpty) {
                  tailors = tailors.where((t) =>
                      t.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                      (t.address?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false)
                  ).toList();
                }

                if (tailors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Chevarlar topilmadi',
                          style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tailors.length,
                  itemBuilder: (context, index) {
                    final tailor = tailors[index];
                    return _TailorCard(
                      tailor: tailor,
                      userService: widget.userService,
                      orderService: widget.orderService,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TAILOR CARD ====================
class _TailorCard extends StatelessWidget {
  final UserModel tailor;
  final UserService userService;
  final OrderService orderService;

  const _TailorCard({
    required this.tailor,
    required this.userService,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    final clientId = FirebaseAuth.instance.currentUser?.uid;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _TailorDetailPage(
                tailor: tailor,
                userService: userService,
                orderService: orderService,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: primaryColor,
                backgroundImage: tailor.avatar != null
                    ? CachedNetworkImageProvider(tailor.avatar!)
                    : null,
                child: tailor.avatar == null
                    ? Text(
                        tailor.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tailor.name,
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (tailor.address != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tailor.address!,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          tailor.rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' (${tailor.ratingCount})',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                        const Spacer(),
                        if (tailor.experienceYears != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${tailor.experienceYears} yil',
                              style: TextStyle(color: primaryColor, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite button
              if (clientId != null)
                StreamBuilder<bool>(
                  stream: userService.isFavorite(clientId, tailor.id),
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          userService.removeFromFavorites(clientId, tailor.id);
                        } else {
                          userService.addToFavorites(clientId, tailor.id);
                        }
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== TAILOR DETAIL PAGE ====================
class _TailorDetailPage extends StatelessWidget {
  final UserModel tailor;
  final UserService userService;
  final OrderService orderService;

  const _TailorDetailPage({
    required this.tailor,
    required this.userService,
    required this.orderService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tailor.name),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => _startChat(context),
            tooltip: 'Xabar yozish',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      tailor.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 36, color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tailor.name,
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (tailor.address != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(tailor.address!, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatChip(icon: Icons.star, value: tailor.rating.toStringAsFixed(1), label: 'Reyting'),
                      const SizedBox(width: 16),
                      if (tailor.experienceYears != null)
                        _StatChip(icon: Icons.work, value: '${tailor.experienceYears}', label: 'Yil'),
                    ],
                  ),
                ],
              ),
            ),

            // Services
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Band kunlar
                  Text(
                    'Band kunlar',
                    style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<DateTime>>(
                    stream: userService.getBusyDays(tailor.id),
                    builder: (context, snapshot) {
                      final busyDays = snapshot.data ?? [];
                      final today = DateTime.now();
                      final upcomingBusyDays = busyDays.where((d) => 
                        d.isAfter(today.subtract(const Duration(days: 1)))
                      ).toList()..sort();

                      if (upcomingBusyDays.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[600]),
                              const SizedBox(width: 12),
                              const Expanded(child: Text('Hozircha band kunlar yo\'q')),
                            ],
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: upcomingBusyDays.take(7).map((d) {
                          return Chip(
                            avatar: const Icon(Icons.event_busy, size: 16, color: Colors.red),
                            label: Text('${d.day}.${d.month}'),
                            backgroundColor: Colors.red[50],
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Xizmatlar
                  Text(
                    'Xizmatlar',
                    style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<ServiceModel>>(
                    stream: userService.getTailorServices(tailor.id),
                    builder: (context, snapshot) {
                      final services = snapshot.data ?? [];

                      if (services.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Xizmatlar hali qo\'shilmagan'),
                          ),
                        );
                      }

                      return Column(
                        children: services.map((service) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: primaryColor.withValues(alpha: 0.1),
                                child: const Icon(Icons.checkroom, color: primaryColor),
                              ),
                              title: Text(service.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${service.priceRange} • ${service.avgTime}'),
                              trailing: ElevatedButton(
                                onPressed: () => _bookService(context, service),
                                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                child: const Text('Buyurtma'),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bookService(BuildContext context, ServiceModel service) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await orderService.createOrder(
        clientId: userId,
        tailorId: tailor.id,
        serviceId: service.id,
        serviceName: service.type,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buyurtma yuborildi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _startChat(BuildContext context) async {
    final clientId = FirebaseAuth.instance.currentUser?.uid;
    if (clientId == null) return;

    final authService = AuthService();
    final chatService = ChatService();
    final client = await authService.getCurrentUserData();
    
    if (client == null) return;

    final chat = await chatService.getOrCreateChat(
      clientId: clientId,
      tailorId: tailor.id,
      clientName: client.name,
      tailorName: tailor.name,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: chat.id,
            otherUserName: tailor.name,
            otherUserId: tailor.id,
          ),
        ),
      );
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

// ==================== FAVORITES PAGE ====================
class _FavoritesPage extends StatelessWidget {
  final UserService userService;
  final OrderService orderService;

  const _FavoritesPage({required this.userService, required this.orderService});

  @override
  Widget build(BuildContext context) {
    final clientId = FirebaseAuth.instance.currentUser?.uid;
    if (clientId == null) return const Center(child: Text('Xatolik'));

    return Scaffold(
      appBar: AppBar(
        title: Text('Sevimli Chevarlar', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: userService.getFavorites(clientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Sevimli chevarlar yo\'q',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chevarlar ro\'yxatida ❤️ bosing',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final tailor = favorites[index];
              return _TailorCard(
                tailor: tailor,
                userService: userService,
                orderService: orderService,
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== MY ORDERS PAGE ====================
class _MyOrdersPage extends StatelessWidget {
  final OrderService orderService;
  final UserService userService;

  const _MyOrdersPage({required this.orderService, required this.userService});

  @override
  Widget build(BuildContext context) {
    final clientId = FirebaseAuth.instance.currentUser?.uid;
    if (clientId == null) return const Center(child: Text('Xatolik'));

    return Scaffold(
      appBar: AppBar(
        title: Text('Buyurtmalarim', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getClientOrders(clientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Xatolik yuz berdi',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '${snapshot.error}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Hali buyurtmalar yo\'q',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _ClientOrderCard(order: order, userService: userService);
            },
          );
        },
      ),
    );
  }
}

class _ClientOrderCard extends StatelessWidget {
  final OrderModel order;
  final UserService userService;

  const _ClientOrderCard({required this.order, required this.userService});

  Color get statusColor {
    switch (order.status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.meetingScheduled: return Colors.blue;
      case OrderStatus.inProgress: return Colors.purple;
      case OrderStatus.fittingScheduled: return Colors.indigo;
      case OrderStatus.ready: return Colors.green;
      case OrderStatus.completed: return Colors.grey;
      case OrderStatus.cancelled: return Colors.red;
    }
  }

  void _showRatingDialog(BuildContext context) {
    double overallRating = 5.0;
    Map<String, int> aspects = {
      'quality': 0, // Tikilish sifati
      'size': 0,     // Hajmi
      'speed': 0,    // Tezligi
      'service': 0,  // Muomalasi
      'price': 0,    // Narxi
    };
    
    final aspectIcons = {
      'quality': Icons.verified,
      'size': Icons.straighten,
      'speed': Icons.speed,
      'service': Icons.handshake,
      'price': Icons.attach_money,
    };
    
    final aspectLabels = {
      'quality': 'Sifat',
      'size': 'Hajm',
      'speed': 'Tezlik',
      'service': 'Muomala',
      'price': 'Narx',
    };
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Chevarga baho bering'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Overall rating stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < overallRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setDialogState(() => overallRating = index + 1.0);
                      },
                    );
                  }),
                ),
                Text(
                  '${overallRating.toInt()} yulduz',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                
                // Aspect selection (only shown when 5 stars)
                if (overallRating >= 4) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Nimani yoqtirdingiz?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: aspects.keys.map((key) {
                      final isSelected = aspects[key] == 1;
                      return FilterChip(
                        avatar: Icon(
                          aspectIcons[key],
                          size: 18,
                          color: isSelected ? Colors.white : primaryColor,
                        ),
                        label: Text(aspectLabels[key]!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() => aspects[key] = selected ? 1 : 0);
                        },
                        selectedColor: primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                ],
                
                // Low rating feedback
                if (overallRating < 4) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Nimani yoqtirmadingiz?',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: aspects.keys.map((key) {
                      final isSelected = aspects[key] == -1;
                      return FilterChip(
                        avatar: Icon(
                          aspectIcons[key],
                          size: 18,
                          color: isSelected ? Colors.white : Colors.red,
                        ),
                        label: Text(aspectLabels[key]!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() => aspects[key] = selected ? -1 : 0);
                        },
                        selectedColor: Colors.red[400],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await userService.rateTailor(order.tailorId, overallRating);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rahmat! Bahoyingiz qabul qilindi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Xatolik: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Yuborish'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.serviceName,
                  style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (order.dates.meeting != null)
              _DateRow(icon: Icons.event, label: 'Uchrashuv', date: order.dates.meeting!),
            if (order.dates.fitting != null)
              _DateRow(icon: Icons.checkroom, label: 'Primerka', date: order.dates.fitting!),
            // Baho berish tugmasi - faqat yakunlangan buyurtmalarda
            if (order.status == OrderStatus.completed) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showRatingDialog(context),
                  icon: const Icon(Icons.star, color: Colors.amber),
                  label: const Text('Baho berish'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber[700],
                    side: BorderSide(color: Colors.amber[700]!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime date;

  const _DateRow({required this.icon, required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Text(
            '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ==================== CLIENT PROFILE PAGE ====================
class _ClientProfilePage extends StatelessWidget {
  final UserModel? user;
  final AuthService authService;

  const _ClientProfilePage({required this.user, required this.authService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: primaryColor,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'M',
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'Mijoz',
              style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: primaryColor),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? ''),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone, color: primaryColor),
                    title: const Text('Telefon'),
                    subtitle: Text(user?.phone ?? ''),
                  ),
                  if (user?.address != null && user!.address!.isNotEmpty) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: primaryColor),
                      title: const Text('Viloyat'),
                      subtitle: Text(user!.address!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Profilni tahrirlash
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.edit, color: primaryColor),
                title: const Text('Profilni tahrirlash'),
                subtitle: const Text('Ism, viloyat'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showEditProfileDialog(context),
              ),
            ),
            const SizedBox(height: 16),
            // Til tanlash
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.language, color: primaryColor),
                title: const Text('Til / Язык / Language'),
                subtitle: _getLanguageName(context),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showLanguageDialog(context),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutConfirmation(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Chiqish', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: user?.name ?? '');
    String? selectedRegion = user?.address;
    
    final regions = [
      'Toshkent shahri',
      'Toshkent viloyati',
      'Andijon viloyati',
      'Buxoro viloyati',
      'Farg\'ona viloyati',
      'Jizzax viloyati',
      'Namangan viloyati',
      'Navoiy viloyati',
      'Qashqadaryo viloyati',
      'Samarqand viloyati',
      'Sirdaryo viloyati',
      'Surxondaryo viloyati',
      'Xorazm viloyati',
      'Qoraqalpog\'iston Respublikasi',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Profilni tahrirlash'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ism',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: regions.contains(selectedRegion) ? selectedRegion : null,
                  decoration: const InputDecoration(
                    labelText: 'Viloyat',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  items: regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (value) => setDialogState(() => selectedRegion = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.id)
                      .update({
                    'name': nameController.text,
                    'address': selectedRegion,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil yangilandi!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Xatolik: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text('Haqiqatan ham hisobingizdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ha, chiqish'),
          ),
        ],
      ),
    );
  }

  Widget _getLanguageName(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    switch (locale.languageCode) {
      case 'uz': return const Text('O\'zbekcha 🇺🇿');
      case 'ru': return const Text('Русский 🇷🇺');
      case 'en': return const Text('English 🇬🇧');
      default: return const Text('O\'zbekcha 🇺🇿');
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tilni tanlang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇿', style: TextStyle(fontSize: 24)),
              title: const Text('O\'zbekcha'),
              onTap: () {
                localeProvider.setLanguage('uz');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇷🇺', style: TextStyle(fontSize: 24)),
              title: const Text('Русский'),
              onTap: () {
                localeProvider.setLanguage('ru');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              onTap: () {
                localeProvider.setLanguage('en');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
