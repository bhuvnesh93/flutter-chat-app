import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/chat_provider.dart';
import 'package:chat_app/screens/chats/group/create_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  final List<UserData> _selectedMember = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Member")),
      body: Column(
        children: [
          if (_selectedMember.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection:
                    Axis.horizontal, // Set scroll direction to horizontal
                itemCount:
                    _selectedMember.length, // Number of items in the list
                itemBuilder: (BuildContext context, int index) {
                  return TextButton(
                    child: Text(_selectedMember[index].name),
                    onPressed: () {
                      setState(() {
                        _selectedMember.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          Consumer(
            builder: (context, ref, child) {
              List<UserData> usersList = ref.watch(chatProvider).usersList;
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
                        onTap: () {
                          setState(() {
                            if (_selectedMember.contains(usersList[index])) {
                              _selectedMember.remove(usersList[index]);
                            } else {
                              _selectedMember.add(usersList[index]);
                            }
                          });
                        },
                      ),
                  itemCount: usersList.length,
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (ctx) =>
                          CreateGroupScreen(selectedMember: _selectedMember),
                ),
              );
            },
            child: Text("Continue"),
          ),
        ],
      ),
    );
  }
}
