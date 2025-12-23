"""
TailorMatch - Diploma Thesis Generator (Part 4: Chapter 3 - Implementation)
Continue from Part 3
"""

# ==================== CHAPTER 3: IMPLEMENTATION ====================
doc.add_heading("3. Implementation of TailorMatch Application", 1)

# 3.1 Development Environment
doc.add_heading("3.1. Development Environment Setup", 2)

setup_text = """The development environment configuration is fundamental to a successful project. TailorMatch development utilized the following toolchain:

Development Tools:

IDE: Visual Studio Code
    - Flutter extension for Dart language support
    - Dart DevTools for debugging
    - Git integration for version control

Flutter SDK: Version 3.x (Stable Channel)
    - Dart SDK included
    - Hot reload/restart capabilities
    - Platform-specific build tools

Firebase CLI:
    - Project initialization
    - Firestore emulator for local development
    - Deployment management

Project Initialization:

The project was initialized with standard Flutter template:

flutter create seamstress --org com.tailormatch

Firebase integration followed Google's official FlutterFire setup:

1. Firebase project created in Firebase Console ("seamstress-e737e")
2. FlutterFire CLI used for platform configuration:
   flutterfire configure
3. firebase_options.dart generated with project credentials

Dependencies (pubspec.yaml):

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0
  provider: ^6.1.1
  intl: ^0.18.1
  image_picker: ^1.0.0

Application Entry Point (main.dart):

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

The initialization ensures Firebase is ready before the UI renders and configures Firestore offline persistence for resilient operation during network interruptions."""

add_paragraph_justified(doc, setup_text)

# 3.2 Authentication
doc.add_heading("3.2. Authentication Module Implementation", 2)

auth_text = """The authentication module handles user registration, login, and session management using Firebase Authentication.

AuthService Implementation:

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<UserCredential> createAccount({
    required String name,
    required String email,
    required String password,
    required String role,
    String? address,
    String? phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'id': credential.user!.uid,
      'name': name,
      'email': email,
      'role': role,
      'address': address,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return credential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

Authentication State Management:

The AuthWrapper widget in main.dart manages routing based on authentication state:

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserModel?>(
            key: ValueKey(snapshot.data!.uid),
            future: _authService.getCurrentUserData(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }
              
              final user = userSnapshot.data;
              if (user == null) return const AuthScreen();
              
              return user.role == 'tailor'
                  ? const TailorHomeScreen()
                  : const ClientHomeScreen();
            },
          );
        }
        
        return const AuthScreen();
      },
    );
  }
}

Login Screen Implementation:

The login screen provides email/password authentication with role selection for registration:

- Form validation for email format and password length
- Toggle between login and registration modes
- Role selection (Client/Tailor) during registration
- Error message display for authentication failures
- Smooth transitions with loading indicators

Logout Confirmation:

To prevent accidental logouts, a confirmation dialog is implemented:

void _showLogoutConfirmation(BuildContext context) {
  final l = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.tr('logoutConfirmation')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.tr('cancel')),
        ),
        TextButton(
          onPressed: () async {
            await _authService.signOut();
            Navigator.pop(context);
          },
          child: Text(l.tr('yesLogout'), 
            style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}"""

add_paragraph_justified(doc, auth_text)

# 3.3 User Profile
doc.add_heading("3.3. User Profile and Service Management", 2)

profile_text = """User profiles and service management form the core of the platform's value proposition.

UserModel Implementation:

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? address;
  final String? phone;
  final String? avatar;
  final int? experienceYears;
  final double? averageRating;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.address,
    this.phone,
    this.avatar,
    this.experienceYears,
    this.averageRating,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      address: map['address'],
      phone: map['phone'],
      avatar: map['avatar'],
      experienceYears: map['experienceYears'],
      averageRating: (map['averageRating'] as num?)?.toDouble(),
    );
  }
}

UserService - Tailor Discovery:

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getTailors() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'tailor')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ServiceModel>> getTailorServices(String tailorId) {
    return _firestore
        .collection('users')
        .doc(tailorId)
        .collection('services')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

Service Management (Tailor):

Tailors can add services through a dialog form:

void _showAddServiceDialog() {
  String type = '';
  String minPrice = '';
  String maxPrice = '';
  String avgTime = '';

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.tr('addService')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: l.tr('serviceType')),
            onChanged: (v) => type = v,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: l.tr('minPrice')),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => minPrice = v,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: l.tr('maxPrice')),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => maxPrice = v,
                ),
              ),
            ],
          ),
          TextField(
            decoration: InputDecoration(labelText: l.tr('avgTime')),
            onChanged: (v) => avgTime = v,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: () async {
            await _userService.addService(
              tailorId: user!.id,
              type: type,
              priceRange: '$minPrice - $maxPrice so\\'m',
              avgTime: avgTime,
            );
            Navigator.pop(context);
          },
          child: Text(l.tr('add')),
        ),
      ],
    ),
  );
}

Profile Editing:

Users can edit their profile information including name and region (viloyat):

void _showEditProfileDialog() {
  final regions = [
    'Toshkent shahri', 'Toshkent viloyati', 'Samarqand',
    'Buxoro', 'Farg\\'ona', 'Andijon', 'Namangan',
    'Qashqadaryo', 'Surxondaryo', 'Jizzax', 'Sirdaryo',
    'Navoiy', 'Xorazm', 'Qoraqalpog\\'iston',
  ];
  
  String selectedRegion = user?.address ?? regions.first;
  
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Profilni tahrirlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Ism'),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRegion,
              decoration: InputDecoration(labelText: 'Viloyat'),
              items: regions.map((r) => 
                DropdownMenuItem(value: r, child: Text(r))
              ).toList(),
              onChanged: (v) => setState(() => selectedRegion = v!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.id)
                  .update({
                'name': nameController.text,
                'address': selectedRegion,
              });
              Navigator.pop(context);
            },
            child: Text('Saqlash'),
          ),
        ],
      ),
    ),
  );
}"""

add_paragraph_justified(doc, profile_text)

# 3.4 Chat System
doc.add_heading("3.4. Real-Time Chat System", 2)

chat_text = """The real-time chat system enables direct communication between clients and tailors using Firestore's real-time capabilities.

ChatModel and MessageModel:

class ChatModel {
  final String id;
  final String clientId;
  final String tailorId;
  final String clientName;
  final String tailorName;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  ChatModel({...});

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      clientId: map['clientId'] ?? '',
      tailorId: map['tailorId'] ?? '',
      clientName: map['clientName'] ?? '',
      tailorName: map['tailorName'] ?? '',
      lastMessage: map['lastMessage'],
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  MessageModel({...});
}

ChatService Implementation:

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ChatModel> getOrCreateChat({
    required String clientId,
    required String tailorId,
    required String clientName,
    required String tailorName,
  }) async {
    final chatId = '${clientId}_$tailorId';
    final chatRef = _firestore.collection('chats').doc(chatId);
    
    final doc = await chatRef.get();
    if (doc.exists) {
      return ChatModel.fromMap(doc.data()!, doc.id);
    }
    
    final chatData = {
      'id': chatId,
      'clientId': clientId,
      'tailorId': tailorId,
      'clientName': clientName,
      'tailorName': tailorName,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    await chatRef.set(chatData);
    return ChatModel.fromMap(chatData, chatId);
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await messageRef.set({
      'id': messageRef.id,
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where(Filter.or(
          Filter('clientId', isEqualTo: userId),
          Filter('tailorId', isEqualTo: userId),
        ))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

ChatScreen UI:

The chat screen displays messages in a conversation format:

- Messages styled differently for sent (right, primary color) vs received (left, gray)
- Real-time updates via StreamBuilder
- Auto-scroll to latest message
- Text input with send button
- Timestamp display for messages"""

add_paragraph_justified(doc, chat_text)

# 3.5 Order Management
doc.add_heading("3.5. Order Management System", 2)

order_text = """The order management system tracks the lifecycle of service requests from creation to completion.

OrderModel Implementation:

class OrderModel {
  final String id;
  final String clientId;
  final String tailorId;
  final String serviceName;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? rating;

  static const statusNew = 'pending';
  static const statusMeetingScheduled = 'meetingScheduled';
  static const statusInProgress = 'inProgress';
  static const statusFittingScheduled = 'fittingScheduled';
  static const statusReady = 'ready';
  static const statusCompleted = 'completed';
  static const statusCancelled = 'cancelled';
}

OrderService Implementation:

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder({
    required String clientId,
    required String tailorId,
    required String serviceId,
    required String serviceName,
  }) async {
    await _firestore.collection('orders').add({
      'clientId': clientId,
      'tailorId': tailorId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> getTailorOrders(String tailorId) {
    return _firestore
        .collection('orders')
        .where('tailorId', isEqualTo: tailorId)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
              .toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

Tailor Dashboard with Status Tabs:

The tailor dashboard categorizes orders into four tabs:

class _TailorDashboard extends StatefulWidget {
  @override
  State<_TailorDashboard> createState() => _TailorDashboardState();
}

class _TailorDashboardState extends State<_TailorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Yangi'),
            Tab(text: 'Jarayonda'),
            Tab(text: 'Tayyor'),
            Tab(text: 'Yakunlangan'),
          ],
        ),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: widget.orderService.getTailorOrders(tailorId),
            builder: (context, snapshot) {
              final orders = snapshot.data ?? [];
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOrderList(orders.where((o) => 
                    o.status == 'pending' || 
                    o.status == 'meetingScheduled').toList()),
                  _buildOrderList(orders.where((o) => 
                    o.status == 'inProgress' || 
                    o.status == 'fittingScheduled').toList()),
                  _buildOrderList(orders.where((o) => 
                    o.status == 'ready').toList()),
                  _buildOrderList(orders.where((o) => 
                    o.status == 'completed' || 
                    o.status == 'cancelled').toList()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}"""

add_paragraph_justified(doc, order_text)

# 3.6 Rating System
doc.add_heading("3.6. Rating and Review System", 2)

rating_text = """The multi-aspect rating system follows Yandex-style evaluation, allowing clients to rate tailors on five specific aspects.

Rating Aspects:

1. Quality (Sifat) - Workmanship and finish quality
2. Size (Hajm) - Accuracy of measurements and fit  
3. Speed (Tezlik) - Timely completion of order
4. Service (Muomala) - Customer service and communication
5. Price (Narx) - Value for money

Rating Implementation:

void _showRatingDialog(OrderModel order) {
  final ratings = <String, int>{
    'quality': 0,
    'size': 0,
    'speed': 0,
    'service': 0,
    'price': 0,
  };

  final icons = {
    'quality': Icons.star,
    'size': Icons.straighten,
    'speed': Icons.speed,
    'service': Icons.handshake,
    'price': Icons.attach_money,
  };

  final labels = {
    'quality': 'Sifat',
    'size': 'Hajm',
    'speed': 'Tezlik',
    'service': 'Muomala',
    'price': 'Narx',
  };

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Baho bering'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ratings.keys.map((key) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icons[key], size: 20),
                        SizedBox(width: 8),
                        Text(labels[key]!),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        return IconButton(
                          icon: Icon(
                            i < ratings[key]! 
                              ? Icons.star 
                              : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () => 
                            setState(() => ratings[key] = i + 1),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor'),
          ),
          ElevatedButton(
            onPressed: () async {
              final avg = ratings.values.reduce((a, b) => a + b) / 5;
              await _orderService.addRating(
                orderId: order.id,
                rating: {...ratings, 'average': avg},
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Baho qabul qilindi!')),
              );
            },
            child: Text('Yuborish'),
          ),
        ],
      ),
    ),
  );
}

Rating Display:

Ratings are displayed using chip widgets showing the average or individual aspect scores."""

add_paragraph_justified(doc, rating_text)

# 3.7 Multilingual Support
doc.add_heading("3.7. Multilingual Support Implementation", 2)

l10n_text = """The application supports three languages: Uzbek (O'zbekcha), Russian (Русский), and English.

LocaleProvider Implementation:

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('uz');
  
  Locale get locale => _locale;
  
  void setLanguage(String code) {
    _locale = Locale(code);
    notifyListeners();
  }
}

AppLocalizations:

class AppLocalizations {
  final Locale locale;
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'orders': 'Buyurtmalar',
      'services': 'Xizmatlar',
      'messages': 'Xabarlar',
      'calendar': 'Kalendar',
      'profile': 'Profil',
      'tailors': 'Chevarlar',
      'logout': 'Chiqish',
      'logoutConfirmation': 'Rostan ham chiqishni xohlaysizmi?',
      'cancel': 'Bekor',
      'yesLogout': 'Ha, chiqish',
      // ... more translations
    },
    'ru': {
      'orders': 'Заказы',
      'services': 'Услуги',
      'messages': 'Сообщения',
      'calendar': 'Календарь',
      'profile': 'Профиль',
      'tailors': 'Портные',
      'logout': 'Выйти',
      'logoutConfirmation': 'Вы действительно хотите выйти?',
      'cancel': 'Отмена',
      'yesLogout': 'Да, выйти',
      // ... more translations
    },
    'en': {
      'orders': 'Orders',
      'services': 'Services',
      'messages': 'Messages',
      'calendar': 'Calendar',
      'profile': 'Profile',
      'tailors': 'Tailors',
      'logout': 'Logout',
      'logoutConfirmation': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'yesLogout': 'Yes, logout',
      // ... more translations
    },
  };
  
  String tr(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

Language Selector UI:

The profile screen includes a language selection dialog with flag emojis for visual identification of languages."""

add_paragraph_justified(doc, l10n_text)

# 3.8 Summary
doc.add_heading("3.8. Summary", 2)

summary3 = """Chapter 3 has detailed the implementation of the TailorMatch application:

The Development Environment was configured with Flutter SDK, Firebase CLI, and Visual Studio Code, with proper dependency management through pubspec.yaml.

The Authentication Module uses Firebase Authentication with email/password, integrated with Firestore for user profile storage. AuthWrapper manages routing based on authentication state and user role.

User Profile and Service Management enables tailors to create and manage services while clients can browse tailor profiles. Profile editing supports name and region (viloyat) updates.

The Real-Time Chat System uses Firestore subcollections for message storage with real-time streaming for instant message delivery. Both clients and tailors have dedicated chat interfaces.

The Order Management System implements a complete workflow with status tracking displayed in a four-tab interface (New, In Progress, Ready, Completed) for tailors.

The Rating System implements Yandex-style multi-aspect evaluation with five criteria (quality, size, speed, service, price), each rated on a five-star scale.

Multilingual Support provides full localization for Uzbek, Russian, and English through a custom localization system with Provider-based locale management.

The next chapter will present the testing methodology and evaluation of the implemented system."""

add_paragraph_justified(doc, summary3)

add_page_break(doc)

# Save Part 4
doc.save('/content/TailorMatch_Thesis_Part4.docx')
print("✅ Part 4 (Chapter 3) saved successfully!")
print("Now run Part 5 code...")
