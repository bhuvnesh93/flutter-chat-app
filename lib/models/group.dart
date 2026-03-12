class GroupData {
  final String groupId;
  final String imageUrl;
  final Map<String, dynamic> members;
  final LastMessage? lastMessage;
  final String name;
  final String createdBy;
  final bool groupDeleted;
  final bool group;
  final int timestamp;

  GroupData({
    required this.groupId,
    required this.imageUrl,
    required this.members,
    this.lastMessage,
    required this.name,
    required this.createdBy,
    required this.groupDeleted,
    required this.group,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    "group_id": groupId,
    "image_url": imageUrl,
    "members": members,
    "lastMessage": lastMessage?.toMap(),
    "name": name,
    "created_by": createdBy,
    "group_deleted": groupDeleted,
    "group": group,
    "timestamp": timestamp,
  };

  factory GroupData.fromMap(Map<String, dynamic> map) {
    return GroupData(
      groupId: map["group_id"] ?? "",
      imageUrl: map["image_url"] ?? "",
      members: Map.from(map["members"] ?? {}).map(
        (k, v) => MapEntry<String, Member>(
          k,
          Member.fromMap(v.cast<String, dynamic>()),
        ),
      ),
      lastMessage:
          map["lastMessage"] != null
              ? LastMessage.fromMap(map["lastMessage"].cast<String, dynamic>())
              : null,
      name: map["name"] ?? "",
      createdBy: map["created_by"] ?? "",
      groupDeleted: map["group_deleted"] ?? false,
      group: map["group"] ?? false,
      timestamp: map["timestamp"] ?? 0,
    );
  }
}

class LastMessage {
  final String messageId;
  final String messageType;
  final String message;
  final String type;
  final String senderId;
  final int timestamp;

  LastMessage({
    required this.messageId,
    required this.messageType,
    required this.message,
    required this.type,
    required this.senderId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    "message_id": messageId,
    "message_type": messageType,
    "message": message,
    "type": type,
    "sender_id": senderId,
    "timestamp": timestamp,
  };

  factory LastMessage.fromMap(Map<String, dynamic> map) => LastMessage(
    messageId: map["message_id"] ?? "",
    messageType: map["message_type"] ?? "",
    message: map["message"] ?? "",
    type: map["type"] ?? "",
    senderId: map["sender_id"] ?? "",
    timestamp: map["timestamp"] ?? 0,
  );
}

class Member {
  final int unreadGroupCount;
  final String uid;
  final bool active;
  final int deleteTill;
  final int lastSeenMessageTimestamp;
  final bool? admin;

  Member({
    required this.unreadGroupCount,
    required this.uid,
    required this.active,
    required this.deleteTill,
    required this.lastSeenMessageTimestamp,
    required this.admin,
  });

  Map<String, dynamic> toMap() => {
    "unread_group_count": unreadGroupCount,
    "uid": uid,
    "active": active,
    "delete_till": deleteTill,
    "last_seen_message_timestamp": lastSeenMessageTimestamp,
    "admin": admin,
  };

  factory Member.fromMap(Map<String, dynamic> map) => Member(
    unreadGroupCount: map["unread_group_count"],
    uid: map["uid"],
    active: map["active"],
    deleteTill: map["delete_till"],
    lastSeenMessageTimestamp: map["last_seen_message_timestamp"],
    admin: map["admin"],
  );
}
