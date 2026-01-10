import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? client;
  final Function(dynamic) onMessageReceived;
  final Function(String, bool)? onTypingStatus; // Error 3 Fix

  WebSocketService({required this.onMessageReceived, this.onTypingStatus});

  void connect(String myPhone) {
    client = StompClient(
      config: StompConfig(
        url: 'wss://ram-backend-ipu1.onrender.com/ws',
        onConnect: (frame) {
          // Subscribe for messages
          client?.subscribe(
            destination: '/user/$myPhone/queue/messages',
            callback: (frame) {
              if (frame.body != null) onMessageReceived(jsonDecode(frame.body!));
            },
          );

          // Error 4 Fix: Typing status subscription
          client?.subscribe(
            destination: '/user/$myPhone/queue/typing',
            callback: (frame) {
              if (frame.body != null) {
                var data = jsonDecode(frame.body!);
                onTypingStatus?.call(data['senderId'], data['isTyping']);
              }
            },
          );
        },
      ),
    );
    client?.activate();
  }

  // Error 5 Fix: sendTyping method add kiya
  void sendTyping(String myPhone, String targetPhone, bool isTyping) {
    if (client != null && client!.connected) {
      client?.send(
        destination: '/app/chat.typing',
        body: jsonEncode({
          'senderId': myPhone,
          'recipientId': targetPhone,
          'isTyping': isTyping
        }),
      );
    }
  }

  void sendMessage(Map<String, dynamic> msg) {
    if (client != null && client!.connected) {
      client?.send(destination: '/app/chat.send', body: jsonEncode(msg));
    }
  }
}