import 'package:chat_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtherUserProfileScreen extends ConsumerWidget {
  const OtherUserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider).user;

    return Scaffold(
      appBar: AppBar(title: Text("Other Profile")),
      body: Column(children: [Text(userData.name), Text(userData.email)]),
    );
  }
}
