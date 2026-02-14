import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/chat_message_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key, required this.selectedMember});

  final List<UserData> selectedMember;

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final groupNameController = TextEditingController();

  void createGroup() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    final userData = ref.read(userProvider).user;
    Map<String, dynamic> adminUserModel = {
      "unread_group_count": 0,
      "last_seen_message_timestamp": timestamp,
      "uid": userData.uid,
      "delete_till": timestamp,
      "admin": true,
      "active": true,
    };
    var membersArr = [];
    var groupMembers = {};
    for (var element in widget.selectedMember) {
      membersArr.add({"name": element.name, "uid": element.uid});
      Map<String, dynamic> otherUserModel = {
        "unread_group_count": 0,
        "last_seen_message_timestamp": timestamp,
        "uid": element.uid,
        "delete_till": timestamp,
        "admin": false,
        "active": true,
      };
      groupMembers[otherUserModel["uid"]] = otherUserModel;
    }
    groupMembers[adminUserModel["uid"]] = adminUserModel;
    String? groupId = FirebaseDatabase.instance.ref("/chat/group").push().key;
    Map<String, dynamic> newGroup = {
      "group": true,
      "name": groupNameController.text,
      "image_url": "",
      "group_deleted": false,
      "members": groupMembers,
      "created_by": adminUserModel["uid"],
      "group_id": groupId,
      "timestamp": timestamp,
    };
    FirebaseDatabase.instance
        .ref("/chat/group")
        .child(groupId!)
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
          String? messageId =
              FirebaseDatabase.instance
                  .ref("/chat/messages")
                  .child(groupId)
                  .push()
                  .key;
          Map<String, dynamic> messageModel = {
            "sender_id": userData.uid,
            "timestamp": timestamp,
            "message_id": messageId,
            "message_type": MessageType.newGroup,
            "type": ChatType.groupNotification,
            "members": [""],
          };
          FirebaseDatabase.instance
              .ref("/chat/messages")
              .child(groupId)
              .child(messageId!)
              .set(messageModel)
              .then((onValue) {
                String? messageId =
                    FirebaseDatabase.instance
                        .ref("/chat/messages")
                        .child(groupId)
                        .push()
                        .key;
                Map<String, dynamic> messageModel = {
                  "sender_id": userData.uid,
                  "timestamp": timestamp,
                  "message_id": messageId,
                  "message_type": MessageType.addMember,
                  "type": ChatType.groupNotification,
                  "members": membersArr,
                };
                FirebaseDatabase.instance
                    .ref("/chat/messages")
                    .child(groupId)
                    .child(messageId!)
                    .set(messageModel)
                    .then((onValue) {
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (ctx) => ChatMessageScreen(
                                  groupId: groupId,
                                  chatType: DaialogType.groupChat,
                                  fromRoute: "CREATE_GROUP",
                                ),
                          ),
                        );
                      }
                    });
              });
        });
  }

  void _onPressCreateGroup() async {
    if (groupNameController.text == "") {
      //
    } else {
      createGroup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Group")),
      body: Column(
        children: [
          TextFormField(
            controller: groupNameController,
            decoration: const InputDecoration(hintText: 'Enter group name'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemBuilder:
                  (ctx, index) =>
                      ListTile(title: Text(widget.selectedMember[index].name)),
              itemCount: widget.selectedMember.length,
            ),
          ),
          ElevatedButton(onPressed: _onPressCreateGroup, child: Text("CREATE")),
        ],
      ),
    );
  }
}
