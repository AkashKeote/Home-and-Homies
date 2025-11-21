import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String? id;
  final double rent;
  final String location;
  final String preferences;
  final List<String> photos;

  Room({
    this.id,
    required this.rent,
    required this.location,
    required this.preferences,
    required this.photos,
  });

  // Convert Room to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'rent': rent,
      'location': location,
      'preferences': preferences,
      'photos': photos,
    };
  }

  // Create Room from Firestore document
  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      rent: (data['rent'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      preferences: data['preferences'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
    );
  }

  // Create Room from Map
  factory Room.fromMap(Map<String, dynamic> map, String id) {
    return Room(
      id: id,
      rent: (map['rent'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      preferences: map['preferences'] ?? '',
      photos: List<String>.from(map['photos'] ?? []),
    );
  }
}
