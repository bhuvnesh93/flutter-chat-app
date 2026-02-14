class MessageData {
  final String message;
  final String messageId;
  final String messageType;
  final String senderId;
  final String type;
  final int timestamp;
  final List<dynamic> members;

  MessageData({
    required this.message,
    required this.messageId,
    required this.messageType,
    required this.senderId,
    required this.type,
    required this.timestamp,
    required this.members,
  });
}
