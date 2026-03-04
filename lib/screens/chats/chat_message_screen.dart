import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/group/group_detail_screen.dart';
import 'package:chat_app/screens/chats/widgets/incoming_chat_cell.dart';
import 'package:chat_app/screens/chats/widgets/notification_cell.dart';
import 'package:chat_app/screens/chats/widgets/outgoing_chat_cell.dart';
import 'package:chat_app/screens/profile/other_user_profile_screen.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';

enum MenuItem { clearChat, exitGroup, deleteGroup }

class ChatMessageScreen extends ConsumerStatefulWidget {
  const ChatMessageScreen({
    super.key,
    required this.chatType,
    required this.groupId,
    required this.fromRoute,
  });

  final String chatType;
  final String groupId;
  final String fromRoute;

  @override
  ConsumerState<ChatMessageScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatMessageScreen> {
  int _deleteTill = 0;
  bool _isGroupExist = true;
  List<MessageData> _messageList = [];
  final _messageController = TextEditingController();
  String _title = "User";
  String _status = "Online";
  String _image = "";
  // final bool _isSelfUserAdmin = false;
  late UserData _userData;
  late String _uid;

  void _checkGroupExist() {
    Map<String, GroupData> userChatGroups =
        ref.read(chatProvider).userChatGroups;
    _isGroupExist = userChatGroups.containsKey(widget.groupId);
    if (_isGroupExist) {
      // _isSelfUserAdmin = userChatGroups[widget.groupId]?.members[uid]!.admin;
      _deleteTill = userChatGroups[widget.groupId]!.members[_uid]!.deleteTill;
    }
  }

  void _fetchAllMessages() {
    if (_deleteTill > 0) {
      FirebaseDatabase.instance
          .ref("/chat/messages")
          .child(widget.groupId)
          .orderByChild("timestamp")
          .get()
          .then((DataSnapshot dataSnapshot) {
            Map<String, dynamic> myData = Map<String, dynamic>.from(
              dataSnapshot.value as Map,
            );
            List<MessageData> list =
                myData.values
                    .map(
                      (map) => MessageData.fromMap(map.cast<String, dynamic>()),
                    )
                    .toList();
            list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            setState(() {
              _messageList = list;
            });
          });
    }
  }

  void _fetchNewMessage() {
    if (_deleteTill > 0) {
      FirebaseDatabase.instance
          .ref("/chat/messages")
          .child(widget.groupId)
          .orderByKey()
          .limitToLast(1)
          .onValue
          .listen((DatabaseEvent event) {
            if (event.snapshot.exists) {
              Map<String, dynamic> messageModel = Map<String, dynamic>.from(
                event.snapshot.value as Map,
              );
              List<MessageData> lastMessage =
                  messageModel.values
                      .map(
                        (entry) =>
                            MessageData.fromMap(entry.cast<String, dynamic>()),
                      )
                      .toList();
              if (lastMessage[0].timestamp > _deleteTill) {
                var arr = _messageList;
                arr.insert(0, lastMessage[0]);
                setState(() {
                  _messageList = arr;
                });
              }
            }
          });
    }
  }

  void _prepareMessage(String messageType) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String? messageId =
        FirebaseDatabase.instance
            .ref("/chat/messages")
            .child(widget.groupId)
            .push()
            .key;
    Map<String, dynamic> messageObj = {
      "message": _messageController.text,
      "sender_id": _uid,
      "timestamp": timestamp,
      "message_id": messageId,
      "message_type": messageType,
      "type": ChatType.chatMessage,
    };
    FirebaseDatabase.instance
        .ref("/chat/group")
        .child(widget.groupId)
        .child("lastMessage")
        .set(messageObj)
        .then((onValue) {});
    FirebaseDatabase.instance
        .ref("/chat/messages")
        .child(widget.groupId)
        .child(messageId!)
        .set(messageObj)
        .then((onValue) {
          if (mounted) {
            _messageController.clear();
          }
        });
  }

  void _createOneOnOneChatGroup(UserData user, UserData otherUser) {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var groupMembers = {};
    Map<String, dynamic> otherUserModel = {
      "unread_group_count": 0,
      "last_seen_message_timestamp": timestamp,
      "uid": otherUser.uid,
      "delete_till": timestamp,
      "active": true,
    };
    groupMembers[otherUserModel["uid"]] = otherUserModel;

    Map<String, dynamic> userModel = {
      "unread_group_count": 0,
      "last_seen_message_timestamp": timestamp,
      "uid": user.uid,
      "delete_till": timestamp,
      "active": true,
    };
    groupMembers[userModel["uid"]] = userModel;

    String groupId = generatePrivateChatId(user.uid, otherUser.uid);
    Map<String, dynamic> newGroup = {
      "group": false,
      "name": "",
      "image_url": "",
      "group_deleted": false,
      "members": groupMembers,
      "created_by": userModel["uid"],
      "group_id": groupId,
      "timestamp": timestamp,
    };
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
                  if (mounted) {
                    _prepareMessage(MessageType.text);
                  }
                });
          });
        });
  }

  void _onSendMessage(usersList) {
    if (_messageController.text.isEmpty) {
      print("message empty");
    } else {
      if (_isGroupExist) {
        _prepareMessage(MessageType.text);
      } else {
        List<String> arr = widget.groupId.split("_");
        String otherUserId = arr.firstWhere((id) => id != _uid);
        final otherUser = usersList.firstWhere(
          (userItem) => userItem.uid == otherUserId,
        );
        _createOneOnOneChatGroup(_userData, otherUser);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _userData = ref.read(userProvider).user;
    _uid = _userData.uid;

    _checkGroupExist();

    _fetchAllMessages();

    _fetchNewMessage();
  }

  @override
  void didUpdateWidget(covariant ChatMessageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget renderItem(MessageData item) {
    if (item.type == ChatType.groupNotification) {
      return NotificationCell(item: item);
    } else if (item.senderId == _uid) {
      return OutgoingChatCell(item: item);
    } else if (item.senderId != _uid) {
      return IncomingChatCell(item: item, chatType: widget.chatType);
    }
    return Text("");
  }

  @override
  Widget build(BuildContext context) {
    final usersList = ref.watch(chatProvider).usersList;
    final userChatGroups = ref.watch(chatProvider).userChatGroups;

    _isGroupExist = userChatGroups.containsKey(widget.groupId);
    if (_isGroupExist) {
      // _isSelfUserAdmin = userChatGroups[widget.groupId]?.members[uid]!.admin;
      _deleteTill = userChatGroups[widget.groupId]!.members[_uid]!.deleteTill;
    }

    if (widget.chatType == DaialogType.oneOnOneChat) {
      List<String> arr = widget.groupId.split("_");
      String otherUserId = arr.firstWhere((id) => id != _uid);
      final otherUser = usersList.firstWhere(
        (userItem) => userItem.uid == otherUserId,
      );
      _title = otherUser.name;
      _image = otherUser.imageUrl;
      _status =
          otherUser.online
              ? "Online"
              : otherUser.lastSeenOnline > 0
              ? "Last seen ${chatIsTodayHeader(otherUser.lastSeenOnline) ? chatFormatTimeAMPM(otherUser.lastSeenOnline) : chatFormatDateDDMonthYYYY(chatFormatDate(otherUser.lastSeenOnline))}"
              : "Offline";
    } else {
      var groupDetail = userChatGroups[widget.groupId];
      _title = groupDetail!.name;
      _image = groupDetail.imageUrl;
      _status = "${groupDetail.members.length} Members";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey, // Choose your color
                  width: 1.0, // Choose your thickness
                ),
              ),
            ),
          ),
        ),
        leading: BackButton(
          onPressed: () {
            if (widget.fromRoute == "CREATE_GROUP") {
              Navigator.popUntil(context, ModalRoute.withName("/ChatsScreen"));
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: InkWell(
          onTap: () {
            if (widget.chatType == DaialogType.oneOnOneChat) {
              final arr = widget.groupId.split('_');
              final otherUserId = arr.firstWhere((id) => id != _uid);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (ctx) => OtherUserProfileScreen(otherUserId: otherUserId),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => GroupDetailScreen(groupId: widget.groupId),
                ),
              );
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage:
                    _image != ""
                        ? NetworkImage(_image)
                        : widget.chatType == DaialogType.oneOnOneChat
                        ? AssetImage("assets/images/default_profile.png")
                        : AssetImage("assets/images/default_group.png"),
              ),
              Container(
                margin: EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_title, style: TextStyle(fontSize: 16.0)),
                    Container(
                      margin: EdgeInsets.only(top: 3.0),
                      child: Text(_status, style: TextStyle(fontSize: 14.0)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: GroupedListView<MessageData, String>(
                elements: _messageList,
                groupBy: (element) => chatFormatDate(element.timestamp),
                groupSeparatorBuilder:
                    (String groupByValue) => Text(
                      chatIsToday(groupByValue)
                          ? 'Today'
                          : chatIsYesterday(groupByValue)
                          ? 'Yesterday'
                          : chatFormatDateDDMonthYYYY(groupByValue),
                      textAlign: TextAlign.center,
                    ),
                itemBuilder: (context, dynamic element) => renderItem(element),
                floatingHeader: true,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Message',
                    ),
                  ),
                ),
                SizedBox(width: 20),
                TextButton(
                  onPressed: () => _onSendMessage(usersList),
                  child: Center(child: Text("Send")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
