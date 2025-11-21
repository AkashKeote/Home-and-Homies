import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDummyRooms() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference rooms = firestore.collection('rooms');

  // Check if data already exists
  final snapshot = await rooms.limit(1).get();
  if (snapshot.docs.isNotEmpty) {
    print('Data already exists in Firestore. Skipping seed.');
    return;
  }

  print('Seeding dummy room data to Firestore...');

  final List<Map<String, dynamic>> dummyRooms = [
    {
      'rent': 15000.0,
      'location': 'Koramangala, Bangalore',
      'preferences': {
        'wifi': true,
        'ac': true,
        'furnished': true,
      },
      'photos': [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'rent': 12000.0,
      'location': 'Indiranagar, Bangalore',
      'preferences': {
        'wifi': true,
        'ac': false,
        'furnished': true,
      },
      'photos': [
        'https://images.unsplash.com/photo-1556020685-ae41abfc9365?w=800',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'rent': 18000.0,
      'location': 'Whitefield, Bangalore',
      'preferences': {
        'wifi': true,
        'ac': true,
        'furnished': true,
      },
      'photos': [
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'rent': 10000.0,
      'location': 'HSR Layout, Bangalore',
      'preferences': {
        'wifi': true,
        'ac': false,
        'furnished': false,
      },
      'photos': [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'rent': 20000.0,
      'location': 'MG Road, Bangalore',
      'preferences': {
        'wifi': true,
        'ac': true,
        'furnished': true,
      },
      'photos': [
        'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=800',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'rent': 13500.0,
      'location': 'Jayanagar, Bangalore',
      'preferences': {
        'wifi': true,
        'ac': true,
        'furnished': false,
      },
      'photos': [
        'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=800',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'rent': 16000.0,
      'location': 'Electronic City, Bangalore',
      'preferences': {
        'wifi': true,
        'ac': true,
        'furnished': true,
      },
      'photos': [
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'rent': 11000.0,
      'location': 'BTM Layout, Bangalore',
      'preferences': {
        'wifi': true,
        'ac': false,
        'furnished': true,
      },
      'photos': [
        'https://images.unsplash.com/photo-1481277542470-605612bd2d61?w=800',
      ],
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  try {
    for (var room in dummyRooms) {
      await rooms.add(room);
    }
    print('Successfully seeded ${dummyRooms.length} rooms to Firestore!');
  } catch (e) {
    print('Error seeding data: $e');
  }
}
