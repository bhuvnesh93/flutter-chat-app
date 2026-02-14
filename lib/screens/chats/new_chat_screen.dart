import 'dart:developer';

import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/screens/chats/group/add_member_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewChatScreen extends ConsumerWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("New Chat")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => AddMemberScreen()),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "New Group",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final usersList = ref.watch(chatProvider).usersList;
              return Expanded(
                child: ListView.builder(
                  itemBuilder:
                      (ctx, index) => ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage(
                            "assets/images/default_profile.png",
                          ),
                        ),
                        title: Text(usersList[index].name),
                      ),
                  itemCount: usersList.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
