import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/group_detail_user_data.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/group/edit_group_info.dart';
import 'package:chat_app/screens/chats/widgets/group_detail_member_list_item.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, GroupData> chatGroups = ref.watch(chatProvider).userChatGroups;
    List<UserData> usersList = ref.watch(chatProvider).usersList;
    UserData userData = ref.read(userProvider).user;

    List<GroupDetailUserData> arr = [];
    for (var e in chatGroups[groupId]!.members.values) {
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
                  color: AppColors.whiteColor,
                ),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (ctx, index) {
                    return GroupDetailMemberListItem(
                      item: membersList[index],
                      groupId: groupId,
                      isSelfUserActive: true,
                      onRemoveMember: () {
                        //
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
                                        //
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
                    InkWell(
                      onTap: () {
                        logging("exit group");
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

  void _onRemoveMember() {}
}
