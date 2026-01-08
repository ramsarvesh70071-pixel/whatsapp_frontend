import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/websocket_service.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String myPhone;
  final String targetPhone;
  final String targetName; // Fixed: Ise yahan define kiya taaki widget.targetName use ho sake

  ChatScreen({
    required this.myPhone,
    required this.targetPhone,
    required this.targetName, // Constructor update kiya
  });

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
      // Check: Message isi user se juda hai ya nahi
      if (data['senderId'] == widget.targetPhone || data['senderId'] == widget.myPhone) {
        setState(() {
          messages.insert(0, ChatMessage.fromJson(data));
        });
      }
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
        title: Text(widget.targetName), // Ab ye error nahi dega
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE5DDD5), // WhatsApp Chat Background
        ),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ListView.builder(
                reverse: true,
                padding: EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isMe = messages[index].senderId == widget.myPhone;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? Color(0xFFDCF8C6) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                          bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 1)
                        ],
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
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey.shade100,
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.teal.shade800,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }
}