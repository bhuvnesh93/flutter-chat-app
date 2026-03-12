import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/chat_message_screen.dart';
import 'package:chat_app/screens/chats/group/add_member_screen.dart';
import 'package:chat_app/screens/chats/widgets/new_chat_list_item.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewChatScreen extends ConsumerWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.read(userProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "New Chat"),
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
      ),
      body: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => AddMemberScreen()),
              );
            },
            leading: CircleAvatar(
              radius: 23,
              backgroundColor: Colors.black,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.whiteColor,
                child: Icon(Icons.group, size: 30.0),
              ),
            ),
            title: Text(
              "New Group",
              style: ConstantStyles.medium.copyWith(fontSize: 16),
            ),
          ),
          Divider(
            height: 1, // Height of the divider
            color: AppColors.greyColor,
            thickness: 1, // Thickness of the divider line
            indent: 16, // Left padding
            endIndent: 16, // Right padding
          ),
          Consumer(
            builder: (context, ref, child) {
              final usersList = ref.watch(chatProvider).usersList;
              return Expanded(
                child: ListView.separated(
                  itemBuilder:
                      (ctx, index) => NewChatListItem(
                        item: usersList[index],
                        onSelectItem: () {
                          final selfUserId = userData.uid;
                          final otherUserId = usersList[index].uid;
                          String groupId = generatePrivateChatId(
                            selfUserId,
                            otherUserId,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (ctx) => ChatMessageScreen(
                                    groupId: groupId,
                                    chatType: DaialogType.oneOnOneChat,
                                    fromRoute: "NewChatScreen",
                                  ),
                            ),
                          );
                        },
                      ),
                  itemCount: usersList.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1, // Height of the divider
                      color: AppColors.greyColor,
                      thickness: 1, // Thickness of the divider line
                      indent: 16, // Left padding
                      endIndent: 16, // Right padding
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
