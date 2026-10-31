class MessageData {
  final String? message;
  final String messageId;
  final String messageType;
  final String senderId;
  final String type;
  final int timestamp;
  final List<dynamic>? members;
  final bool? isDeleted;
  final bool? isEdited;

  MessageData({
    this.message,
    required this.messageId,
    required this.messageType,
    required this.senderId,
    required this.type,
    required this.timestamp,
    this.members,
    this.isDeleted,
    this.isEdited,
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
      isDeleted: map["is_deleted"] ?? false,
      isEdited: map["is_edited"] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    "message_id": messageId,
    "message_type": messageType,
    "message": message,
    "type": type,
    "sender_id": senderId,
    "timestamp": timestamp,
    "members": members,
  };
}
