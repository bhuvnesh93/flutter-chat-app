import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomingChatCell extends ConsumerStatefulWidget {
  const IncomingChatCell({
    super.key,
    required this.item,
    required this.chatType,
  });

  final MessageData item;
  final String chatType;

  @override
  ConsumerState<IncomingChatCell> createState() => _IncomingChatCellState();
}

class _IncomingChatCellState extends ConsumerState<IncomingChatCell> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        List<UserData> usersList = ref.read(chatProvider).usersList;
        UserData userData = usersList.firstWhere(
          (id) => id.uid == widget.item.senderId,
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.chatType == DaialogType.groupChat)
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        userData.imageUrl != ""
                            ? NetworkImage(userData.imageUrl)
                            : AssetImage("assets/images/default_profile.png"),
                  ),
                  SizedBox(width: 8),
                ],
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  constraints: BoxConstraints(
                    minWidth: 100.0, // Minimum width of 100 logical pixels
                    maxWidth:
                        MediaQuery.of(context).size.width *
                        85 /
                        100, // Maximum width of 300 logical pixels
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.chatType == DaialogType.groupChat)
                        Consumer(
                          builder: (
                            BuildContext context,
                            WidgetRef ref,
                            Widget? child,
                          ) {
                            List<UserData> usersList =
                                ref.read(chatProvider).usersList;
                            UserData userData = usersList.firstWhere(
                              (id) => id.uid == widget.item.senderId,
                            );
                            return Text(
                              '~${userData.name}',
                              style: ConstantStyles.semiBold.copyWith(
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      Text(
                        widget.item.message!,
                        style: ConstantStyles.medium.copyWith(fontSize: 16),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          chatFormatTimeAMPM(widget.item.timestamp),
                          textAlign: TextAlign.right,
                          style: ConstantStyles.medium.copyWith(
                            fontSize: 13,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
