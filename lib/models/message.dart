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

  factory MessageData.fromMap(Map<String, dynamic> map) {
    return MessageData(
      messageId: map["message_id"],
      messageType: map["message_type"],
      senderId: map["sender_id"],
      type: map["type"],
      timestamp: map["timestamp"],
      message: map["message"] ?? "",
      members: map["members"] ?? [],
    );
  }

  // Map<String, dynamic> toMap() => {
  //   "message_id": messageId,
  //   "message_type": messageType,
  //   "message": message,
  //   "type": type,
  //   "sender_id": senderId,
  //   "timestamp": timestamp,
  // };
}
