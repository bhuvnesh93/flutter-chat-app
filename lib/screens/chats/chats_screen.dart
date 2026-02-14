import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/authentication/login_screen.dart';
import 'package:chat_app/screens/chats/chat_message_screen.dart';
import 'package:chat_app/screens/chats/new_chat_screen.dart';
import 'package:chat_app/screens/profile/profile_detail_screen.dart';
import 'package:chat_app/screens/chats/widgets/chats_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MenuItem { profile, logout }

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  void prepareGroupDataModel(value) {
    Map<String, dynamic> myData = Map<String, dynamic>.from(value as Map);
    try {
      Map<String, Member> members = Map.from(myData["members"]).map(
        (k, v) => MapEntry<String, Member>(
          k,
          Member(
            unreadGroupCount: v["unread_group_count"],
            uid: v["uid"],
            active: v['active'],
            deleteTill: v["delete_till"],
            lastSeenMessageTimestamp: v["last_seen_message_timestamp"],
            admin: v?["admin"] ?? false,
          ),
        ),
      );
      print(members);
      LastMessage? lastMessage =
          myData.containsKey("lastMessage")
              ? LastMessage(
                messageId: myData["lastMessage"]?["message_id"],
                messageType: myData["lastMessage"]?["message_type"],
                message: myData["lastMessage"]?["message"],
                type: myData["lastMessage"]?["type"],
                senderId: myData["lastMessage"]?["sender_id"],
                timestamp: myData["lastMessage"]?["timestamp"],
              )
              : null;
      GroupData groupData = GroupData(
        groupId: myData["group_id"],
        imageUrl: myData["image_url"]!,
        members: members,
        lastMessage: lastMessage,
        name: myData["name"]!,
        createdBy: myData["created_by"],
        groupDeleted: myData["group_deleted"],
        group: myData["group"],
        timestamp: myData["timestamp"],
      );

      ref.read(chatProvider.notifier).saveUserChatGroups(groupData);
    } on Exception catch (e) {
      print("e $e");
    }
  }

  void _fetchUserGroups() async {
    final userData = ref.read(userProvider).user;
    String uid = userData.uid;
    DatabaseReference userRef = FirebaseDatabase.instance.ref(
      "/chat/users/$uid/group",
    );
    DatabaseReference groupRef = FirebaseDatabase.instance.ref("/chat/group");
    userRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        final originalMap = event.snapshot.value as Map<Object?, Object?>;
        Map<String, dynamic> groups = originalMap.cast<String, dynamic>();
        groups.forEach((key, value) async {
          if (value == true) {
            final dataSnapshot = await groupRef.child(key).get();
            print(dataSnapshot.value);
            if (dataSnapshot.value != null && dataSnapshot.value is Map) {
              prepareGroupDataModel(dataSnapshot.value);
            }
          } else {
            ref.read(chatProvider.notifier).removeGroup(key);
          }
        });
      }
    });
  }

  void _fetchGroupsChildUpdated() {
    FirebaseDatabase.instance.ref("/chat/group").onChildChanged.listen((
      DatabaseEvent event,
    ) {
      prepareGroupDataModel(event.snapshot.value);
    });
  }

  void _fetchUsersOnce() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref("/chat/users");
    final snapshot = await usersRef.get();
    if (snapshot.exists) {
      final originalMap = snapshot.value as Map<Object?, Object?>;
      Map<String, dynamic> userList = originalMap.cast<String, dynamic>();
      List<UserData> data1 =
          userList.values
              .map(
                (entry) => UserData(
                  uid: entry["uid"],
                  name: entry["name"],
                  imageUrl: entry["image_url"],
                  status: entry["status"],
                  email: entry["email"],
                  online: entry["online"],
                  lastSeenOnline: entry["last_seen_online"],
                ),
              )
              .toList();
      ref.read(chatProvider.notifier).saveUsersList(data1);
    }
  }

  void _fetchUserChildUpdates() {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref("/chat/users");
    usersRef.onChildChanged.listen((DatabaseEvent event) {
      var userList = ref.read(chatProvider).usersList;
      final originalMap = event.snapshot.value as Map<Object?, Object?>;
      Map<String, dynamic> users = originalMap.cast<String, dynamic>();
      UserData userData = UserData.fromJson(users);
      int indexToUpdate = userList.indexWhere(
        (user) => user.uid == originalMap["uid"],
      );
      if (indexToUpdate != -1) {
        userList[indexToUpdate] = userData; // Updates 'Bob' to 'Robert'
      }
      ref.read(chatProvider.notifier).saveUsersList(userList);
    });
  }

  @override
  void initState() {
    super.initState();

    // fetch all users once
    _fetchUsersOnce();

    // listen on users child changed
    _fetchUserChildUpdates();

    // listen on user groups and update group information
    _fetchUserGroups();

    // listen on group updated
    _fetchGroupsChildUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (MenuItem result) {
              // Handle the selected menu item
              if (result == MenuItem.profile) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => ProfileDetailScreen()),
                );
              } else if (result == MenuItem.logout) {
                FirebaseAuth.instance.signOut();
                ref
                    .read(userProvider.notifier)
                    .saveUserData(
                      UserData(
                        uid: "",
                        name: "",
                        imageUrl: "",
                        status: "",
                        email: "",
                        online: false,
                        lastSeenOnline: 0,
                      ),
                    );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (ctx) => LoginScreen()),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                  const PopupMenuItem<MenuItem>(
                    value: MenuItem.profile,
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem<MenuItem>(
                    value: MenuItem.logout,
                    child: Text('Logout'),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => NewChatScreen()),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "New Chat",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Consumer(
            builder: (consumerContext, ref, child) {
              List<GroupData> data =
                  ref.watch(chatProvider).userChatGroups.values.toList();
              data.sort((GroupData a, GroupData b) {
                if (a.lastMessage == null && b.lastMessage == null) {
                  return b.timestamp - a.timestamp;
                } else if (a.lastMessage == null) {
                  return (b.lastMessage?.timestamp ?? 0) - a.timestamp;
                } else if (b.lastMessage == null) {
                  return b.timestamp - (a.lastMessage?.timestamp ?? 0);
                } else {
                  return (b.lastMessage?.timestamp ?? 0) -
                      (a.lastMessage?.timestamp ?? 0);
                }
              });
              if (data.isNotEmpty) {
                return Expanded(
                  child: ListView.separated(
                    itemBuilder:
                        (ctx, index) => ChatsListItem(
                          item: data[index],
                          onSelectItem: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (ctx) => ChatMessageScreen(
                                      groupId: data[index].groupId,
                                      chatType:
                                          data[index].group == true
                                              ? DaialogType.groupChat
                                              : DaialogType.oneOnOneChat,
                                      fromRoute: "ChatsScreen",
                                    ),
                              ),
                            );
                          },
                        ),
                    itemCount: data.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1, // Height of the divider
                        color: Colors.grey, // Color of the divider
                        thickness: 1, // Thickness of the divider line
                        indent: 16, // Left padding
                        endIndent: 16, // Right padding
                      );
                    },
                  ),
                );
              } else {
                return Center(child: Text("No data"));
              }
            },
          ),
        ],
      ),
    );
  }
}
