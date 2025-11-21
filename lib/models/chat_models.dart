class UserModel {
  final String id;
  final String name;
  final String email;
  final List<String> chats; // List of chat IDs this user belongs to
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.chats,
    required this.createdAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'chats': chats,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> doc) {
    return UserModel(
      id: doc['id'] ?? '',
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      chats: List<String>.from(doc['chats'] ?? []),
      createdAt: DateTime.parse(doc['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? chats,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      chats: chats ?? this.chats,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Message {
  final String id;
  final String content;
  final String userId;
  final String userName;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Firestore map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert to JSON for Socket.IO
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from Socket.IO JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Chat {
  final String id;
  final List<String> participantIds;
  final List<String> participantNames;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  Chat({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.messages,
    required this.createdAt,
    required this.lastMessageAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory Chat.fromFirestore(Map<String, dynamic> doc) {
    return Chat(
      id: doc['id'] ?? '',
      participantIds: List<String>.from(doc['participantIds'] ?? []),
      participantNames: List<String>.from(doc['participantNames'] ?? []),
      messages: (doc['messages'] as List<dynamic>?)
              ?.map((m) => Message.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(doc['createdAt'] ?? DateTime.now().toIso8601String()),
      lastMessageAt: DateTime.parse(doc['lastMessageAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Get the other participant's name (for 1-on-1 chats)
  String getOtherParticipantName(String currentUserId) {
    final index = participantIds.indexOf(currentUserId);
    if (index == -1 || participantNames.isEmpty) return 'Unknown';
    
    // Return the other participant's name
    return participantNames[(index + 1) % participantNames.length];
  }
}
