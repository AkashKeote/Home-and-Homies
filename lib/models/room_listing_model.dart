import 'package:cloud_firestore/cloud_firestore.dart';

class RoomListingModel {
  final String? id;
  final double rent;
  final String location;
  final Map<String, dynamic> preferences;
  final List<String> photos;
  final DateTime createdAt;

  RoomListingModel({
    this.id,
    required this.rent,
    required this.location,
    required this.preferences,
    required this.photos,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'rent': rent,
      'location': location,
      'preferences': preferences,
      'photos': photos,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory RoomListingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return RoomListingModel(
      id: snapshot.id,
      rent: (data['rent'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      photos: List<String>.from(data['photos'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Helper getters for preferences
  bool get hasWifi => preferences['wifi'] ?? false;
  bool get hasAC => preferences['ac'] ?? false;
  bool get isFurnished => preferences['furnished'] ?? false;
}
