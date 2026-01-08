import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/websocket_service.dart';
import '../services/api_service.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    wsService = WebSocketService(onMessageReceived: (data) {
      setState(() {
        messages.insert(0, ChatMessage.fromJson(data));
      });
    });
    wsService.connect(widget.myPhone);
  }

  void _loadHistory() async {
    try {
      var historyData = await ApiService.getChatHistory(widget.myPhone, widget.targetPhone);
      List<ChatMessage> historyMessages = historyData
          .map((item) => ChatMessage.fromJson(item))
          .toList();

      setState(() {
        messages = historyMessages.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      print("History load karne mein error: $e");
      setState(() => isLoading = false);
    }
  }

  void _send() {
    if (_controller.text.trim().isNotEmpty) {
      var msg = ChatMessage(
        senderId: widget.myPhone,
        recipientId: widget.targetPhone,
        content: _controller.text.trim(),
        type: "TEXT",
      );
      wsService.sendMessage(msg.toJson());
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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isMe = messages[index].senderId == widget.myPhone;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.teal[100] : Colors.white,
                      // FIXED: Elevation hata kar boxShadow add kiya hai
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: isMe ? Radius.circular(15) : Radius.circular(0),
                        bottomRight: isMe ? Radius.circular(0) : Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      messages[index].content,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
            ),
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
                    onSubmitted: (_) => _send(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _send,
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