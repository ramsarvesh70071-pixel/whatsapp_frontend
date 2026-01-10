class ChatMessage {
  final String senderId;
  final String recipientId;
  final String content;
  final String type;
  final DateTime timestamp; // Error 1 Fix: Timestamp add kiya
  final String? mediaUrl;   // Error 2 Fix: MediaUrl add kiya

  ChatMessage({
    required this.senderId,
    required this.recipientId,
    required this.content,
    this.type = "TEXT",
    required this.timestamp,
    this.mediaUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId']?.toString() ?? '',
      recipientId: json['recipientId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'TEXT',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      mediaUrl: json['mediaUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'recipientId': recipientId,
    'content': content,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'mediaUrl': mediaUrl,
  };
}