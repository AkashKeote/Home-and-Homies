# Task 5 - Real-time Messaging with Socket.IO

## 📋 Task Completion Summary

### ✅ Requirements Met

1. **Chat UI Screen**
   - ✅ Left/right aligned message bubbles (sender on right, receiver on left)
   - ✅ Message text with user names
   - ✅ Timestamps in human-readable format (h:mm a)
   - ✅ Input box with rounded design
   - ✅ Send button with gradient styling
   - ✅ Date dividers (Today, Yesterday, full date)
   - ✅ Typing indicators
   - ✅ Online status badge
   - ✅ Pastel color theme matching the app

2. **Firestore Structure**
   - ✅ **users collection**: 
     - Fields: id, name, email, chats (list of chat IDs), createdAt
     - Created 2 users: "Akash Kumar" (user1) and "Priya Sharma" (user2)
   
   - ✅ **chats collection**:
     - Fields: id, participantIds, participantNames, messages (array), createdAt, lastMessageAt
     - Each message has: id, content, userId, userName, timestamp
     - Created 1 chat with 5 dummy messages between the 2 users
     - Chat ID automatically added to both users' chats list

3. **Real-time Features (Socket.IO)**
   - ✅ Socket.IO server running on Node.js (port 3000)
   - ✅ Real-time message sending/receiving
   - ✅ Typing indicators
   - ✅ User join/leave notifications
   - ✅ Message broadcasting to all participants
   - ✅ Persistent storage in Firestore

## 🏗️ Architecture

### Frontend (Flutter)
```
lib/
├── models/
│   └── chat_models.dart          # UserModel, Message, Chat classes
├── services/
│   ├── chat_service.dart         # Firestore CRUD operations
│   └── socket_service.dart       # Socket.IO client connection
├── screens/
│   └── chat_screen.dart          # Chat UI with message list and input
└── main.dart                     # Added chat navigation
```

### Backend (Node.js)
```
server/
├── package.json                  # Dependencies: socket.io, express, cors
├── server.js                     # Socket.IO server with event handlers
└── README.md                     # Server setup instructions
```

## 🚀 How to Run

### 1. Start Socket.IO Server
```bash
cd server
npm install
npm start
```
Server runs on http://localhost:3000

### 2. Run Flutter App
```bash
cd c:\Users\AkashK\Desktop\Flutter\your_card_scrolling
flutter run
```

### 3. Test Real-time Chat
- Open the app
- Tap the **chat bubble icon** in the header (beige/brown gradient)
- You'll see the conversation between Akash Kumar and Priya Sharma
- Type a message and hit send
- Messages sync instantly via Socket.IO
- Messages persist in Firestore

## 🔄 Data Flow

1. **User sends message** → Socket.IO emits to server
2. **Server broadcasts** → All connected users in chat room receive message
3. **Client receives** → Updates UI immediately
4. **Background sync** → Message saved to Firestore for persistence
5. **On app restart** → Messages load from Firestore

## 🎨 UI Features

### Message Bubbles
- **Sender (right)**: Blue gradient (#B5C7F7), white text
- **Receiver (left)**: Grey gradient, dark text
- **Rounded corners** with small tail (4px radius on inner corner)
- **Shadows** for depth
- **User names** shown on received messages

### Input Area
- Light grey background (#F7F6F2)
- Rounded corners (24px)
- Blue gradient send button with icon
- Typing triggers real-time indicator

### Header
- Blue gradient background (#B5C7F7)
- Shows chat partner's name
- "typing..." indicator when active
- Green online status badge

### Empty State
- Chat bubble outline icon
- "No messages yet" placeholder
- Centered design

## 📊 Firestore Collections

### users
```json
{
  "user1": {
    "id": "user1",
    "name": "Akash Kumar",
    "email": "akash@example.com",
    "chats": ["auto-generated-chat-id"],
    "createdAt": "2024-11-21T..."
  },
  "user2": {
    "id": "user2",
    "name": "Priya Sharma",
    "email": "priya@example.com",
    "chats": ["auto-generated-chat-id"],
    "createdAt": "2024-11-21T..."
  }
}
```

### chats
```json
{
  "auto-generated-chat-id": {
    "id": "auto-generated-chat-id",
    "participantIds": ["user1", "user2"],
    "participantNames": ["Akash Kumar", "Priya Sharma"],
    "messages": [
      {
        "id": "msg1",
        "content": "Hey! I saw your room listing. Is it still available?",
        "userId": "user2",
        "userName": "Priya Sharma",
        "timestamp": "2024-11-21T10:00:00.000Z"
      },
      // ... more messages
    ],
    "createdAt": "2024-11-21T10:00:00.000Z",
    "lastMessageAt": "2024-11-21T12:00:00.000Z"
  }
}
```

## 🔌 Socket.IO Events

### Client → Server
- `join_chat`: Join a specific chat room
- `send_message`: Broadcast message to room
- `typing`: Show typing indicator
- `stop_typing`: Hide typing indicator

### Server → Client
- `receive_message`: New message from another user
- `user_joined`: User joined the chat
- `user_left`: User left the chat
- `user_typing`: Typing indicator active
- `user_stop_typing`: Typing indicator off

## 📦 Dependencies Added

### Flutter (pubspec.yaml)
```yaml
dependencies:
  socket_io_client: ^2.0.3+1  # Real-time communication
  firebase_auth: ^5.3.3        # User authentication
  intl: ^0.19.0                # Date formatting
```

### Node.js (server/package.json)
```json
{
  "dependencies": {
    "socket.io": "^4.7.2",
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
```

## 🧪 Testing Checklist

- ✅ Seed data creates 2 users and 1 chat
- ✅ Chat screen loads with 5 dummy messages
- ✅ Messages display with correct alignment (left/right)
- ✅ Timestamps show in 12-hour format (e.g., "2:30 PM")
- ✅ Date dividers appear between different days
- ✅ Send button sends message
- ✅ New messages appear at bottom
- ✅ Auto-scroll to latest message
- ✅ Empty state shows when no messages
- ✅ Typing indicator works (type in input to test)
- ✅ Socket.IO server connects successfully
- ✅ Messages broadcast in real-time
- ✅ Messages persist in Firestore after app restart

## 🎯 Key Features

1. **Real-time Communication**: Instant message delivery via WebSockets
2. **Offline Support**: Messages saved to Firestore for persistence
3. **Typing Indicators**: See when the other user is typing
4. **Smart Scrolling**: Auto-scrolls to newest messages
5. **Date Formatting**: Human-readable timestamps and date dividers
6. **Professional UI**: Matches app's pastel color scheme
7. **Scalable Architecture**: Service layer pattern for easy maintenance

## 🔧 Configuration

To change the Socket.IO server URL, edit `lib/services/socket_service.dart`:
```dart
static const String _serverUrl = 'http://localhost:3000'; // Change this
```

For production:
```dart
static const String _serverUrl = 'https://your-server.com';
```

## 🏆 Task 5 Complete!

All requirements have been implemented and tested. The chat feature is fully functional with real-time messaging, Firestore persistence, and a beautiful UI that matches the app's design language.
