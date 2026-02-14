import 'package:chat_app/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.read(userProvider).user;

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Column(children: [Text(userData.name), Text(userData.email)]),
    );
  }
}
