class DaialogType {
  static const String oneOnOneChat = 'one_on_one_chat';
  static const String groupChat = 'group_chat';
}

class ChatType {
  static const String chatMessage = "CHAT_MESSAGE";
  static const String groupNotification = "GROUP_NOTIFICATION";
}

class NotificationMessageTypes {
  static const String newGroup = 'NEW_GROUP';
  // ADD_MEMBER: 'ADD_MEMBER',
  // REMOVE_MEMBER: 'REMOVE_MEMBER',
  // USER_LEFT: 'USER_LEFT',
  static const String changeGroupName = 'CHANGE_GROUP_NAME';
  // CHANGE_GROUP_IMAGE: 'CHANGE_GROUP_IMAGE',
}

class MessageType {
  static const String text = "TEXT";
  static const String image = "IMAGE";
  static const String video = "VIDEO";
  static const String audio = "AUDIO";
  static const String newGroup = "NEW_GROUP";
  static const String addMember = "ADD_MEMBER";
  static const String removeMember = "REMOVE_MEMBER";
  static const String changeGroupName = "CHANGE_GROUP_NAME";
  static const String changeGroupImage = "CHANGE_GROUP_IMAGE";
}

enum ToastTypes { info, error, success }
