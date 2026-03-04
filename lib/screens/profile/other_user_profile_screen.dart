import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtherUserProfileScreen extends ConsumerWidget {
  const OtherUserProfileScreen({super.key, required this.otherUserId});

  final String otherUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersList = ref.watch(chatProvider).usersList;

    final otherUser = usersList.firstWhere(
      (element) => element.uid == otherUserId,
    );

    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Other Profile"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey, // Choose your color
                  width: 1.0, // Choose your thickness
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  otherUser.imageUrl != ""
                      ? NetworkImage(otherUser.imageUrl)
                      : AssetImage("assets/images/default_profile.png"),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 32.0),
              child: Row(
                children: [
                  Icon(Icons.person, size: 30.0),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name",
                            style: ConstantStyles.bold.copyWith(fontSize: 16),
                          ),
                          Text(otherUser.name),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.email, size: 30.0),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: ConstantStyles.bold.copyWith(fontSize: 16),
                        ),
                        Text(otherUser.email),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
