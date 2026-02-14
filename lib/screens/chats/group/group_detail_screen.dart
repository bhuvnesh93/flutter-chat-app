import 'dart:developer';

import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, GroupData> chatGroups = ref.watch(chatProvider).userChatGroups;
    List<UserData> usersList = ref.watch(chatProvider).usersList;

    var arr = [];
    for (var e in chatGroups[groupId]!.members.values) {
      final userData = ref.read(userProvider).user;
      if (e.uid == userData.uid) {
        arr.add({
          "uid": userData.uid,
          "name": userData.name,
          "image_url": userData.imageUrl,
          "status": userData.status,
          "online": userData.online,
          "last_seen_online": userData.lastSeenOnline,
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
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Group detail")),
      body: Column(
        children: [
          Text(chatGroups[groupId]!.name),
          Expanded(
            child: ListView.builder(
              itemBuilder:
                  (ctx, index) => ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(
                        "assets/images/default_profile.png",
                      ),
                    ),
                    title: Text(arr[index]["name"]),
                    onTap: () {},
                  ),
              itemCount: arr.length,
            ),
          ),
        ],
      ),
    );
  }
}
