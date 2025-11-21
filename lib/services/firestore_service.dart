import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_listing_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'rooms';

  // Get rooms collection reference
  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore.collection(_collectionName);

  // Add a new room listing
  Future<String> addRoomListing(RoomListingModel room) async {
    try {
      final docRef = await _roomsCollection.add(room.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add room listing: $e');
    }
  }

  // Get all room listings
  Stream<List<RoomListingModel>> getRoomListings() {
    return _roomsCollection
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => RoomListingModel.fromFirestore(doc))
          .toList();
      // Sort by createdAt in memory (client-side)
      rooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return rooms;
    });
  }

  // Get a single room listing by ID
  Future<RoomListingModel?> getRoomListingById(String id) async {
    try {
      final doc = await _roomsCollection.doc(id).get();
      if (doc.exists) {
        return RoomListingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get room listing: $e');
    }
  }

  // Update a room listing
  Future<void> updateRoomListing(String id, RoomListingModel room) async {
    try {
      await _roomsCollection.doc(id).update(room.toFirestore());
    } catch (e) {
      throw Exception('Failed to update room listing: $e');
    }
  }

  // Delete a room listing
  Future<void> deleteRoomListing(String id) async {
    try {
      await _roomsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete room listing: $e');
    }
  }
}
