import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return Center(child: Text("No messages found!"));
        }
        if (chatSnapshots.hasError) {
          return Center(child: Text("Something went wrong!!"));
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMesssage = loadedMessages[index].data();
            final nextChatMesssage =
                index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;

            final currentMessageUserId = chatMesssage["userId"];
            final nextMessageUserId =
                nextChatMesssage != null ? nextChatMesssage["userId"] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMesssage["text"],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMesssage["userImage"],
                username: chatMesssage["username"],
                message: chatMesssage["text"],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
      stream:
          FirebaseFirestore.instance
              .collection("chats")
              .orderBy("createdAt", descending: true)
              .snapshots(),
    );
  }
}
