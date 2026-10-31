import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/models/group_detail_user_data.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/group/add_new_member_screen.dart';
import 'package:chat_app/screens/chats/group/edit_group_info.dart';
import 'package:chat_app/screens/chats/widgets/group_detail_member_list_item.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userChatGroups = ref.watch(chatProvider).userChatGroups;
    final usersList = ref.watch(chatProvider).usersList;
    final userData = ref.read(userProvider).user;
    bool isSelfUserAdmin =
        userChatGroups.containsKey(groupId)
            ? userChatGroups[groupId]!.members[userData.uid]!.admin
            : false;

    bool isSelfUserActive =
        userChatGroups.containsKey(groupId)
            ? userChatGroups[groupId]!.members[userData.uid]!.active
            : false;

    List<GroupDetailUserData> arr = [];
    if (userChatGroups.containsKey(groupId)) {
      for (var e in userChatGroups[groupId]!.members.values) {
        if (e.active == true) {
          if (e.uid == userData.uid) {
            arr.add(
              GroupDetailUserData(
                uid: userData.uid,
                name: '${userData.name} (You)',
                imageUrl: userData.imageUrl,
                status: userData.status,
                email: "",
                online: userData.online,
                lastSeenOnline: userData.lastSeenOnline,
                admin: e.admin!,
              ),
            );
          } else {
            UserData userData = usersList.firstWhere(
              (element) => element.uid == e.uid,
            );
            if (userData.uid.isNotEmpty) {
              arr.add(
                GroupDetailUserData(
                  uid: userData.uid,
                  name: userData.name,
                  imageUrl: userData.imageUrl,
                  status: userData.status,
                  email: "",
                  online: userData.online,
                  lastSeenOnline: userData.lastSeenOnline,
                  admin: e.admin!,
                ),
              );
            }
          }
        }
      }
    }

    final a1 = arr.where((element) => element.uid == userData.uid).toList();
    final a2 = arr.where(
      (element) => element.admin == true && element.uid != userData.uid,
    );
    final a3 = arr.where(
      (element) => element.admin == false && element.uid != userData.uid,
    );
    var membersList = [...a1, ...a2, ...a3];

    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Group detail"),
        backgroundColor: AppColors.whiteColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.greyColor,
                  width: 1.0, // Choose your thickness
                ),
              ),
            ),
          ),
        ),
        actions: [
          if (isSelfUserActive)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => EditGroupInfo(
                            groupId: userChatGroups[groupId]!.groupId,
                            groupImage: userChatGroups[groupId]!.imageUrl,
                            groupName: userChatGroups[groupId]!.name,
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
              if (!isSelfUserActive)
                Center(child: Text("You are no longer active member")),
              SizedBox(height: 15),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      userChatGroups[groupId]!.imageUrl != ""
                          ? NetworkImage(userChatGroups[groupId]!.imageUrl)
                          : AssetImage("assets/images/default_profile.png"),
                ),
              ),
              SizedBox(height: 15),
              Center(
                child: Text(
                  userChatGroups[groupId]!.name,
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
              if (isSelfUserAdmin && isSelfUserActive)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.whiteColor,
                  ),
                  child: ListTile(
                    title: Text("Add members"),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => AddNewMemberScreen(
                                groupId: userChatGroups[groupId]!.groupId,
                                addedMembers: membersList,
                              ),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                  ),
                ),
              if (isSelfUserAdmin && isSelfUserActive)
                Divider(
                  height: 1,
                  color: AppColors.greyColor,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.whiteColor,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) {
                    return GroupDetailMemberListItem(
                      item: membersList[index],
                      groupId: groupId,
                      isSelfUserActive: isSelfUserActive,
                      isSelfUserAdmin: isSelfUserAdmin,
                      onRemoveMember: (removeMemberUserId) {
                        // TODO: show dialog to confirm
                        removeMemberFromGroup(
                          groupId,
                          removeMemberUserId,
                          userData.uid,
                          () {
                            //
                          },
                        );
                      },
                    );
                  },
                  itemCount: membersList.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      color: AppColors.greyColor,
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
                  color: AppColors.whiteColor,
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
                                        color: AppColors.whiteColor,
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
                                        clearChatHistory(
                                          groupId,
                                          userData.uid,
                                          () {},
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color: AppColors.whiteColor,
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
                      color: AppColors.greyColor,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    if (isSelfUserActive)
                      InkWell(
                        onTap: () {
                          exitGroup(
                            groupId,
                            userData.uid,
                            userChatGroups[groupId]!,
                            isSelfUserAdmin,
                            () {
                              //
                            },
                          );
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 50,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "Exit Group",
                            style: ConstantStyles.regular.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    if (!isSelfUserActive)
                      InkWell(
                        onTap: () {
                          deleteGroupForSelfAfterExit(
                            groupId,
                            userData.uid,
                            () {
                              Navigator.popUntil(
                                context,
                                (route) => route.isFirst,
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
                            "Delete Group",
                            style: ConstantStyles.regular.copyWith(
                              fontSize: 16,
                            ),
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
