import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_models.dart';

class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;

  // Change this to your server URL
  // For local testing: 'http://localhost:3000'
  // For production: 'https://your-server.com'
  static const String _serverUrl = 'http://localhost:3000';

  // Connect to Socket.IO server
  Future<void> connect() async {
    if (_isConnected) return;

    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Connected to Socket.IO server');
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      print('❌ Disconnected from Socket.IO server');
      _isConnected = false;
    });

    _socket!.onConnectError((error) {
      print('❌ Connection Error: $error');
    });

    _socket!.onError((error) {
      print('❌ Socket Error: $error');
    });
  }

  // Join a chat room
  void joinChat(String chatId, String userId, String userName) {
    if (_socket == null || !_isConnected) {
      print('⚠️ Socket not connected. Cannot join chat.');
      return;
    }

    _socket!.emit('join_chat', {
      'chatId': chatId,
      'userId': userId,
      'userName': userName,
    });

    print('📥 Joined chat: $chatId');
  }

  // Send a message
  void sendMessage(String chatId, Message message) {
    if (_socket == null || !_isConnected) {
      print('⚠️ Socket not connected. Cannot send message.');
      return;
    }

    _socket!.emit('send_message', {
      'chatId': chatId,
      'message': message.toJson(),
    });

    print('📤 Message sent: ${message.content}');
  }

  // Listen for incoming messages
  void onMessageReceived(Function(Message) callback) {
    _socket?.on('receive_message', (data) {
      try {
        final message = Message.fromJson(data as Map<String, dynamic>);
        callback(message);
        print('📩 Message received: ${message.content}');
      } catch (e) {
        print('❌ Error parsing message: $e');
      }
    });
  }

  // Send typing indicator
  void sendTypingIndicator(String chatId, String userName) {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('typing', {
      'chatId': chatId,
      'userName': userName,
    });
  }

  // Send stop typing indicator
  void sendStopTypingIndicator(String chatId) {
    if (_socket == null || !_isConnected) return;

    _socket!.emit('stop_typing', {
      'chatId': chatId,
    });
  }

  // Listen for typing indicators
  void onUserTyping(Function(String) callback) {
    _socket?.on('user_typing', (data) {
      final userName = data['userName'] as String;
      callback(userName);
    });
  }

  void onUserStopTyping(Function() callback) {
    _socket?.on('user_stop_typing', (_) {
      callback();
    });
  }

  // Listen for user joined
  void onUserJoined(Function(String, String) callback) {
    _socket?.on('user_joined', (data) {
      final userId = data['userId'] as String;
      final userName = data['userName'] as String;
      callback(userId, userName);
      print('👋 $userName joined the chat');
    });
  }

  // Listen for user left
  void onUserLeft(Function(String, String) callback) {
    _socket?.on('user_left', (data) {
      final userId = data['userId'] as String;
      final userName = data['userName'] as String;
      callback(userId, userName);
      print('👋 $userName left the chat');
    });
  }

  // Disconnect from server
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      print('🔌 Disconnected from Socket.IO server');
    }
  }

  // Check connection status
  bool get isConnected => _isConnected;
}
