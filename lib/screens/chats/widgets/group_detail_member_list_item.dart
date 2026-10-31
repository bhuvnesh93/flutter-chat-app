import 'package:chat_app/models/group_detail_user_data.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MenuItem { remove, removeAdmin, makeAdmin }

class GroupDetailMemberListItem extends ConsumerWidget {
  const GroupDetailMemberListItem({
    super.key,
    required this.item,
    required this.groupId,
    required this.isSelfUserActive,
    required this.isSelfUserAdmin,
    required this.onRemoveMember,
  });

  final GroupDetailUserData item;
  final String groupId;
  final bool isSelfUserActive;
  final bool isSelfUserAdmin;
  final Function(String userId) onRemoveMember;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final userChatGroups = ref.watch(chatProvider).userChatGroups;
    final userData = ref.read(userProvider).user;
    bool isOverFlowShown = false;

    // final groupDetail = userChatGroups[groupId];
    if (isSelfUserAdmin && isSelfUserActive && item.uid != userData.uid) {
      isOverFlowShown = true;
    } else {
      isOverFlowShown = false;
    }

    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundImage:
            item.imageUrl.isNotEmpty
                ? NetworkImage(item.imageUrl)
                : AssetImage("assets/images/default_profile.png"),
      ),
      title: Text(item.name),
      onTap: null,

      trailing: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (item.admin) Text("Admin"),
          isOverFlowShown && !item.admin
              ? PopupMenuButton<MenuItem>(
                icon: const Icon(Icons.more_vert),
                onSelected: (MenuItem result) {
                  if (result == MenuItem.remove) {
                    onRemoveMember(item.uid);
                  } else if (result == MenuItem.makeAdmin) {
                    changeAdminStatusOfUser(groupId, item.uid, true);
                  }
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                      const PopupMenuItem<MenuItem>(
                        value: MenuItem.remove,
                        child: Text('Remove'),
                      ),
                      const PopupMenuItem<MenuItem>(
                        value: MenuItem.makeAdmin,
                        child: Text('Make Admin'),
                      ),
                    ],
              )
              : isOverFlowShown && item.admin
              ? PopupMenuButton<MenuItem>(
                icon: const Icon(Icons.more_vert),
                onSelected: (MenuItem result) {
                  if (result == MenuItem.remove) {
                    onRemoveMember(item.uid);
                  } else if (result == MenuItem.removeAdmin) {
                    changeAdminStatusOfUser(groupId, item.uid, false);
                  }
                },
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                      const PopupMenuItem<MenuItem>(
                        value: MenuItem.remove,
                        child: Text('Remove'),
                      ),
                      const PopupMenuItem<MenuItem>(
                        value: MenuItem.removeAdmin,
                        child: Text('Remove Admin'),
                      ),
                    ],
              )
              : Text(""),
        ],
      ),
      // trailing:
      //     item.admin == true
      //         ? Wrap(
      //           spacing: 8,
      //           crossAxisAlignment: WrapCrossAlignment.center,
      //           children: [
      //             Text("Admin"),
      //             if (chatGroups[groupId]!.members[userData.uid]!.admin ==
      //                     true &&
      //                 chatGroups[groupId]!.members[userData.uid]!.active ==
      //                     true &&
      //                 item.uid != userData.uid)
      //               PopupMenuButton<MenuItem>(
      //                 icon: const Icon(Icons.more_vert),
      //                 onSelected: (MenuItem result) {
      //                   // Handle the selected menu item
      //                   if (result == MenuItem.remove) {
      //                     onRemoveMember();
      //                   } else if (result == MenuItem.removeAdmin) {
      //                     //
      //                   }
      //                 },
      //                 itemBuilder:
      //                     (BuildContext context) => <PopupMenuEntry<MenuItem>>[
      //                       const PopupMenuItem<MenuItem>(
      //                         value: MenuItem.remove,
      //                         child: Text('Remove'),
      //                       ),
      //                       const PopupMenuItem<MenuItem>(
      //                         value: MenuItem.removeAdmin,
      //                         child: Text('Remove Admin'),
      //                       ),
      //                     ],
      //               ),
      //           ],
      //         )
      //         : chatGroups[groupId]!.members[userData.uid]!.admin == true &&
      //             chatGroups[groupId]!.members[userData.uid]!.active == true &&
      //             item.uid != userData.uid
      //         ? PopupMenuButton<MenuItem>(
      //           icon: const Icon(Icons.more_vert),
      //           onSelected: (MenuItem result) {
      //             if (result == MenuItem.remove) {
      //               onRemoveMember();
      //             } else if (result == MenuItem.removeAdmin) {}
      //           },
      //           itemBuilder:
      //               (BuildContext context) => <PopupMenuEntry<MenuItem>>[
      //                 const PopupMenuItem<MenuItem>(
      //                   value: MenuItem.remove,
      //                   child: Text('Remove'),
      //                 ),
      //                 const PopupMenuItem<MenuItem>(
      //                   value: MenuItem.removeAdmin,
      //                   child: Text('Remove Admin'),
      //                 ),
      //               ],
      //         )
      //         : null,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    );
  }
}
