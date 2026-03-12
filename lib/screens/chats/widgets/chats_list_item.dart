import 'dart:developer';

import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsListItem extends ConsumerWidget {
  const ChatsListItem({
    super.key,
    required this.item,
    required this.onSelectItem,
  });

  final GroupData item;
  final Function() onSelectItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersList = ref.watch(chatProvider).usersList;
    final userData = ref.read(userProvider).user;
    String groupName = "";
    String groupImage = "";

    if (item.group == false) {
      List<String> arr = item.groupId.split("_");
      String otherUserId = arr.firstWhere((id) => id != userData.uid);
      final otherUser = usersList.firstWhere(
        (userItem) => userItem.uid == otherUserId,
      );
      if (otherUser.uid.isNotEmpty) {
        groupName = otherUser.name;
        groupImage = otherUser.imageUrl;
      }
    } else {
      groupName = item.name;
      groupImage = item.imageUrl;
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        radius: 30,
        backgroundImage:
            groupImage.isNotEmpty
                ? NetworkImage(groupImage)
                : AssetImage(
                  item.group
                      ? "assets/images/default_group.png"
                      : "assets/images/default_profile.png",
                ),
      ),
      title: Text(groupName, style: ConstantStyles.bold.copyWith(fontSize: 17)),
      subtitle: Text(
        item.lastMessage?.message ?? "",
        style: ConstantStyles.regular.copyWith(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      onTap: onSelectItem,
    );
  }
}
