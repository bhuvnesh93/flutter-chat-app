import 'dart:developer';

import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsListItem extends ConsumerStatefulWidget {
  const ChatsListItem({
    super.key,
    required this.item,
    required this.onSelectItem,
  });

  final GroupData item;
  final Function() onSelectItem;

  @override
  ConsumerState<ChatsListItem> createState() => _ChatsListItemState();
}

class _ChatsListItemState extends ConsumerState<ChatsListItem> {
  String _groupName = "";

  void _calculateGroupName() {
    var data = widget.item;
    final userDataProviderRef = ref.read(userProvider).user;
    final chatProviderRef = ref.read(chatProvider).usersList;
    if (data.group == false) {
      List<String> arr = data.groupId.split("_");
      String otherUserId = arr.firstWhere(
        (id) => id != userDataProviderRef.uid,
      );
      final otherUser = chatProviderRef.firstWhere(
        (userItem) => userItem.uid == otherUserId,
      );
      if (otherUser.uid.isNotEmpty) {
        _groupName = otherUser.name;
      }
    } else {
      _groupName = data.name;
    }
  }

  @override
  void initState() {
    super.initState();

    _calculateGroupName();
  }

  @override
  void didUpdateWidget(covariant ChatsListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    _calculateGroupName();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        radius: 22,
        backgroundImage:
            widget.item.group == true
                ? AssetImage("assets/images/default_group.png")
                : AssetImage("assets/images/default_profile.png"),
      ),
      title: Text(_groupName, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(widget.item.lastMessage?.message ?? ""),
      // trailing: Text("0"),
      onTap: widget.onSelectItem,
    );
  }
}
