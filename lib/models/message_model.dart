enum MessageStatus { sent, delivered, read }

class ChatMessage {
  final String? id;
  final String senderId;
  final String recipientId;
  final String content;
  final String type; // TEXT, IMAGE, VIDEO, FILE
  final DateTime timestamp;
  final MessageStatus status;
  final String? mediaUrl;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    this.type = "TEXT",
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.mediaUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString(),
      senderId: json['senderId']?.toString() ?? '',
      recipientId: json['recipientId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'TEXT',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      status: _parseStatus(json['status']),
      mediaUrl: json['mediaUrl'],
    );
  }

  static MessageStatus _parseStatus(String? status) {
    switch (status) {
      case 'READ': return MessageStatus.read;
      case 'DELIVERED': return MessageStatus.delivered;
      default: return MessageStatus.sent;
    }
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