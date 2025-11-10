import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/post_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static const String serverUrl = 'https://college-community-app-backend.onrender.com';
  
  static bool get isConnected => _socket?.connected ?? false;
  static IO.Socket? get socket => _socket;

  static Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      print('✅ Socket already connected');
      return;
    }

    final token = PostService.authToken;
    
    if (token == null || token.isEmpty) {
      print('❌ No token - cannot connect to socket');
      return;
    }

    print('🔌 Connecting to socket...');
    print('🔗 URL: $serverUrl');
    print('🔑 Token: ${token.substring(0, 20)}...');

    _socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])  
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(5)
          .setAuth({'token': token})  
          .build(),
    );

    _socket!.onConnect((_) {
      print('✅ Socket connected!');
      print('   Socket ID: ${_socket!.id}');
    });

    _socket!.onDisconnect((reason) {
      print('❌ Socket disconnected: $reason');
    });

    _socket!.onConnectError((error) {
      print('❌ Socket connection error: $error');
    });

    _socket!.onError((error) {
      print('❌ Socket error: $error');
    });

    _socket!.on('connect_timeout', (_) {
      print('⏱️ Socket connection timeout');
    });

    _socket!.on('reconnect', (attemptNumber) {
      print('🔄 Socket reconnected after $attemptNumber attempts');
    });

    _socket!.on('reconnect_attempt', (attemptNumber) {
      print('🔄 Socket reconnection attempt: $attemptNumber');
    });

    _socket!.on('reconnect_failed', (_) {
      print('❌ Socket reconnection failed');
    });

    _socket!.connect();
  }

  static void disconnect() {
    if (_socket != null) {
      print('🔌 Disconnecting socket...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
  }

  static void joinRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      print('🚪 Joining room: $roomId');
      _socket!.emit('joinRoom', {'roomId': roomId});
    } else {
      print('❌ Cannot join room - socket not connected');
    }
  }

  static void leaveRoom(String roomId) {
    if (_socket != null && _socket!.connected) {
      print('🚪 Leaving room: $roomId');
      _socket!.emit('leaveRoom', {'roomId': roomId});
    }
  }

  static void sendMessage({
    required String roomId,
    required String message,
    String? replyTo,
  }) {
    if (_socket != null && _socket!.connected) {
      print('📤 Sending message to room: $roomId');
      print('   Message: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      
      _socket!.emit('sendMessage', {
        'roomId': roomId,
        'message': message,
        if (replyTo != null) 'replyTo': replyTo,
      });
    } else {
      print('❌ Socket not connected - cannot send message');
    }
  }

  static void onNewMessage(Function(dynamic) callback) {
    print('👂 Listening for new messages...');
    _socket?.on('newMessage', callback);
  }

  static void onMessageHistory(Function(dynamic) callback) {
    print('👂 Listening for message history...');
    _socket?.on('messageHistory', callback);
  }

  static void onUserTyping(Function(dynamic) callback) {
    print('👂 Listening for typing status...');
    _socket?.on('userTyping', callback);
  }

  static void sendTypingStatus(String roomId, bool isTyping) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing', {
        'roomId': roomId,
        'isTyping': isTyping,
      });
    }
  }

  static void markAsRead(String roomId) {
    if (_socket != null && _socket!.connected) {
      print('✅ Marking messages as read in room: $roomId');
      _socket!.emit('markAsRead', {'roomId': roomId});
    }
  }

  static void off(String event) {
    _socket?.off(event);
  }

  static void removeAllListeners() {
    print('🗑️ Removing all socket listeners');
    _socket?.off('newMessage');
    _socket?.off('messageHistory');
    _socket?.off('userTyping');
  }
}
