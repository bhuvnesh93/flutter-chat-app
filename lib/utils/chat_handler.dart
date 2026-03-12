import 'package:chat_app/constants/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

String uId(uid) {
  return 'uid-$uid';
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

// Write Data
Future<void> setUser(String userId, Map<String, dynamic> userData) async {
  await _dbRef.child('users/$userId').set(userData);
}

// Write Data
Future<void> updateOnlineOfflineStatus(String userId, bool isOnline) async {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  Map<String, dynamic> data = {
    "online": isOnline,
    "last_seen_online": timestamp,
  };
  await _dbRef.child('/chat/users/$userId').update(data).then((onValue) {});
}

Future<void> updateGroupName(
  String userId,
  String groupId,
  String groupName,
  Function() callback,
) async {
  await _dbRef.child('/chat/group/$groupId/name').set(groupName).then((
    onValue,
  ) {
    sendNotificationMessageToGroup(
      groupId,
      userId,
      NotificationMessageTypes.changeGroupName,
      [],
      (groupId, messageId) {
        callback();
      },
    );
  });
}

void sendNotificationMessageToGroup(
  String groupId,
  String selfUserId,
  String messageType,
  List<Map<String, dynamic>> members,
  Function(String groupId, String messageId) callback,
) async {
  int timestamp = DateTime.now().millisecondsSinceEpoch;
  String? messageId =
      FirebaseDatabase.instance.ref("/chat/messages").child(groupId).push().key;
  Map<String, dynamic> messageObj = {
    "sender_id": selfUserId,
    "timestamp": timestamp,
    "message_id": messageId,
    "message_type": messageType,
    "type": ChatType.groupNotification,
    "members": members,
  };

  await _dbRef.child("/chat/messages/$groupId/$messageId").set(messageObj).then(
    (onValue) {
      callback(groupId, messageId!);
    },
  );
}

// Real-time Read
Stream<DatabaseEvent> getUserStream(String userId) {
  return _dbRef.child('users/$userId').onValue;
}

// }
