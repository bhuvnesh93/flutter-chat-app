import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter/material.dart';

class NewChatListItem extends StatelessWidget {
  const NewChatListItem({
    super.key,
    required this.item,
    required this.onSelectItem,
  });

  final UserData item;
  final Function() onSelectItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        radius: 23,
        backgroundImage: AssetImage("assets/images/default_profile.png"),
      ),
      title: Text(
        item.name,
        style: ConstantStyles.medium.copyWith(fontSize: 16),
      ),
      onTap: onSelectItem,
    );
  }
}
