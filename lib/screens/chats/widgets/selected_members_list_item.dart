import 'dart:developer';

import 'package:chat_app/models/group.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedMembersListItem extends ConsumerStatefulWidget {
  const SelectedMembersListItem({
    super.key,
    required this.item,
    required this.onSelectItem,
  });

  final GroupData item;
  final Function() onSelectItem;

  @override
  ConsumerState<SelectedMembersListItem> createState() => _ChatsListItemState();
}

class _ChatsListItemState extends ConsumerState<SelectedMembersListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      // leading: CircleAvatar(
      //   backgroundImage: AssetImage(
      //     'assets/profile_pic.png',
      //   ),
      // ),
      title: Text("", style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(''),
      trailing: Text("0"),
      onTap: widget.onSelectItem,
    );
  }
}
