import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'rooms';

  // Add a new room listing
  Future<String> addRoom(Room room) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(room.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding room: $e');
    }
  }

  // Get all room listings
  Stream<List<Room>> getRooms() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    });
  }

  // Get a single room by ID
  Future<Room?> getRoomById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return Room.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting room: $e');
    }
  }

  // Update a room listing
  Future<void> updateRoom(String id, Room room) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .update(room.toMap());
    } catch (e) {
      throw Exception('Error updating room: $e');
    }
  }

  // Delete a room listing
  Future<void> deleteRoom(String id) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Error deleting room: $e');
    }
  }
}
