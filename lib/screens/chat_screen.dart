import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/websocket_service.dart';

class ChatScreen extends StatefulWidget {
  final String myPhone;
  final String targetPhone;

  ChatScreen({required this.myPhone, required this.targetPhone});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> messages = [];
  late WebSocketService wsService;

  @override
  void initState() {
    super.initState();
    // WebSocket connect aur message receive logic
    wsService = WebSocketService(onMessageReceived: (data) {
      setState(() {
        // Bahar se aane wala message list mein upar add hoga
        messages.insert(0, ChatMessage.fromJson(data));
      });
    });
    wsService.connect(widget.myPhone);
  }

  void _send() {
    if (_controller.text.trim().isNotEmpty) {
      // 1. Message object banayein
      var msg = ChatMessage(
        senderId: widget.myPhone,
        recipientId: widget.targetPhone,
        content: _controller.text.trim(),
        type: "TEXT",
      );

      // 2. Backend ko bhejein (Isse pgAdmin mein data jayega)
      wsService.sendMessage(msg.toJson());

      // 3. Apni screen par turant dikhayein
      setState(() {
        messages.insert(0, msg);
      });

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.targetPhone}"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Naye messages niche se upar aayenge
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isMe = messages[index].senderId == widget.myPhone;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.teal[100] : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: isMe ? Radius.circular(15) : Radius.circular(0),
                        bottomRight: isMe ? Radius.circular(0) : Radius.circular(15),
                      ),
                    ),
                    child: Text(messages[index].content),
                  ),
                );
              },
            ),
          ),
          // --- Input Area Fixed ---
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _send(), // Enter dabane par bhi bhejega
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _send, // FIX: Ab button kaam karega
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}