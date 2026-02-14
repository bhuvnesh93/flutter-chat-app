import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier()
    : super(ChatState(usersList: [], userChatGroups: {})); // initial state

  void saveUsersList(List<UserData> users) {
    state = state.copyWith(usersList: users);
  }

  void saveUserChatGroups(GroupData groups) {
    final updatedGroups = Map<String, GroupData>.from(state.userChatGroups);
    updatedGroups[groups.groupId] = groups;
    state = state.copyWith(userChatGroups: updatedGroups);
  }

  void removeGroup(String groupId) {
    final updatedGroups = Map<String, GroupData>.from(state.userChatGroups);
    updatedGroups.remove(groupId);
    state = state.copyWith(userChatGroups: updatedGroups);
  }
}

class ChatState {
  final List<UserData> usersList;
  final Map<String, GroupData> userChatGroups;

  ChatState({required this.usersList, required this.userChatGroups});

  ChatState copyWith({
    List<UserData>? usersList,
    Map<String, GroupData>? userChatGroups,
  }) {
    return ChatState(
      usersList: usersList ?? this.usersList,
      userChatGroups: userChatGroups ?? this.userChatGroups,
    );
  }
}

// expose provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
