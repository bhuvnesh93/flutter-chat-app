import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/authentication/login_screen.dart';
import 'package:chat_app/screens/chats/chat_message_screen.dart';
import 'package:chat_app/screens/chats/new_chat_screen.dart';
import 'package:chat_app/screens/profile/profile_detail_screen.dart';
import 'package:chat_app/screens/chats/widgets/chats_list_item.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MenuItem { profile, logout }

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen> {
  late String _uid;
  late final AppLifecycleListener _listener;
  StreamSubscription<DatabaseEvent>? _subscription;
  StreamSubscription<DatabaseEvent>? _childSubscription;

  void _prepareGroupDataModel(value) {
    Map<String, dynamic> castedMap = Map<String, dynamic>.from(value as Map);
    GroupData groupData = GroupData.fromMap(castedMap);
    ref.read(chatProvider.notifier).saveUserChatGroups(groupData);
  }

  void _fetchUserGroups() async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref(
      "/chat/users/$_uid/group",
    );
    _subscription = userRef.onValue.listen((DatabaseEvent databaseEvent) {
      if (databaseEvent.snapshot.exists) {
        Map<String, dynamic> castedMap = Map<String, dynamic>.from(
          databaseEvent.snapshot.value as Map,
        );
        castedMap.forEach((key, value) async {
          if (value == true) {
            final ref = FirebaseDatabase.instance.ref('/chat/group/$key');
            final databaseEvent = await ref.once();
            if (databaseEvent.snapshot.exists) {
              _prepareGroupDataModel(databaseEvent.snapshot.value);
            }
          } else {
            ref.read(chatProvider.notifier).removeGroup(key);
          }
        });
      }
    });
  }

  void _fetchGroupsChildUpdated() {
    _childSubscription = FirebaseDatabase.instance
        .ref("/chat/group")
        .onChildChanged
        .listen(
          (DatabaseEvent databaseEvent) {
            _prepareGroupDataModel(databaseEvent.snapshot.value);
          },
          onError: (error) {
            log('Listen error: $error');
          },
        );
  }

  // void _fetchUsersOnce() async {
  //   DatabaseReference usersRef = FirebaseDatabase.instance.ref("/chat/users");
  //   final databaseEvent = await usersRef.once();
  //   if (databaseEvent.snapshot.exists) {
  //     // final originalMap = snapshot.snapshot.value as Map<Object?, Object?>;
  //     // Map<String, dynamic> castedMap = originalMap.cast<String, dynamic>();
  //     Map<String, dynamic> castedMap = Map<String, dynamic>.from(
  //       databaseEvent.snapshot.value as Map,
  //     );
  //     final usersList =
  //         castedMap.values
  //             .map((map) => UserData.fromMap(map.cast<String, dynamic>()))
  //             .toList()
  //             .where((element) => element.uid != _uid)
  //             .toList();
  //     ref.read(chatProvider.notifier).saveUsersList(usersList);
  //   }
  // }

  void _fetchUserChildUpdates() {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref("/chat/users");
    usersRef.onChildChanged.listen((DatabaseEvent databaseEvent) {
      Map<String, dynamic> castedMap = Map<String, dynamic>.from(
        databaseEvent.snapshot.value as Map,
      );
      UserData childChanged = UserData.fromMap(
        castedMap.cast<String, dynamic>(),
      );

      var userList = ref.read(chatProvider).usersList;
      int indexToUpdate = userList.indexWhere(
        (element) => element.uid == childChanged.uid,
      );

      if (indexToUpdate != -1) {
        userList[indexToUpdate] = childChanged;
      }
      ref.read(chatProvider.notifier).saveUsersList(userList);
    });
  }

  Future<void> requestNotificationPermission() async {
    var deviceInfo = DeviceInfoPlugin();
    String? deviceId = "";
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      print(androidDeviceInfo);
      deviceId = androidDeviceInfo.id;
      print("deviceId $deviceId");
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? fcmToken;
      if (Platform.isIOS) {
        String? apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          fcmToken = await FirebaseMessaging.instance.getToken();
        }
      } else if (Platform.isAndroid) {
        fcmToken = await messaging.getToken();
      }
      updateFCMTokenAndDeviceId(deviceId!, fcmToken ?? "", _uid);
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      //
    }
  }

  @override
  void initState() {
    super.initState();

    _uid = ref.read(userProvider).user.uid;

    requestNotificationPermission();

    // fetch all users once
    fetchAllUsers(_uid, (usersList) {
      ref.read(chatProvider.notifier).saveUsersList(usersList);
    });

    // listen on users child changed
    _fetchUserChildUpdates();

    // listen on user groups and update group information
    _fetchUserGroups();

    // listen on group updated
    _fetchGroupsChildUpdated();

    _listener = AppLifecycleListener(
      // onShow: () => print('App is shown'),
      onResume: () => updateOnlineOfflineStatus(_uid, true),
      // onHide: () => print('App is hidden'),
      // onInactive: () => print('App is inactive'),
      onPause: () => updateOnlineOfflineStatus(_uid, false),
      // onDetach: () => print('App is detached'),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    _subscription?.cancel();
    _childSubscription?.cancel();
    super.dispose();
  }

  void _logout() async {
    updateOnlineOfflineStatus(_uid, false);
    var deviceInfo = DeviceInfoPlugin();
    String? deviceId = "";
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      deviceId = iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      print(androidDeviceInfo);
      deviceId = androidDeviceInfo.id;
    }
    removeFCMTokenAndDeviceIdOnSignout(deviceId!, _uid, () {
      FirebaseAuth.instance.signOut();
      ref
          .read(userProvider.notifier)
          .saveUserData(
            UserData(
              uid: "",
              name: "",
              imageUrl: "",
              status: "",
              email: "",
              online: false,
              lastSeenOnline: 0,
            ),
          );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => LoginScreen()),
      );
    });
  }

  Widget renderItem(GroupData item) {
    return ChatsListItem(
      item: item,
      onSelectItem: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (ctx) => ChatMessageScreen(
                  groupId: item.groupId,
                  chatType:
                      item.group == true
                          ? DaialogType.groupChat
                          : DaialogType.oneOnOneChat,
                  fromRoute: "ChatsScreen",
                ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Chats"),
        backgroundColor: AppColors.whiteColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.greyColor, // Choose your color
                  width: 1.0, // Choose your thickness
                ),
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<MenuItem>(
            icon: const Icon(Icons.more_vert),
            onSelected: (MenuItem result) {
              if (result == MenuItem.profile) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => ProfileDetailScreen()),
                );
              } else if (result == MenuItem.logout) {
                _logout();
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<MenuItem>>[
                  const PopupMenuItem<MenuItem>(
                    value: MenuItem.profile,
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem<MenuItem>(
                    value: MenuItem.logout,
                    child: Text('Logout'),
                  ),
                ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => NewChatScreen()),
            ),
        tooltip: 'Add Item',
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: AppColors.whiteColor),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Consumer(
            builder: (consumerContext, ref, child) {
              List<GroupData> data =
                  ref.watch(chatProvider).userChatGroups.values.toList();
              data.sort((GroupData a, GroupData b) {
                if (a.lastMessage == null && b.lastMessage == null) {
                  return b.timestamp - a.timestamp;
                } else if (a.lastMessage == null) {
                  return (b.lastMessage?.timestamp ?? 0) - a.timestamp;
                } else if (b.lastMessage == null) {
                  return b.timestamp - (a.lastMessage?.timestamp ?? 0);
                } else {
                  return (b.lastMessage?.timestamp ?? 0) -
                      (a.lastMessage?.timestamp ?? 0);
                }
              });

              if (data.isNotEmpty) {
                return Expanded(
                  child: ListView.separated(
                    itemBuilder: (ctx, index) => renderItem(data[index]),
                    itemCount: data.length,
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
              } else {
                return Center(child: Text("No data"));
              }
            },
          ),
        ],
      ),
    );
  }
}
