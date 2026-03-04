import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/chat_message_screen.dart';
import 'package:chat_app/widgets/app_header.dart';
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
  final _groupNameController = TextEditingController();

  void _createGroup() {
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
      membersArr.add({"uid": element.uid});
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
      "name": _groupNameController.text,
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder:
                                (ctx) => ChatMessageScreen(
                                  groupId: groupId,
                                  chatType: DaialogType.groupChat,
                                  fromRoute: "CREATE_GROUP",
                                ),
                          ),
                          (Route<dynamic> route) => route.isFirst,
                        );
                      }
                    });
              });
        });
  }

  void _onPressCreateGroup() async {
    if (_groupNameController.text == "") {
      //
    } else {
      _createGroup();
    }
  }

  @override
  void dispose() {
    // Remember to dispose of the controller when the widget is removed from the widget tree.
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Create Group"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            1.0,
          ), // Define the height of the divider
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera, size: 30.0),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _groupNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter group name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 5,
                  // mainAxisSpacing: 10,
                ),
                // scrollDirection: Axis.horizontal,
                itemBuilder:
                    (ctx, index) => Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 23,
                          backgroundImage: AssetImage(
                            "assets/images/default_profile.png",
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.selectedMember[index].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ],
                    ),
                itemCount: widget.selectedMember.length,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onPressCreateGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text("CREATE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
