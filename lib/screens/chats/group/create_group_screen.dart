import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/chat_message_screen.dart';
import 'package:chat_app/widgets/app_button.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key, required this.selectedMember});

  final List<UserData> selectedMember;

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  bool _isLoading = false;

  void _createGroup() {
    setState(() {
      _isLoading = true;
    });
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    var membersArr = [];
    Map<String, dynamic> groupMembers = {};
    final userData = ref.read(userProvider).user;
    Member adminUserModel = Member(
      unreadGroupCount: 0,
      uid: userData.uid,
      active: true,
      deleteTill: timestamp,
      lastSeenMessageTimestamp: timestamp,
      admin: true,
    );
    groupMembers[adminUserModel.uid] = adminUserModel.toMap();
    // Map<String, dynamic> adminUserModel = {
    //   "unread_group_count": 0,
    //   "last_seen_message_timestamp": timestamp,
    //   "uid": userData.uid,
    //   "delete_till": timestamp,
    //   "admin": true,
    //   "active": true,
    // };
    // groupMembers[adminUserModel["uid"]] = adminUserModel;
    for (var element in widget.selectedMember) {
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
      // Map<String, dynamic> otherUserModel = {
      //   "unread_group_count": 0,
      //   "last_seen_message_timestamp": timestamp,
      //   "uid": element.uid,
      //   "delete_till": timestamp,
      //   "admin": false,
      //   "active": true,
      // };
      // groupMembers[otherUserModel["uid"]] = otherUserModel;
    }
    String? groupId = FirebaseDatabase.instance.ref("/chat/group").push().key;
    // Map<String, dynamic> newGroup = {
    //   "group": true,
    //   "name": _groupNameController.text,
    //   "image_url": "",
    //   "group_deleted": false,
    //   "members": groupMembers,
    //   "created_by": adminUserModel["uid"],
    //   "group_id": groupId,
    //   "timestamp": timestamp,
    // };
    GroupData groupData = GroupData(
      groupId: groupId!,
      imageUrl: "",
      members: groupMembers,
      name: _groupNameController.text,
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
          String? messageId =
              FirebaseDatabase.instance
                  .ref("/chat/messages")
                  .child(groupId)
                  .push()
                  .key;
          // Map<String, dynamic> messageModel = {
          //   "sender_id": userData.uid,
          //   "timestamp": timestamp,
          //   "message_id": messageId,
          //   "message_type": MessageType.newGroup,
          //   "type": ChatType.groupNotification,
          //   "members": [""],
          // };
          MessageData messageData = MessageData(
            messageId: messageId!,
            messageType: MessageType.newGroup,
            senderId: userData.uid,
            type: ChatType.groupNotification,
            timestamp: timestamp,
            message: "",
            members: [],
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
                  senderId: userData.uid,
                  type: ChatType.groupNotification,
                  timestamp: timestamp,
                  members: membersArr,
                  message: "",
                );
                final messageModel = messageData.toMap();
                // Map<String, dynamic> messageModel = {
                //   "sender_id": userData.uid,
                //   "timestamp": timestamp,
                //   "message_id": messageId,
                //   "message_type": MessageType.addMember,
                //   "type": ChatType.groupNotification,
                //   "members": membersArr,
                // };
                FirebaseDatabase.instance
                    .ref("/chat/messages")
                    .child(groupId)
                    .child(messageId)
                    .set(messageModel)
                    .then((onValue) {
                      setState(() {
                        _isLoading = false;
                      });
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
      toastification.show(
        context: context,
        type: ToastificationType.info,
        title: Text('Enter Group Name'),
        autoCloseDuration: const Duration(seconds: 3),
        style: ToastificationStyle.minimal,
        alignment: Alignment.bottomCenter,
        direction: TextDirection.ltr,
      );
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
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.greyColor, width: 1.0),
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
                      backgroundColor: AppColors.whiteColor,
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
            Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                text: "CREATE",
                onPress: _onPressCreateGroup,
                isLoading: _isLoading,
              ),
            ),
            // SizedBox(
            //   width: double.infinity,
            //   height: 50,
            //   child: ElevatedButton(
            //     onPressed: _onPressCreateGroup,
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryColor,
            //       foregroundColor: AppColors.whiteColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(0),
            //       ),
            //     ),
            //     child: Text("CREATE"),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
