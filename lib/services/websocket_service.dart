import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  StompClient? client;
  final Function(dynamic) onMessageReceived;

  WebSocketService({required this.onMessageReceived});

  void connect(String myPhone) {
    if (client != null && client!.connected) return; // Pehle se connected hai toh dubara na karein

    client = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/ws', // Backend URL
        onConnect: (StompFrame frame) {
          print("STOMP Connected successfully as $myPhone");

          // Subscribe to private queue
          client?.subscribe(
            destination: '/user/$myPhone/queue/messages',
            callback: (StompFrame frame) {
              if (frame.body != null) {
                print("RAW MESSAGE RECEIVED FROM SERVER: ${frame.body}");
                try {
                  final dynamic data = jsonDecode(frame.body!);
                  onMessageReceived(data);
                } catch (e) {
                  print("Error decoding message: $e");
                }
              }
            },
          );
        },
        onWebSocketError: (e) => print("WebSocket Error: $e"),
        onStompError: (d) => print("STOMP Error: ${d.body}"),
        onDisconnect: (f) => print("Disconnected from WebSocket"),
        // Heartbeat helps in keeping the connection alive on Chrome
        stompConnectHeaders: {'heart-beat': '10000,10000'},
        webSocketConnectHeaders: {'heart-beat': '10000,10000'},
      ),
    );
    client?.activate();
  }

  void sendMessage(Map<String, dynamic> msg) {
    if (client != null && client!.connected) {
      print("Sending to /app/chat.send: $msg");
      client?.send(
        destination: '/app/chat.send',
        body: jsonEncode(msg),
      );
    } else {
      print("Error: Cannot send message. WebSocket is not connected!");
    }
  }

  void disconnect() {
    client?.deactivate();
  }
}