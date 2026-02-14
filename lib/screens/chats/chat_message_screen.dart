import 'dart:developer';

import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/chats_screen.dart';
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
  bool _isSelfUserAdmin = false;

  void checkGroupExist() {
    final userData = ref.read(userProvider).user;
    final uid = userData.uid;
    Map<String, GroupData> userChatGroups =
        ref.read(chatProvider).userChatGroups;
    _isGroupExist = userChatGroups.containsKey(widget.groupId);
    print("dsdsd ${userChatGroups[widget.groupId]!.members[uid]?.admin}");
    if (_isGroupExist) {
      // _isSelfUserAdmin = userChatGroups[widget.groupId]?.members[uid]!.admin;
      _deleteTill = userChatGroups[widget.groupId]!.members[uid]!.deleteTill;
    }
  }

  void fetchAllMessages() {
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
            List<MessageData> data1 =
                myData.values
                    .map(
                      (entry) => MessageData(
                        messageId: entry["message_id"],
                        messageType: entry["message_type"],
                        senderId: entry["sender_id"],
                        type: entry["type"],
                        timestamp: entry["timestamp"],
                        message: entry?["message"] ?? "",
                        members: entry?["members"] ?? [],
                      ),
                    )
                    .toList();
            data1.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            setState(() {
              _messageList = data1;
            });
          });
    }
  }

  void fetchNewMessage() {
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
                        (entry) => MessageData(
                          messageId: entry["message_id"],
                          messageType: entry["message_type"],
                          senderId: entry["sender_id"],
                          type: entry["type"],
                          timestamp: entry["timestamp"],
                          message: entry["message"] ?? "",
                          members: entry?["members"] ?? [],
                        ),
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

  void prepareMessage(String messageType) {
    final userData = ref.read(userProvider).user;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String? messageId =
        FirebaseDatabase.instance
            .ref("/chat/messages")
            .child(widget.groupId)
            .push()
            .key;
    Map<String, dynamic> messageObj = {
      "message": _messageController.text,
      "sender_id": userData.uid,
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
          _messageController.clear();
        });
  }

  void createOneOnOneChatGroup(UserData user, UserData otherUse, callback) {
    //
  }

  void onSendMessage() {
    if (_isGroupExist) {
      prepareMessage(MessageType.text);
    } else {
      final userData = ref.read(userProvider).user;
      final usersList = ref.read(chatProvider).usersList;
      List<String> arr = widget.groupId.split("_");
      String otherUserId = arr.firstWhere((id) => id != userData.uid);
      final otherUser = usersList.firstWhere(
        (userItem) => userItem.uid == otherUserId,
      );
      createOneOnOneChatGroup(
        userData,
        otherUser,
        () => {
          // prepareMessage({message, messageType: '1'}),
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();

    checkGroupExist();

    fetchAllMessages();

    fetchNewMessage();
  }

  @override
  void didUpdateWidget(covariant ChatMessageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget renderItem(MessageData item) {
    final userData = ref.read(userProvider).user;
    final uid = userData.uid;
    if (item.type == ChatType.groupNotification) {
      return NotificationCell(item: item);
    } else if (item.senderId == uid) {
      return OutgoingChatCell(item: item);
    } else if (item.senderId != uid) {
      return IncomingChatCell(item: item, chatType: widget.chatType);
    }
    return Text("");
  }

  @override
  Widget build(BuildContext context) {
    final usersList = ref.watch(chatProvider).usersList;
    var chatGroups = ref.watch(chatProvider).userChatGroups;

    if (widget.chatType == DaialogType.oneOnOneChat) {
      final userData = ref.read(userProvider).user;
      List<String> arr = widget.groupId.split("_");
      String otherUserId = arr.firstWhere((id) => id != userData.uid);
      final otherUser = usersList.firstWhere(
        (userItem) => userItem.uid == otherUserId,
      );
      _title = otherUser.name;
      _status =
          otherUser.online
              ? "Online"
              : otherUser.lastSeenOnline > 0
              ? "Last seen ${chatIsTodayHeader(otherUser.lastSeenOnline) ? chatFormatTimeAMPM(otherUser.lastSeenOnline) : chatFormatDateDDMonthYYYY(chatFormatDate(otherUser.lastSeenOnline))}"
              : "Offline";
    } else {
      var groupDetail = chatGroups[widget.groupId];
      _title = groupDetail!.name;
      _status = "${groupDetail.members.length} Members";
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (widget.fromRoute == "CREATE_GROUP") {
              Navigator.popUntil(context, ModalRoute.withName("/ChatsScreen"));
            } else if (widget.fromRoute == "ChatsScreen") {
              Navigator.pop(context);
            }
          },
        ),
        title: InkWell(
          onTap: () {
            if (widget.chatType == DaialogType.oneOnOneChat) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => OtherUserProfileScreen()),
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
                    widget.chatType == DaialogType.oneOnOneChat
                        ? AssetImage("assets/images/default_profile.png")
                        : AssetImage("assets/images/default_group.png"),
              ),
              Container(
                margin: EdgeInsets.only(left: 8.0),
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
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (MenuItem result) {
              if (result == MenuItem.clearChat) {
                //
              } else if (result == MenuItem.exitGroup) {
                //
              } else if (result == MenuItem.deleteGroup) {
                //
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                  if (widget.chatType == DaialogType.oneOnOneChat)
                    const PopupMenuItem<MenuItem>(
                      value: MenuItem.clearChat,
                      child: Text('Clear Chat'),
                    ),
                  if (widget.chatType == DaialogType.groupChat &&
                      _isSelfUserAdmin) ...[
                    const PopupMenuItem<MenuItem>(
                      value: MenuItem.clearChat,
                      child: Text('Clear Chat'),
                    ),
                    const PopupMenuItem<MenuItem>(
                      value: MenuItem.exitGroup,
                      child: Text('Exit group'),
                    ),
                    const PopupMenuItem<MenuItem>(
                      value: MenuItem.deleteGroup,
                      child: Text('Delete Group'),
                    ),
                  ],
                ],
          ),
        ],
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
                  onPressed: () => onSendMessage(),
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
