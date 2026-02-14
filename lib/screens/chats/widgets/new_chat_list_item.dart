import 'dart:developer';

import 'package:chat_app/models/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewChatListItem extends ConsumerStatefulWidget {
  const NewChatListItem({
    super.key,
    required this.item,
    required this.onSelectItem,
  });

  final GroupData item;
  final Function() onSelectItem;

  @override
  ConsumerState<NewChatListItem> createState() => _ChatsListItemState();
}

class _ChatsListItemState extends ConsumerState<NewChatListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        radius: 22,
        backgroundImage: AssetImage("assets/images/default_profile.png"),
      ),
      title: Text("", style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(''),
      trailing: Text("0"),
      onTap: widget.onSelectItem,
    );
  }
}
