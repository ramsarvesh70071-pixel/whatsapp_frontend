class ChatMessage {
  final String senderId;
  final String recipientId; // Iska naam 'recipientId' hi rakhein (Backend ki tarah)
  final String content;
  final String type;

  ChatMessage({
    required this.senderId,
    required this.recipientId,
    required this.content,
    this.type = "TEXT"
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId']?.toString() ?? '',
      recipientId: json['recipientId']?.toString() ?? '', // Null safety handle kari
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'TEXT',
    );
  }

  Map<String, dynamic> toJson() => {
    'senderId': senderId,
    'recipientId': recipientId,
    'content': content,
    'type': type,
  };
}