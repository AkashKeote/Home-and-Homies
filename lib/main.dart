import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/room_listing_model.dart';
import 'services/firestore_service.dart';
import 'services/compatibility_service.dart';
import 'services/chat_service.dart';
import 'screens/add_room_screen.dart';
import 'screens/chat_screen.dart';
import 'seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Seed dummy data on first run
  await seedDummyRooms();
  
  // Seed chat data
  final chatService = ChatService();
  await chatService.seedInitialData();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homes N Homies',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB5C7F7)),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const RoomListingsScreen(),
    );
  }
}

// Model for Room Listing
class RoomListing {
  final String imageUrl;
  final double monthlyRent;
  final String location;
  final bool hasWifi;
  final bool hasAC;
  final bool isFurnished;

  RoomListing({
    required this.imageUrl,
    required this.monthlyRent,
    required this.location,
    required this.hasWifi,
    required this.hasAC,
    required this.isFurnished,
  });
}

class RoomListingsScreen extends StatefulWidget {
  const RoomListingsScreen({super.key});

  @override
  State<RoomListingsScreen> createState() => _RoomListingsScreenState();
}

class _RoomListingsScreenState extends State<RoomListingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  double _minRent = 5000;
  double _maxRent = 50000;
  bool _showFilters = false;
  bool _showCompatibility = true;
  
  // Current user preferences for compatibility matching
  final Map<String, int> _userPreferences = {
    'cleanliness': 4,
    'introvert': 3,
    'loudness': 2,
  };
  
  // Keep dummy data as fallback
  static final List<RoomListing> _dummyRoomListings = [
    RoomListing(
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      monthlyRent: 15000,
      location: 'Koramangala, Bangalore',
      hasWifi: true,
      hasAC: true,
      isFurnished: true,
    ),
    RoomListing(
      imageUrl: 'https://images.unsplash.com/photo-1556020685-ae41abfc9365?w=800',
      monthlyRent: 12000,
      location: 'Indiranagar, Bangalore',
      hasWifi: true,
      hasAC: false,
      isFurnished: true,
    ),
    RoomListing(
      imageUrl: 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      monthlyRent: 18000,
      location: 'Whitefield, Bangalore',
      hasWifi: true,
      hasAC: true,
      isFurnished: true,
    ),
    RoomListing(
      imageUrl: 'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800',
      monthlyRent: 10000,
      location: 'HSR Layout, Bangalore',
      hasWifi: true,
      hasAC: false,
      isFurnished: false,
    ),
    RoomListing(
      imageUrl: 'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800',
      monthlyRent: 20000,
      location: 'MG Road, Bangalore',
      hasWifi: true,
      hasAC: true,
      isFurnished: true,
    ),
    RoomListing(
      imageUrl: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800',
      monthlyRent: 13500,
      location: 'Jayanagar, Bangalore',
      hasWifi: true,
      hasAC: true,
      isFurnished: false,
    ),
    RoomListing(
      imageUrl: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
      monthlyRent: 16000,
      location: 'Electronic City, Bangalore',
      hasWifi: true,
      hasAC: true,
      isFurnished: true,
    ),
    RoomListing(
      imageUrl: 'https://images.unsplash.com/photo-1481277542470-605612bd2d61?w=800',
      monthlyRent: 11000,
      location: 'BTM Layout, Bangalore',
      hasWifi: true,
      hasAC: false,
      isFurnished: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Pastel Design
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFFF7F6F2).withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB5C7F7).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Logo Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFB5C7F7),
                              const Color(0xFF9FB3E8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB5C7F7).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Homes N Homies',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF22223B),
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'Find your perfect room',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Compatibility Toggle
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _showCompatibility
                                ? [
                                    const Color(0xFF8BC34A),
                                    const Color(0xFF7CB342),
                                  ]
                                : [
                                    Colors.grey.shade300,
                                    Colors.grey.shade400,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: (_showCompatibility ? const Color(0xFF8BC34A) : Colors.grey).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showCompatibility = !_showCompatibility;
                            });
                          },
                          child: Icon(
                            _showCompatibility ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Chat Icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatScreen(
                                chatId: 'chat1',
                                currentUserId: 'user1',
                                currentUserName: 'Akash Kumar',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE8D5C4),
                                Color(0xFFD4C4B8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE8D5C4).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chat_bubble_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Filter Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF9E79F),
                              const Color(0xFFFFD98E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF9E79F).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF22223B),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFB5C7F7).withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB5C7F7).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by location...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: const Color(0xFFB5C7F7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Filter Toggle Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE8D5C4).withOpacity(0.3),
                            const Color(0xFFF9E79F).withOpacity(0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE8D5C4).withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                color: const Color(0xFF22223B),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Filter by Rent Range',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _showFilters
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: const Color(0xFF22223B),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Expandable Filter Controls
                  if (_showFilters) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFB5C7F7).withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB5C7F7).withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Min Rent Slider
                          Text(
                            'Minimum Rent: ₹${_minRent.toInt()}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFFB5C7F7),
                              inactiveTrackColor:
                                  const Color(0xFFB5C7F7).withOpacity(0.2),
                              thumbColor: const Color(0xFFB5C7F7),
                              overlayColor:
                                  const Color(0xFFB5C7F7).withOpacity(0.2),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _minRent,
                              min: 5000,
                              max: 50000,
                              divisions: 45,
                              onChanged: (value) {
                                setState(() {
                                  _minRent = value;
                                  if (_minRent > _maxRent) {
                                    _maxRent = _minRent;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Max Rent Slider
                          Text(
                            'Maximum Rent: ₹${_maxRent.toInt()}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF8BC34A),
                              inactiveTrackColor:
                                  const Color(0xFF8BC34A).withOpacity(0.2),
                              thumbColor: const Color(0xFF8BC34A),
                              overlayColor:
                                  const Color(0xFF8BC34A).withOpacity(0.2),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _maxRent,
                              min: 5000,
                              max: 50000,
                              divisions: 45,
                              onChanged: (value) {
                                setState(() {
                                  _maxRent = value;
                                  if (_maxRent < _minRent) {
                                    _minRent = _maxRent;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Range Display
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF9E79F).withOpacity(0.2),
                                  const Color(0xFFFFD98E).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.currency_rupee_rounded,
                                  size: 16,
                                  color: const Color(0xFF22223B),
                                ),
                                Text(
                                  '${_minRent.toInt()} - ${_maxRent.toInt()} per month',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF22223B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section Title with Add Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Available Rooms',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<List<RoomListingModel>>(
                    stream: _firestoreService.getRoomListings(),
                    builder: (context, snapshot) {
                      final count = snapshot.hasData ? snapshot.data!.length : _dummyRoomListings.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFB5C7F7).withOpacity(0.2),
                              const Color(0xFFD6EAF8).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFB5C7F7).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$count rooms',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB5C7F7),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  // Add Room Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8BC34A),
                          Color(0xFF7CB342),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8BC34A).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddRoomScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Listings with Firestore StreamBuilder
            Expanded(
              child: StreamBuilder<List<RoomListingModel>>(
                stream: _firestoreService.getRoomListings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFB5C7F7),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading rooms',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final allRooms = snapshot.data ?? [];
                  
                  // Filter rooms by rent range
                  final rooms = allRooms.where((room) {
                    return room.rent >= _minRent && room.rent <= _maxRent;
                  }).toList();

                  if (rooms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB5C7F7).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              size: 64,
                              color: Color(0xFFB5C7F7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            allRooms.isEmpty
                                ? 'No rooms available yet'
                                : 'No rooms in this price range',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            allRooms.isEmpty
                                ? 'Tap the + button to add a new room'
                                : 'Try adjusting the rent range filter',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      return FirestoreRoomListingCard(
                        listing: rooms[index],
                        userPreferences: _showCompatibility ? _userPreferences : null,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Firestore Room Listing Card Component
class FirestoreRoomListingCard extends StatelessWidget {
  final RoomListingModel listing;
  final Map<String, int>? userPreferences;

  const FirestoreRoomListingCard({
    super.key, 
    required this.listing,
    this.userPreferences,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF7F6F2).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB5C7F7).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5C7F7).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Image with Favorite Button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  listing.photos.isNotEmpty 
                      ? listing.photos[0] 
                      : 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFB5C7F7).withOpacity(0.3),
                            const Color(0xFFD6EAF8).withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.home_rounded,
                          size: 64,
                          color: Color(0xFFB5C7F7),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Favorite Button
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFB6C1).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB6C1).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFFFFB6C1),
                    size: 20,
                  ),
                ),
              ),
              // Price Tag
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB5C7F7),
                        const Color(0xFF9FB3E8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB5C7F7).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.currency_rupee_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      Text(
                        '${listing.rent.toStringAsFixed(0)}/mo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Compatibility Score Badge
              if (userPreferences != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Builder(
                    builder: (context) {
                      // Calculate compatibility score
                      final roommatePrefs = <String, int>{};
                      final prefs = listing.preferences;
                      
                      // Extract numeric preferences for matching
                      if (prefs['cleanliness'] is int) roommatePrefs['cleanliness'] = prefs['cleanliness'];
                      if (prefs['introvert'] is int) roommatePrefs['introvert'] = prefs['introvert'];
                      if (prefs['loudness'] is int) roommatePrefs['loudness'] = prefs['loudness'];
                      
                      final score = CompatibilityService.calculateCompatibilityScore(
                        userPreferences!,
                        roommatePrefs,
                      );
                      
                      // Determine color based on score
                      Color scoreColor;
                      if (score >= 75) {
                        scoreColor = const Color(0xFF8BC34A); // Green
                      } else if (score >= 50) {
                        scoreColor = const Color(0xFFF9E79F); // Yellow
                      } else {
                        scoreColor = const Color(0xFFFF9800); // Orange
                      }
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: scoreColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: scoreColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${score.toStringAsFixed(0)}% Match',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
          
          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF9E79F).withOpacity(0.3),
                            const Color(0xFFFFD98E).withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF9E79F).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: Color(0xFFF9E79F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        listing.location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF22223B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Amenities Section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF7F6F2).withOpacity(0.5),
                        const Color(0xFFE8D5C4).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8D5C4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAmenityIcon(
                        icon: Icons.wifi_rounded,
                        label: 'WiFi',
                        isAvailable: listing.hasWifi,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _buildAmenityIcon(
                        icon: Icons.ac_unit_rounded,
                        label: 'AC',
                        isAvailable: listing.hasAC,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _buildAmenityIcon(
                        icon: Icons.weekend_rounded,
                        label: 'Furnished',
                        isAvailable: listing.isFurnished,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // View Details Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB5C7F7),
                        const Color(0xFF9FB3E8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB5C7F7).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle view details
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityIcon({
    required IconData icon,
    required String label,
    required bool isAvailable,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: isAvailable
                ? LinearGradient(
                    colors: [
                      const Color(0xFF8BC34A).withOpacity(0.3),
                      const Color(0xFF7CB342).withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.15),
                      Colors.grey.withOpacity(0.1),
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAvailable
                  ? const Color(0xFF8BC34A).withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: isAvailable
                ? [
                    BoxShadow(
                      color: const Color(0xFF8BC34A).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            icon,
            size: 22,
            color: isAvailable
                ? const Color(0xFF8BC34A)
                : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isAvailable
                ? const Color(0xFF22223B)
                : Colors.grey[500],
            fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// Reusable Room Listing Card Component (for dummy data)
class RoomListingCard extends StatelessWidget {
  final RoomListing listing;

  const RoomListingCard({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            const Color(0xFFF7F6F2).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFB5C7F7).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB5C7F7).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Image with Favorite Button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  listing.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFB5C7F7).withOpacity(0.3),
                            const Color(0xFFD6EAF8).withOpacity(0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.home_rounded,
                          size: 64,
                          color: Color(0xFFB5C7F7),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Favorite Button
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFB6C1).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB6C1).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFFFFB6C1),
                    size: 20,
                  ),
                ),
              ),
              // Price Tag
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB5C7F7),
                        const Color(0xFF9FB3E8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB5C7F7).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.currency_rupee_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      Text(
                        '${listing.monthlyRent.toStringAsFixed(0)}/mo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF9E79F).withOpacity(0.3),
                            const Color(0xFFFFD98E).withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFF9E79F).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: Color(0xFFF9E79F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        listing.location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF22223B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Amenities Section
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF7F6F2).withOpacity(0.5),
                        const Color(0xFFE8D5C4).withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8D5C4).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAmenityIcon(
                        icon: Icons.wifi_rounded,
                        label: 'WiFi',
                        isAvailable: listing.hasWifi,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _buildAmenityIcon(
                        icon: Icons.ac_unit_rounded,
                        label: 'AC',
                        isAvailable: listing.hasAC,
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                      _buildAmenityIcon(
                        icon: Icons.weekend_rounded,
                        label: 'Furnished',
                        isAvailable: listing.isFurnished,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // View Details Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB5C7F7),
                        const Color(0xFF9FB3E8),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB5C7F7).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle view details
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityIcon({
    required IconData icon,
    required String label,
    required bool isAvailable,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: isAvailable
                ? LinearGradient(
                    colors: [
                      const Color(0xFF8BC34A).withOpacity(0.3),
                      const Color(0xFF7CB342).withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.15),
                      Colors.grey.withOpacity(0.1),
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAvailable
                  ? const Color(0xFF8BC34A).withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: isAvailable
                ? [
                    BoxShadow(
                      color: const Color(0xFF8BC34A).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            icon,
            size: 22,
            color: isAvailable
                ? const Color(0xFF8BC34A)
                : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isAvailable
                ? const Color(0xFF22223B)
                : Colors.grey[500],
            fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
