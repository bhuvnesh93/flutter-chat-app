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
