import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Add this package
import 'dart:io';
import '../models/message_model.dart';
import '../services/websocket_service.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String myPhone;
  final String targetPhone;
  final String targetName;

  ChatScreen({required this.myPhone, required this.targetPhone, required this.targetName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<ChatMessage> messages = [];
  late WebSocketService wsService;
  bool isTargetTyping = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    wsService = WebSocketService(
      onMessageReceived: (data) {
        if (data['senderId'] == widget.targetPhone || data['senderId'] == widget.myPhone) {
          setState(() => messages.insert(0, ChatMessage.fromJson(data)));
        }
      },
      onTypingStatus: (senderId, isTyping) {
        if (senderId == widget.targetPhone) {
          setState(() => isTargetTyping = isTyping);
        }
      },
    );
    wsService.connect(widget.myPhone);
  }

  // --- IMAGE PICKER FUNCTION ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      // Yahan aapko image ko Cloudinary ya backend pe upload karke URL lena hoga
      // Filhal main dummy URL bhej raha hoon logic dikhane ke liye
      var msg = ChatMessage(
        senderId: widget.myPhone,
        recipientId: widget.targetPhone,
        content: "Sent an image",
        type: "IMAGE",
        mediaUrl: selectedImage.path, // Local path for instant preview
        timestamp: DateTime.now(),
      );

      wsService.sendMessage(msg.toJson());
      setState(() => messages.insert(0, msg));
    }
  }

  void _loadHistory() async {
    var historyData = await ApiService.getChatHistory(widget.myPhone, widget.targetPhone);
    setState(() {
      messages = historyData.map((item) => ChatMessage.fromJson(item)).toList().reversed.toList();
      isLoading = false;
    });
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    var msg = ChatMessage(
      senderId: widget.myPhone,
      recipientId: widget.targetPhone,
      content: _controller.text.trim(),
      type: "TEXT",
      timestamp: DateTime.now(),
    );
    wsService.sendMessage(msg.toJson());
    setState(() => messages.insert(0, msg));
    _controller.clear();
    wsService.sendTyping(widget.myPhone, widget.targetPhone, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.targetName),
            if (isTargetTyping)
              Text("typing...", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.teal.shade800,
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
                fit: BoxFit.cover
            )
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) => _buildMessageBubble(messages[index]),
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    bool isMe = msg.senderId == widget.myPhone;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: EdgeInsets.all(8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg.type == "IMAGE" && msg.mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: msg.mediaUrl!.startsWith('http')
                    ? Image.network(msg.mediaUrl!)
                    : Image.file(File(msg.mediaUrl!)),
              ),
            if (msg.content.isNotEmpty && msg.type == "TEXT")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(msg.content, style: TextStyle(fontSize: 16)),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(DateFormat('hh:mm a').format(msg.timestamp), style: TextStyle(fontSize: 10, color: Colors.grey)),
                if (isMe) Icon(Icons.done_all, size: 14, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey), onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: (v) => wsService.sendTyping(widget.myPhone, widget.targetPhone, v.isNotEmpty),
                      decoration: InputDecoration(hintText: "Message", border: InputBorder.none),
                    ),
                  ),
                  IconButton(icon: Icon(Icons.camera_alt, color: Colors.grey), onPressed: () => _pickImage(ImageSource.camera)),
                  IconButton(icon: Icon(Icons.attach_file, color: Colors.grey), onPressed: () => _pickImage(ImageSource.gallery)),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
          CircleAvatar(
            backgroundColor: Colors.teal.shade800,
            child: IconButton(icon: Icon(Icons.send, color: Colors.white), onPressed: _send),
          ),
        ],
      ),
    );
  }
}