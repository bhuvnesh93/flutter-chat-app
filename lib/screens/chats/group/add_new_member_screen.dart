import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/models/group_detail_user_data.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewMemberScreen extends ConsumerStatefulWidget {
  const AddNewMemberScreen({
    super.key,
    required this.groupId,
    required this.addedMembers,
  });

  final List<GroupDetailUserData> addedMembers;
  final String groupId;

  @override
  ConsumerState<AddNewMemberScreen> createState() => _AddNewMemberScreenState();
}

class _AddNewMemberScreenState extends ConsumerState<AddNewMemberScreen> {
  final List<UserData> _selectedMember = [];

  @override
  Widget build(BuildContext context) {
    final userData = ref.read(userProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Add Member"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.greyColor, width: 1.0),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_selectedMember.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      scrollDirection:
                          Axis.horizontal, // Set scroll direction to horizontal
                      itemCount:
                          _selectedMember.length, // Number of items in the list
                      itemBuilder:
                          (ctx, index) => InkWell(
                            onTap: () {
                              setState(() {
                                _selectedMember.removeAt(index);
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 23,
                                        backgroundImage: AssetImage(
                                          "assets/images/default_profile.png",
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.greyColor,
                                            border: Border.all(
                                              color: AppColors.whiteColor,
                                              width: 2,
                                            ), // White border for visibility
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 12.0,
                                            color: AppColors.whiteColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.0),
                                  Text(
                                    _selectedMember[index].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ),
                  Divider(
                    height: 1, // Height of the divider
                    color: AppColors.greyColor,
                    thickness: 1, // Thickness of the divider line
                    indent: 16, // Left padding
                    endIndent: 16, // Right padding
                  ),
                ],
              ),
            Consumer(
              builder: (context, ref, child) {
                final usersList = ref.watch(chatProvider).usersList;
                return Expanded(
                  child: ListView.separated(
                    itemBuilder:
                        (ctx, index) => ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundImage: AssetImage(
                                  "assets/images/default_profile.png",
                                ),
                              ),
                              if (_selectedMember.contains(usersList[index]))
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.greyColor,
                                      border: Border.all(
                                        color: AppColors.whiteColor,
                                        width: 2,
                                      ), // White border for visibility
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 12.0,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            usersList[index].name,
                            style: ConstantStyles.medium.copyWith(fontSize: 16),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          onTap: () {
                            widget.addedMembers.any(
                                  (element) =>
                                      element.uid == (usersList[index].uid),
                                )
                                ? null
                                : setState(() {
                                  if (_selectedMember.contains(
                                    usersList[index],
                                  )) {
                                    _selectedMember.remove(usersList[index]);
                                  } else {
                                    _selectedMember.add(usersList[index]);
                                  }
                                });
                          },
                          trailing:
                              widget.addedMembers.any(
                                    (element) =>
                                        element.uid == (usersList[index].uid),
                                  )
                                  ? Text("Already added")
                                  : null,
                        ),
                    itemCount: usersList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1,
                        color: AppColors.greyColor,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _selectedMember.isNotEmpty
                        ? () {
                          addMemberToGroup(
                            widget.groupId,
                            userData.uid,
                            _selectedMember,
                            () {
                              Navigator.pop(context);
                            },
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  disabledBackgroundColor: AppColors.greyColor,
                  disabledForegroundColor: AppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: ConstantStyles.medium.copyWith(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
