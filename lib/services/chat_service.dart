import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new user
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toFirestore());
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data()!);
    }
    return null;
  }

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromFirestore(doc.data()))
              .toList(),
        );
  }

  // Create a new chat
  Future<String> createChat(Chat chat) async {
    final docRef = await _firestore.collection('chats').add(chat.toFirestore());
    
    // Update each participant's chat list
    for (String participantId in chat.participantIds) {
      await _firestore.collection('users').doc(participantId).update({
        'chats': FieldValue.arrayUnion([docRef.id])
      });
    }
    
    return docRef.id;
  }

  // Get chat by ID
  Future<Chat?> getChat(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id; // Add the document ID
      return Chat.fromFirestore(data);
    }
    return null;
  }

  // Stream chat messages in real-time
  Stream<Chat> getChatStream(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return Chat.fromFirestore(data);
      }
      throw Exception('Chat not found');
    });
  }

  // Send a message (add to Firestore)
  Future<void> sendMessage(String chatId, Message message) async {
    await _firestore.collection('chats').doc(chatId).update({
      'messages': FieldValue.arrayUnion([message.toMap()]),
      'lastMessageAt': message.timestamp.toIso8601String(),
    });
  }

  // Get user's chats
  Stream<List<Chat>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Chat.fromFirestore(data);
          }).toList(),
        );
  }

  // Seed initial data (for testing)
  Future<void> seedInitialData() async {
    // Check if users already exist
    final usersSnapshot = await _firestore.collection('users').limit(1).get();
    if (usersSnapshot.docs.isNotEmpty) {
      print('Users already exist, skipping seed data');
      return;
    }

    print('Seeding initial chat data...');

    // Create two users
    final user1 = UserModel(
      id: 'user1',
      name: 'Akash Kumar',
      email: 'akash@example.com',
      chats: [],
      createdAt: DateTime.now(),
    );

    final user2 = UserModel(
      id: 'user2',
      name: 'Priya Sharma',
      email: 'priya@example.com',
      chats: [],
      createdAt: DateTime.now(),
    );

    await createUser(user1);
    await createUser(user2);

    // Create a chat with some dummy messages
    final now = DateTime.now();
    final chat = Chat(
      id: '',
      participantIds: ['user1', 'user2'],
      participantNames: ['Akash Kumar', 'Priya Sharma'],
      messages: [
        Message(
          id: 'msg1',
          content: 'Hey! I saw your room listing. Is it still available?',
          userId: 'user2',
          userName: 'Priya Sharma',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
        Message(
          id: 'msg2',
          content: 'Yes, it is! Would you like to know more about it?',
          userId: 'user1',
          userName: 'Akash Kumar',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 55)),
        ),
        Message(
          id: 'msg3',
          content: 'Sure! What are the nearby facilities?',
          userId: 'user2',
          userName: 'Priya Sharma',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 50)),
        ),
        Message(
          id: 'msg4',
          content: 'There\'s a park, metro station, and supermarket within 5 minutes walk. Plus WiFi and AC included!',
          userId: 'user1',
          userName: 'Akash Kumar',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        ),
        Message(
          id: 'msg5',
          content: 'That sounds perfect! When can I visit?',
          userId: 'user2',
          userName: 'Priya Sharma',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 40)),
        ),
      ],
      createdAt: now.subtract(const Duration(hours: 2)),
      lastMessageAt: now.subtract(const Duration(hours: 1, minutes: 40)),
    );

    await createChat(chat);

    print('✅ Chat seed data created successfully!');
  }
}
