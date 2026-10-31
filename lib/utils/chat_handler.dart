import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

String uId(uid) {
  return 'uid-$uid';
}

String _deviceIdDatabaseKey(String deviceId) {
  if (!RegExp(r'[.#$\[\]/\u0000-\u001F\u007F]').hasMatch(deviceId) &&
      !deviceId.startsWith('~')) {
    return deviceId;
  }
  return '~${base64Url.encode(utf8.encode(deviceId)).replaceAll('=', '')}';
}

String generatePrivateChatId(selfUserId, otherUserId) {
  String aTemp = selfUserId.replaceFirst('uid-', '');
  String bTemp = otherUserId.replaceFirst('uid-', '');
  String id = '';
  if (aTemp.compareTo(bTemp) > 0) {
    id = '${otherUserId}_$selfUserId';
  } else {
    id = '${selfUserId}_$otherUserId';
  }
  return id;
}

bool chatIsTodayHeader(milliseconds) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  String formattedDate = DateFormat('yyyy-MM-dd').format(date);

  DateTime dateToday = DateTime.now();
  String formattedDateToday = DateFormat('yyyy-MM-dd').format(dateToday);

  return formattedDateToday == formattedDate;
}

bool chatIsYesterdayHeader(milliseconds) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  String formattedDate = DateFormat('yyyy-MM-dd').format(date);
  DateTime yesterdayDate = DateTime.now().subtract(Duration(days: 1));
  String formattedDateYesterday = DateFormat(
    'yyyy-MM-dd',
  ).format(yesterdayDate);
  return formattedDate == formattedDateYesterday;
}

String chatFormatTimeAMPM(milliseconds) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  String formattedTime = DateFormat('h:mm a').format(dateTime);
  return formattedTime;
}

bool chatIsToday(date) {
  DateTime dateTime = DateTime.parse(date);
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  DateTime dateToday = DateTime.now();
  String formattedDateToday = DateFormat('yyyy-MM-dd').format(dateToday);

  return formattedDateToday == formattedDate;
}

bool chatIsYesterday(date) {
  DateTime dateTime = DateTime.parse(date);
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  DateTime yesterdayDate = DateTime.now().subtract(Duration(days: 1));
  String formattedDateYesterday = DateFormat(
    'yyyy-MM-dd',
  ).format(yesterdayDate);
  return formattedDate == formattedDateYesterday;
}

String chatFormatDateDDMonthYYYY(date) {
  DateTime dateTime = DateTime.parse(date);
  String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
  return formattedDate;
}

String chatFormatDate(milliseconds) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
  return formattedDate;
}

// String chatFormatDateDDMonthYYYY(milliseconds) {
//   DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
//   String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
//   return formattedDate;
// }

// class DatabaseService {
final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

final Reference _storageRef = FirebaseStorage.instance.ref();

// Write Data
// Future<void> setUser(String userId, Map<String, dynamic> userData) async {
//   await _dbRef.child('users/$userId').set(userData);
// }

void updateOnlineOfflineStatus(String userId, bool isOnline) async {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  Map<String, dynamic> data = {
    "online": isOnline,
    "last_seen_online": timestamp,
  };
  _dbRef.child('/chat/users/$userId').update(data);
}

void updateGroupName(
  String userId,
  String groupId,
  String groupName,
  Function() callback,
) {
  _dbRef.child('/chat/group/$groupId/name').set(groupName).then((onValue) {
    sendNotificationMessageToGroup(
      groupId,
      userId,
      MessageType.changeGroupName,
      [],
      (groupId, messageId) {
        callback();
      },
    );
  });
}

void sendMessageToChat(
  String userId,
  String groupId,
  String messageType,
  String message,
  Function() callback,
) {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  String messageId = _dbRef.child("/chat/messages/$groupId").push().key!;
  MessageData messageData = MessageData(
    messageId: messageId,
    messageType: messageType,
    senderId: userId,
    type: ChatType.chatMessage,
    timestamp: timestamp,
    message: message,
  );
  final messageModel = messageData.toMap();
  _dbRef.child("/chat/group/$groupId/lastMessage").set(messageModel);
  _dbRef.child("/chat/messages/$groupId/$messageId").set(messageModel).then((
    value,
  ) {
    callback();
  });
  // FirebaseDatabase.instance
  //     .ref("/chat/group")
  //     .child(groupId)
  //     .child("lastMessage")
  //     .set(messageModel)
  //     .then((onValue) {});
  // FirebaseDatabase.instance
  //     .ref("/chat/messages")
  //     .child(groupId)
  //     .child(messageId)
  //     .set(messageModel)
  //     .then((onValue) {
  //       callback();
  //     });
}

void fetchMessagesByGroupPagination(
  String groupId,
  int deleteTill,
  Function(List<MessageData>) callback,
) async {
  final databaseEvent =
      await _dbRef
          .child("/chat/messages/$groupId")
          .orderByChild("timestamp")
          .startAt(deleteTill)
          .once();
  if (databaseEvent.snapshot.exists) {
    Map<String, dynamic> myData = Map<String, dynamic>.from(
      databaseEvent.snapshot.value as Map,
    );
    List<MessageData> list =
        myData.values
            .map((map) => MessageData.fromMap(map.cast<String, dynamic>()))
            .toList();
    callback(list);
  } else {
    callback([]);
  }
}

void sendNotificationMessageToGroup(
  String groupId,
  String selfUserId,
  String messageType,
  List<Map<String, dynamic>> members,
  Function(String groupId, String messageId) callback,
) {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  String messageId = _dbRef.child("/chat/messages/$groupId").push().key!;
  MessageData messageData = MessageData(
    messageId: messageId,
    messageType: messageType,
    senderId: selfUserId,
    type: ChatType.groupNotification,
    timestamp: timestamp,
    members: members,
  );
  final messageModel = messageData.toMap();
  _dbRef.child("/chat/messages/$groupId/$messageId").set(messageModel).then((
    _,
  ) {
    callback(groupId, messageId);
  });
}

void fetchAllUsers(
  String userId,
  Function(List<UserData> usersList) callback,
) async {
  final databaseEvent = await _dbRef.child("/chat/users").once();
  if (databaseEvent.snapshot.exists) {
    Map<String, dynamic> castedMap = Map<String, dynamic>.from(
      databaseEvent.snapshot.value as Map,
    );
    final usersList =
        castedMap.values
            .map((map) => UserData.fromMap(map.cast<String, dynamic>()))
            .toList()
            .where((element) => element.uid != userId)
            .toList();
    callback(usersList);
  }
}

void fetchUserData(String userId, Function(UserData userData) callback) async {
  final databaseEvent = await _dbRef.child("/chat/users/$userId").once();
  Map<String, dynamic> castedMap = Map<String, dynamic>.from(
    databaseEvent.snapshot.value as Map,
  );
  UserData userData = UserData.fromMap(castedMap);
  callback(userData);
}

void saveUserData(UserData userData, Function() callback) {
  _dbRef
      .child("/chat/users/${userData.uid}")
      .set(userData.toMap())
      .then((value) => callback());
}

void createOneOnOneChatGroup(
  UserData user,
  UserData otherUser,
  String groupId,
  Function() callback,
) {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  Map<String, dynamic> groupMembers = {};
  Member userModel = Member(
    unreadGroupCount: 0,
    uid: user.uid,
    active: true,
    deleteTill: timestamp,
    lastSeenMessageTimestamp: timestamp,
  );
  groupMembers[userModel.uid] = userModel.toMap();
  Member otherUserModel = Member(
    unreadGroupCount: 0,
    uid: otherUser.uid,
    active: true,
    deleteTill: timestamp,
    lastSeenMessageTimestamp: timestamp,
  );
  groupMembers[otherUserModel.uid] = otherUserModel.toMap();
  GroupData groupData = GroupData(
    groupId: groupId,
    imageUrl: "",
    members: groupMembers,
    name: "",
    createdBy: userModel.uid,
    groupDeleted: false,
    group: false,
    timestamp: timestamp,
  );
  final newGroup = groupData.toMap();
  // FirebaseDatabase.instance
  //     .ref("/chat/group")
  _dbRef.child("/chat/group/$groupId").set(newGroup).then((onValue) {
    // _prepareMessage(MessageType.text);
    callback();
    newGroup["members"].keys.forEach((key) {
      // FirebaseDatabase.instance
      _dbRef
          .child("/chat/users/$key/group/$groupId")
          // .child(key)
          // .child("group")
          // .child(groupId)
          .set(true)
          .then((onValue) {});
    });
  });
}

void createGroup(
  String userId,
  String groupName,
  List<UserData> selectedMember,
  Function(String groupId) callback,
) {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  var membersArr = [];
  Map<String, dynamic> groupMembers = {};

  Member adminUserModel = Member(
    unreadGroupCount: 0,
    uid: userId,
    active: true,
    deleteTill: timestamp,
    lastSeenMessageTimestamp: timestamp,
    admin: true,
  );
  groupMembers[adminUserModel.uid] = adminUserModel.toMap();
  for (var element in selectedMember) {
    membersArr.add({"uid": element.uid});
    Member otherUserModel = Member(
      unreadGroupCount: 0,
      uid: element.uid,
      active: true,
      deleteTill: timestamp,
      lastSeenMessageTimestamp: timestamp,
      admin: false,
    );
    groupMembers[otherUserModel.uid] = otherUserModel.toMap();
  }
  String? groupId = FirebaseDatabase.instance.ref("/chat/group").push().key;
  GroupData groupData = GroupData(
    groupId: groupId!,
    imageUrl: "",
    members: groupMembers,
    name: groupName,
    createdBy: adminUserModel.uid,
    groupDeleted: false,
    group: true,
    timestamp: timestamp,
  );
  final newGroup = groupData.toMap();
  FirebaseDatabase.instance
      .ref("/chat/group")
      .child(groupId)
      .set(newGroup)
      .then((onValue) {
        newGroup["members"].keys.forEach((key) {
          FirebaseDatabase.instance
              .ref("/chat/users")
              .child(key)
              .child("group")
              .child(groupId)
              .set(true)
              .then((onValue) {
                //
              });
        });
        String messageId = _dbRef.child("/chat/messages/$groupId").push().key!;
        MessageData messageData = MessageData(
          messageId: messageId,
          messageType: MessageType.newGroup,
          senderId: userId,
          type: ChatType.groupNotification,
          timestamp: timestamp,
        );
        final messageModel = messageData.toMap();
        FirebaseDatabase.instance
            .ref("/chat/messages")
            .child(groupId)
            .child(messageId)
            .set(messageModel)
            .then((onValue) {
              String? messageId =
                  FirebaseDatabase.instance
                      .ref("/chat/messages")
                      .child(groupId)
                      .push()
                      .key;
              MessageData messageData = MessageData(
                messageId: messageId!,
                messageType: MessageType.addMember,
                senderId: userId,
                type: ChatType.groupNotification,
                timestamp: timestamp,
                members: membersArr,
              );
              final messageModel = messageData.toMap();
              FirebaseDatabase.instance
                  .ref("/chat/messages")
                  .child(groupId)
                  .child(messageId)
                  .set(messageModel)
                  .then((onValue) {
                    callback(groupId);
                  });
            });
      });
}

void updateProfilePic(
  UserData userData,
  String path,
  Function(String downloadURL) callback,
) {
  uploadImage(path, "user", (downloadURL) {
    callback(downloadURL);
    if (userData.imageUrl.isNotEmpty) {
      removeImage(userData.imageUrl);
    }
  });
}

void uploadImage(
  String path,
  String storagePath,
  Function(String downloadURL) callback,
) async {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  final uploadTask = _storageRef
      .child("$storagePath/${timestamp}_gallery")
      .putFile(File(path));
  final TaskSnapshot snapshot = await uploadTask;
  final String downloadURL = await snapshot.ref.getDownloadURL();
  callback(downloadURL);
}

void removeImage(String imageUrl) async {
  try {
    var imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    await imageRef.delete();
    print('Image deleted successfully from Firebase Storage');
  } on FirebaseException catch (e) {
    print('Failed to delete image: ${e.message}');
  }
}

void updateGroupImage() {
  //
}

void addMemberToGroup(
  String groupId,
  String userId,
  List<UserData> selectedMember,
  Function() callback,
) {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  List<Map<String, dynamic>> membersArr = [];
  Map<String, dynamic> groupMembers = {};

  for (var element in selectedMember) {
    membersArr.add({"uid": element.uid});
    Member otherUserModel = Member(
      unreadGroupCount: 0,
      uid: element.uid,
      active: true,
      deleteTill: timestamp,
      lastSeenMessageTimestamp: timestamp,
      admin: false,
    );
    groupMembers["chat/group/$groupId/members/${otherUserModel.uid}"] =
        otherUserModel.toMap();
    groupMembers["chat/users/${otherUserModel.uid}/group/$groupId"] = true;
  }
  _dbRef.update(groupMembers).then((_) {
    sendNotificationMessageToGroup(
      groupId,
      userId,
      MessageType.addMember,
      membersArr,
      (groupId, messageId) {
        callback();
      },
    );
  });
}

void changeAdminStatusOfUser(String groupId, String userId, bool isAdmin) {
  _dbRef.child('/chat/group/$groupId/members/$userId/admin').set(isAdmin);
}

void removeMemberFromGroup(
  String groupId,
  String removeMemberUserId,
  String userId,
  Function() callback,
) {
  _dbRef
      .child('/chat/group/$groupId/members/$removeMemberUserId/active')
      .set(false)
      .then((_) {
        sendNotificationMessageToGroup(
          groupId,
          userId,
          MessageType.removeMember,
          [
            {"uid": removeMemberUserId},
          ],
          (groupId, messageId) {
            callback();
          },
        );
      });
}

void clearChatHistory(String groupId, String uid, Function() callback) {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  _dbRef
      .child('/chat/group/$groupId/members/$uid/delete_till')
      .set(timestamp)
      .then((_) {
        callback();
      });
}

void exitGroup(
  String groupId,
  String userId,
  GroupData groupData,
  bool isSelfUserAdmin,
  Function() callback,
) {
  if (isSelfUserAdmin) {
    bool anyOtherAdminPresent = false;
    groupData.members.forEach((key, value) {
      if (value.uid != userId) {
        if (value.admin) {
          anyOtherAdminPresent = true;
        }
      }
    });

    if (anyOtherAdminPresent) {
      _dbRef
          .child('/chat/group/$groupId/members/$userId/active')
          .set(false)
          .then((_) {
            sendNotificationMessageToGroup(
              groupId,
              userId,
              MessageType.userLeft,
              [
                {"uid": userId},
              ],
              (groupId, messageId) {
                callback();
              },
            );
          });
    } else {
      var userIds = [];
      groupData.members.forEach((key, value) {
        if (value.uid != userId) {
          if (!value.admin) {
            userIds.add(value.uid);
          }
        }
      });
      // get random user uid index
      final random = Random();
      int randomIndex = random.nextInt(userIds.length);
      var randomUid = userIds[randomIndex];
      changeAdminStatusOfUser(groupId, randomUid, true);
      _dbRef
          .child('/chat/group/$groupId/members/$userId/active')
          .set(false)
          .then((_) {
            sendNotificationMessageToGroup(
              groupId,
              userId,
              MessageType.userLeft,
              [
                {"uid": userId},
              ],
              (groupId, messageId) {
                callback();
              },
            );
          });
    }
  } else {
    _dbRef.child('/chat/group/$groupId/members/$userId/active').set(false).then(
      (_) {
        sendNotificationMessageToGroup(
          groupId,
          userId,
          MessageType.userLeft,
          [
            {"uid": userId},
          ],
          (groupId, messageId) {
            callback();
          },
        );
      },
    );
  }
}

void deleteGroupForSelfAfterExit(
  String groupId,
  String userId,
  Function() callback,
) {
  _dbRef.child('/chat/users/$userId/group/$groupId').set(false).then((_) {
    callback();
  });
}

void deleteMessage(
  String groupId,
  MessageData messageData,
  MessageData lastMessageData,
) {
  Map<String, dynamic> updates = {};
  updates["chat/group/$groupId/lastMessage/is_deleted"] = true;
  updates["chat/messages/$groupId/${messageData.messageId}/is_deleted"] = true;
  _dbRef.update(updates);
}

void editMessage() {
  //
}

void uploadMediaImage() {
  //
}

void uploadMediaDocument() {
  //
}

void updateUnReadCountLastSeenMessageTimestamp() {
  //
}

void updateFCMTokenAndDeviceId(
  String deviceId,
  String fcmToken,
  String userId,
) {
  final deviceKey = _deviceIdDatabaseKey(deviceId);
  _dbRef.child('chat/users/$userId/deviceIds/$deviceKey').update({
    "fcm_token": fcmToken,
    "device_type": Platform.isAndroid ? "Android" : 'iOS',
  });
}

void removeFCMTokenAndDeviceIdOnSignout(
  String deviceId,
  String userId,
  Function() callback,
) async {
  final deviceKey = _deviceIdDatabaseKey(deviceId);
  await _dbRef.child('chat/users/$userId/deviceIds/$deviceKey').remove();
  callback();
}

// Real-time Read
Stream<DatabaseEvent> getUserStream(String userId) {
  return _dbRef.child('users/$userId').onValue;
}
