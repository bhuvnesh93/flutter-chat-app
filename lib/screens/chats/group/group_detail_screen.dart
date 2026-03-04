import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/group/edit_group_info.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MenuItem { remove, removeAdmin }

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, GroupData> chatGroups = ref.watch(chatProvider).userChatGroups;
    List<UserData> usersList = ref.watch(chatProvider).usersList;
    UserData userData = ref.read(userProvider).user;

    List<dynamic> arr = [];
    for (var e in chatGroups[groupId]!.members.values) {
      if (e.uid == userData.uid) {
        arr.add({
          "uid": userData.uid,
          "name": '${userData.name} (You)',
          "image_url": userData.imageUrl,
          "status": userData.status,
          "online": userData.online,
          "last_seen_online": userData.lastSeenOnline,
          "admin": e.admin,
        });
      } else {
        UserData userData = usersList.firstWhere(
          (element) => element.uid == e.uid,
        );
        if (userData.uid.isNotEmpty) {
          arr.add({
            "uid": userData.uid,
            "name": userData.name,
            "image_url": userData.imageUrl,
            "status": userData.status,
            "online": userData.online,
            "last_seen_online": userData.lastSeenOnline,
            "admin": e.admin,
          });
        }
      }
    }

    final a1 = arr.where((element) => element["uid"] == userData.uid).toList();
    final a2 = arr.where(
      (element) => element["admin"] == true && element["uid"] != userData.uid,
    );
    final a3 = arr.where(
      (element) => element["admin"] == false && element["uid"] != userData.uid,
    );
    var membersList = [...a1, ...a2, ...a3];

    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Group detail"),
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => EditGroupInfo(
                          groupId: chatGroups[groupId]!.groupId,
                          groupImage: chatGroups[groupId]!.imageUrl,
                          groupName: chatGroups[groupId]!.name,
                        ),
                    fullscreenDialog: true,
                  ),
                );
              },
              icon: Icon(Icons.edit),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      chatGroups[groupId]!.imageUrl != ""
                          ? NetworkImage(chatGroups[groupId]!.imageUrl)
                          : AssetImage("assets/images/default_profile.png"),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  chatGroups[groupId]!.name,
                  style: ConstantStyles.bold.copyWith(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '${membersList.length} members',
                style: ConstantStyles.semiBold.copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage(
                          "assets/images/default_profile.png",
                        ),
                      ),
                      title: Text(membersList[index]["name"]),
                      onTap: null,
                      trailing:
                          membersList[index]["admin"] == true
                              ? Wrap(
                                spacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text("Admin"),
                                  if (chatGroups[groupId]!
                                              .members[userData.uid]!
                                              .admin ==
                                          true &&
                                      chatGroups[groupId]!
                                              .members[userData.uid]!
                                              .active ==
                                          true &&
                                      membersList[index]["uid"] != userData.uid)
                                    PopupMenuButton<MenuItem>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (MenuItem result) {
                                        // Handle the selected menu item
                                        if (result == MenuItem.remove) {
                                          //
                                        } else if (result ==
                                            MenuItem.removeAdmin) {
                                          //
                                        }
                                      },
                                      itemBuilder:
                                          (BuildContext context) =>
                                              <PopupMenuEntry<MenuItem>>[
                                                const PopupMenuItem<MenuItem>(
                                                  value: MenuItem.remove,
                                                  child: Text('Remove'),
                                                ),
                                                const PopupMenuItem<MenuItem>(
                                                  value: MenuItem.removeAdmin,
                                                  child: Text('Remove Admin'),
                                                ),
                                              ],
                                    ),
                                ],
                              )
                              : null,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    );
                  },
                  itemCount: membersList.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      color: Colors.grey,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                child: Wrap(
                                  runSpacing: 15.0,
                                  children: [
                                    Center(child: Text("Clear all messages?")),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "This chat will be empty but will remain in your chat list",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        //
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: Colors.white,
                                        ),
                                        padding: EdgeInsets.all(12),
                                        child: Text("Clear all messages"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 50,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Clear Chat",
                          style: ConstantStyles.regular.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    InkWell(
                      onTap: () {
                        print("exit group");
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 50,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Exit Group",
                          style: ConstantStyles.regular.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
