import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/authentication/login_screen.dart';
import 'package:chat_app/screens/chats/chats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userProvider).user;

    if (userData.uid != "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ChatsScreen()),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: Center(child: Text("Loading...")),
    );
  }
}
