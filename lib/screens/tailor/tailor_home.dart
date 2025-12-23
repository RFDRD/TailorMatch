// =============================================================
// TAILOR HOME SCREEN - Chevar asosiy ekrani
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
import '../../models/portfolio_model.dart';
import '../../models/message_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/order_service.dart';
import '../../services/storage_service.dart';
import '../../services/chat_service.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_screens.dart';
import '../chat/chat_screen.dart';

const Color primaryColor = Color(0xFFE91E63);

class TailorHomeScreen extends StatefulWidget {
  const TailorHomeScreen({super.key});

  @override
  State<TailorHomeScreen> createState() => _TailorHomeScreenState();
}

class _TailorHomeScreenState extends State<TailorHomeScreen> {
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
          _TailorDashboard(orderService: _orderService),
          _ServicesPage(userService: _userService),
          _TailorChatsPage(),
          _CalendarPage(userService: _userService),
          _TailorProfilePage(user: _user, authService: _authService),
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
                icon: const Icon(Icons.dashboard_outlined),
                activeIcon: const Icon(Icons.dashboard),
                label: l.tr('orders'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.design_services_outlined),
                activeIcon: const Icon(Icons.design_services),
                label: l.tr('services'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_outlined),
                activeIcon: const Icon(Icons.chat),
                label: l.tr('messages'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.calendar_month_outlined),
                activeIcon: const Icon(Icons.calendar_month),
                label: l.tr('calendar'),
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

// ==================== DASHBOARD ====================
class _TailorDashboard extends StatefulWidget {
  final OrderService orderService;

  const _TailorDashboard({required this.orderService});

  @override
  State<_TailorDashboard> createState() => _TailorDashboardState();
}

class _TailorDashboardState extends State<_TailorDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tailorId = FirebaseAuth.instance.currentUser?.uid;
    if (tailorId == null) return const Center(child: Text('Xatolik'));

    return Scaffold(
      appBar: AppBar(
        title: Text('Buyurtmalar', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.new_releases), text: 'Yangi'),
            Tab(icon: Icon(Icons.schedule), text: 'Jarayonda'),
            Tab(icon: Icon(Icons.check_circle), text: 'Tayyor'),
            Tab(icon: Icon(Icons.done_all), text: 'Yakunlangan'),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: widget.orderService.getTailorOrders(tailorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final allOrders = snapshot.data ?? [];

          // Kategoriyalarga bo'lish
          final newOrders = allOrders.where((o) => 
            o.status == OrderStatus.pending || o.status == OrderStatus.meetingScheduled).toList();
          final inProgressOrders = allOrders.where((o) => 
            o.status == OrderStatus.inProgress || o.status == OrderStatus.fittingScheduled).toList();
          final readyOrders = allOrders.where((o) => o.status == OrderStatus.ready).toList();
          final completedOrders = allOrders.where((o) => 
            o.status == OrderStatus.completed || o.status == OrderStatus.cancelled).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(newOrders, 'Yangi buyurtmalar yo\'q', Icons.new_releases),
              _buildOrderList(inProgressOrders, 'Jarayondagi buyurtmalar yo\'q', Icons.schedule),
              _buildOrderList(readyOrders, 'Tayyor buyurtmalar yo\'q', Icons.check_circle),
              _buildOrderList(completedOrders, 'Yakunlangan buyurtmalar yo\'q', Icons.done_all),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String emptyMessage, IconData emptyIcon) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: GoogleFonts.lato(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _OrderCard(order: orders[index], orderService: widget.orderService);
      },
    );
  }
}

// ==================== ORDER CARD ====================
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderService orderService;

  const _OrderCard({required this.order, required this.orderService});

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
              _InfoRow(icon: Icons.event, label: 'Uchrashuv', value: _formatDate(order.dates.meeting!)),
            if (order.dates.fitting != null)
              _InfoRow(icon: Icons.checkroom, label: 'Primerka', value: _formatDate(order.dates.fitting!)),
            const SizedBox(height: 12),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (order.status) {
      case OrderStatus.pending:
        return ElevatedButton.icon(
          onPressed: () => _showDatePicker(context, 'Uchrashuv', (date) {
            orderService.acceptOrder(order.id, date);
          }),
          icon: const Icon(Icons.check),
          label: const Text('Qabul qilish'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        );
      case OrderStatus.meetingScheduled:
        return ElevatedButton.icon(
          onPressed: () => orderService.startWork(order.id),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Ishni boshlash'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        );
      case OrderStatus.inProgress:
        return ElevatedButton.icon(
          onPressed: () => _showDatePicker(context, 'Primerka', (date) {
            orderService.scheduleFitting(order.id, date);
          }),
          icon: const Icon(Icons.checkroom),
          label: const Text('Primerka belgilash'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
        );
      case OrderStatus.fittingScheduled:
        return ElevatedButton.icon(
          onPressed: () => orderService.markAsReady(order.id),
          icon: const Icon(Icons.done_all),
          label: const Text('Tayyor'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        );
      case OrderStatus.ready:
        return ElevatedButton.icon(
          onPressed: () => orderService.completeOrder(order.id),
          icon: const Icon(Icons.check_circle),
          label: const Text('Yakunlash'),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        );
      default:
        return const SizedBox();
    }
  }

  void _showDatePicker(BuildContext context, String title, Function(DateTime) onSelected) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
      );
      if (time != null) {
        final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        onSelected(dateTime);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==================== SERVICES PAGE ====================
class _ServicesPage extends StatefulWidget {
  final UserService userService;

  const _ServicesPage({required this.userService});

  @override
  State<_ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<_ServicesPage> {
  @override
  Widget build(BuildContext context) {
    final tailorId = FirebaseAuth.instance.currentUser?.uid;
    if (tailorId == null) return const Center(child: Text('Xatolik'));

    return Scaffold(
      appBar: AppBar(
        title: Text('Xizmatlarim', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context, tailorId),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<ServiceModel>>(
        stream: widget.userService.getTailorServices(tailorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.design_services, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Xizmatlar qo\'shing',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => widget.userService.deleteService(service.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, String tailorId) {
    final typeController = TextEditingController();
    final minPriceController = TextEditingController();
    final maxPriceController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xizmat qo\'shish'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Xizmat turi (Ko\'ylak, Shim...)'),
              ),
              TextField(
                controller: minPriceController,
                decoration: const InputDecoration(labelText: 'Minimal narx'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: maxPriceController,
                decoration: const InputDecoration(labelText: 'Maksimal narx'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'O\'rtacha vaqt (5 kun)'),
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
              if (typeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xizmat turini kiriting')),
                );
                return;
              }
              try {
                final service = ServiceModel(
                  id: '',
                  tailorId: tailorId,
                  type: typeController.text,
                  minPrice: double.tryParse(minPriceController.text) ?? 0,
                  maxPrice: double.tryParse(maxPriceController.text) ?? 0,
                  avgTime: timeController.text,
                  createdAt: DateTime.now(),
                );
                await widget.userService.addService(service);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xizmat qo\'shildi!')),
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
            child: const Text('Qo\'shish'),
          ),
        ],
      ),
    );
  }
}

// ==================== CALENDAR PAGE ====================
class _CalendarPage extends StatefulWidget {
  final UserService userService;

  const _CalendarPage({required this.userService});

  @override
  State<_CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<_CalendarPage> {
  DateTime _currentMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tailorId = FirebaseAuth.instance.currentUser?.uid;
    if (tailorId == null) return const Center(child: Text('Xatolik'));

    return Scaffold(
      appBar: AppBar(
        title: Text('Kalendar', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Oy navigatsiyasi
          Container(
            padding: const EdgeInsets.all(16),
            color: primaryColor.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  _getMonthName(_currentMonth),
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Hafta kunlari
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya']
                  .map((day) => Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Kalendar
          Expanded(
            child: StreamBuilder<List<DateTime>>(
              stream: widget.userService.getBusyDays(tailorId),
              builder: (context, snapshot) {
                final busyDays = snapshot.data ?? [];
                return _buildCalendarGrid(tailorId, busyDays);
              },
            ),
          ),

          // Izoh
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Band kun'),
                const SizedBox(width: 24),
                const Text('Kunni bosing - band/bo\'sh qilish'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(String tailorId, List<DateTime> busyDays) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = (firstDay.weekday - 1) % 7;

    final days = <Widget>[];

    // Bo'sh kunlar
    for (int i = 0; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    // Oy kunlari
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isBusy = busyDays.any((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);
      final isToday = _isToday(date);
      final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

      days.add(
        GestureDetector(
          onTap: isPast
              ? null
              : () async {
                  if (isBusy) {
                    await widget.userService.removeBusyDay(tailorId, date);
                  } else {
                    await widget.userService.addBusyDay(tailorId, date);
                  }
                },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isBusy
                  ? Colors.red.withValues(alpha: 0.3)
                  : isToday
                      ? primaryColor.withValues(alpha: 0.2)
                      : null,
              border: isToday
                  ? Border.all(color: primaryColor, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isPast ? Colors.grey[400] : Colors.black87,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.all(8),
      children: days,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ==================== PORTFOLIO PAGE ====================
class _PortfolioPage extends StatefulWidget {
  @override
  State<_PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<_PortfolioPage> {
  final _storageService = StorageService();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(bool fromCamera) async {
    final tailorId = FirebaseAuth.instance.currentUser?.uid;
    if (tailorId == null) return;

    setState(() => _isUploading = true);

    try {
      final file = fromCamera
          ? await _storageService.takePhoto()
          : await _storageService.pickImage();

      if (file == null) {
        setState(() => _isUploading = false);
        return;
      }

      await _storageService.uploadPortfolioImage(
        tailorId: tailorId,
        file: file,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rasm yuklandi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: primaryColor),
                title: const Text('Galereyadan tanlash'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: primaryColor),
                title: const Text('Kameradan olish'),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndUploadImage(true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tailorId = FirebaseAuth.instance.currentUser?.uid;
    if (tailorId == null) return const Center(child: Text('Xatolik'));

    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _showImageOptions,
        backgroundColor: _isUploading ? Colors.grey : primaryColor,
        child: _isUploading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.add_photo_alternate),
      ),
      body: StreamBuilder<List<PortfolioImage>>(
        stream: _storageService.getPortfolioImages(tailorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final images = snapshot.data ?? [];

          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Portfolio rasmlarini yuklang',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maksimum 10 ta rasm',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Rasm soni ko'rsatish
              Container(
                padding: const EdgeInsets.all(12),
                color: primaryColor.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo, size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      '${images.length}/10 rasm',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return _PortfolioImageCard(
                      image: image,
                      tailorId: tailorId,
                      storageService: _storageService,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PortfolioImageCard extends StatelessWidget {
  final PortfolioImage image;
  final String tailorId;
  final StorageService storageService;

  const _PortfolioImageCard({
    required this.image,
    required this.tailorId,
    required this.storageService,
  });

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rasmni o\'chirish'),
        content: const Text('Bu rasmni o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await storageService.deletePortfolioImage(tailorId, image.id, image.url);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rasm o\'chirildi')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullImage(context),
      onLongPress: () => _confirmDelete(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: image.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  onPressed: () => _confirmDelete(context),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: image.url,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== PROFILE PAGE ====================
class _TailorProfilePage extends StatelessWidget {
  final UserModel? user;
  final AuthService authService;

  const _TailorProfilePage({required this.user, required this.authService});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profil', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                user!.name.isNotEmpty ? user!.name.substring(0, 1).toUpperCase() : 'C',
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user!.name.isNotEmpty ? user!.name : 'Chevar',
              style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (user!.address != null && user!.address!.isNotEmpty)
              Text(user!.address!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: primaryColor),
                    title: const Text('Email'),
                    subtitle: Text(user!.email.isNotEmpty ? user!.email : 'Ko\'rsatilmagan'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone, color: primaryColor),
                    title: const Text('Telefon'),
                    subtitle: Text(user!.phone.isNotEmpty ? user!.phone : 'Ko\'rsatilmagan'),
                  ),
                  if (user!.experienceYears != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.work, color: primaryColor),
                      title: const Text('Tajriba'),
                      subtitle: Text('${user!.experienceYears} yil'),
                    ),
                  ],
                  if (user!.address != null && user!.address!.isNotEmpty) ...[
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
                label: Text(AppLocalizations.of(context).tr('logout'), style: const TextStyle(color: Colors.red)),
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

  void _showLogoutConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tr('logout')),
        content: Text(l10n.tr('logoutConfirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authService.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.tr('yesLogout')),
          ),
        ],
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

// ==================== TAILOR CHATS PAGE ====================
class _TailorChatsPage extends StatelessWidget {
  final _chatService = ChatService();

  _TailorChatsPage();

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return const Center(child: Text('Xatolik'));

    return Scaffold(
      appBar: AppBar(
        title: Text('Xabarlar', style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _chatService.getUserChats(currentUserId),
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
                  Text('Xatolik: ${snapshot.error}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Hali xabarlar yo\'q',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mijozlar sizga yozganda bu yerda ko\'rinadi',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherName = chat.clientName;
              final otherUserId = chat.clientId;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor,
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : 'M',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  chat.lastMessage ?? 'Yangi suhbat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: chat.lastMessageAt != null
                    ? Text(
                        _formatDate(chat.lastMessageAt!),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chat.id,
                        otherUserName: otherName,
                        otherUserId: otherUserId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}.${date.month}';
  }
}
