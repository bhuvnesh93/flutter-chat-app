import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationCell extends ConsumerStatefulWidget {
  const NotificationCell({super.key, required this.item});

  final MessageData item;

  @override
  ConsumerState<NotificationCell> createState() => _NotificationCellState();
}

class _NotificationCellState extends ConsumerState<NotificationCell> {
  String _userName = '';
  String _message = "";

  @override
  void initState() {
    super.initState();

    final MessageData item = widget.item;

    final userData = ref.read(userProvider).user;
    final usersList = ref.read(chatProvider).usersList;

    String name =
        usersList
            .firstWhere((element) => element.uid == widget.item.senderId)
            .name;
    setState(() {
      _userName = name;
    });

    if (item.messageId.isNotEmpty) {
      if (item.messageType == MessageType.newGroup) {
        if (item.senderId == userData.uid) {
          setState(() {
            _message = "You created this group";
          });
        } else {
          setState(() {
            _message = "$_userName created this group";
          });
        }
      } else if (item.messageType == MessageType.addMember) {
        String membersName = '';
        if (item.members!.length > 1) {
          if (item.members!.length - 1 > 1) {
            membersName =
                "${item.members[0]["name"]} and ${item.members!.length - 1} others";
          } else {
            membersName =
                "${item.members[0]["name"]} and ${item.members!.length - 1} other";
          }
        } else {
          membersName = "${item.members![0]["name"]}";
        }
        if (item.senderId == userData.uid) {
          setState(() {
            _message = "You added $membersName";
          });
        } else {
          setState(() {
            _message = "$_userName added $membersName";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(_message));
  }
}
