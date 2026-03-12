import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
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

    final userData = ref.read(userProvider).user;
    final usersList = ref.read(chatProvider).usersList;

    if (widget.item.senderId == userData.uid) {
      _userName = 'You';
    } else {
      UserData user = usersList.firstWhere(
        (element) => element.uid == widget.item.senderId,
      );
      _userName = user.name;
    }

    if (widget.item.messageId.isNotEmpty) {
      if (widget.item.messageType == MessageType.newGroup) {
        _message = "$_userName created this group";
      } else if (widget.item.messageType == MessageType.addMember) {
        String membersName = '';
        if (widget.item.members!.length > 1) {
          UserData user = usersList.firstWhere(
            (element) => element.uid == widget.item.members![0]["uid"],
          );
          membersName =
              "${user.name} and ${widget.item.members!.length - 1} others";
        } else {
          if (widget.item.members![0]["uid"] == userData.uid) {
            membersName = 'You';
          } else {
            UserData user = usersList.firstWhere(
              (element) => element.uid == widget.item.members![0]["uid"],
            );
            membersName = user.name;
          }
        }
        _message = "$_userName added $membersName";
      } else if (widget.item.messageType == MessageType.removeMember) {
        String membersName = '';

        if (widget.item.members![0]["uid"] == userData.uid) {
          membersName = 'You';
        } else {
          UserData user = usersList.firstWhere(
            (element) => element.uid == widget.item.members![0]["uid"],
          );
          membersName = user.name;
        }
        _message = "$_userName removed $membersName";
      } else if (widget.item.messageType == MessageType.changeGroupName) {
        _message = "$_userName changed the group name";
      } else if (widget.item.messageType == MessageType.changeGroupImage) {
        _message = "$_userName changed the group image";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _message,
        style: ConstantStyles.regular.copyWith(fontSize: 13),
      ),
    );
  }
}
