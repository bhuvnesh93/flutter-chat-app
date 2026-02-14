import 'dart:convert';

import 'package:chat_app/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final notifier = UserNotifier();
  notifier.fetchUserData();
  return notifier;
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier()
    : super(
        UserState(
          user: UserData(
            uid: "",
            name: "",
            imageUrl: "",
            status: "",
            email: "",
            online: false,
            lastSeenOnline: 0,
          ),
        ),
      ); // initial state

  // final SharedPreferences _prefs;

  void saveUserData(UserData userData) async {
    String jsonString = jsonEncode(
      userData.toJson(),
    ); // model to json and then json string
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('userData', jsonString);
    state = state.copyWith(user: userData);
  }

  Future<void> fetchUserData() async {
    var prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString("userData");
    if (jsonString != null) {
      Map<String, dynamic> decodedJson =
          jsonDecode(jsonString) as Map<String, dynamic>;
      state = UserState(user: UserData.fromJson(decodedJson));
    }
  }
}

class UserState {
  final UserData user;

  UserState({required this.user});

  UserState copyWith({UserData? user}) {
    return UserState(user: user ?? this.user);
  }
}
