import 'dart:convert';

GroupData groupDataFromJson(String str) => GroupData.fromJson(json.decode(str));

String groupDataToJson(GroupData data) => json.encode(data.toJson());

class GroupData {
  final String groupId;
  final String imageUrl;
  final Map<String, Member> members;
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

  factory GroupData.fromJson(Map<String, dynamic> json) => GroupData(
    groupId: json["group_id"],
    imageUrl: json["image_url"],
    members: Map.from(
      json["members"],
    ).map((k, v) => MapEntry<String, Member>(k, Member.fromJson(v))),
    lastMessage:
        json["lastMessage"] != null
            ? LastMessage.fromJson(json["lastMessage"])
            : null,
    name: json["name"],
    createdBy: json["created_by"],
    groupDeleted: json["group_deleted"],
    group: json["group"],
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "group_id": groupId,
    "image_url": imageUrl,
    // "members": Map.from(
    //   members,
    // ).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    "lastMessage": lastMessage!.toJson(),
    "name": name,
    "created_by": createdBy,
    "group_deleted": groupDeleted,
    "group": group,
    "timestamp": timestamp,
  };
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

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
    messageId: json["message_id"] ?? "",
    messageType: json["message_type"] ?? "",
    message: json["message"] ?? "",
    type: json["type"] ?? "",
    senderId: json["sender_id"] ?? "",
    timestamp: json["timestamp"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "message_id": messageId,
    "message_type": messageType,
    "message": message,
    "type": type,
    "sender_id": senderId,
    "timestamp": timestamp,
  };
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

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    unreadGroupCount: json["unread_group_count"],
    uid: json["uid"],
    active: json["active"],
    deleteTill: json["delete_till"],
    lastSeenMessageTimestamp: json["last_seen_message_timestamp"],
    admin: json["admin"],
  );

  Map<String, dynamic> toJson() => {
    "unread_group_count": unreadGroupCount,
    "uid": uid,
    "active": active,
    "delete_till": deleteTill,
    "last_seen_message_timestamp": lastSeenMessageTimestamp,
    // "admin": admin,
  };
}
