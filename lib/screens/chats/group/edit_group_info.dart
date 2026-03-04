import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';

class EditGroupInfo extends StatefulWidget {
  final String groupImage;
  final String groupName;
  final String groupId;

  const EditGroupInfo({
    super.key,
    required this.groupImage,
    required this.groupName,
    required this.groupId,
  });

  @override
  State<EditGroupInfo> createState() => _EditGroupInfoState();
}

class _EditGroupInfoState extends State<EditGroupInfo> {
  late final TextEditingController _groupNameController;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.groupName);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Edit group info"),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey, // Choose your color
                  width: 1.0, // Choose your thickness
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                //
              },
              child: Text("Save"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage:
                    widget.groupImage != ""
                        ? NetworkImage(widget.groupImage)
                        : AssetImage("assets/images/default_profile.png"),
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Wrap(
                        children: [
                          ListTile(
                            leading: Icon(Icons.camera),
                            title: Text('Camera'),
                            onTap: _handleImageCapture,
                          ),
                          ListTile(
                            leading: Icon(Icons.browse_gallery),
                            title: Text('Gallery'),
                            onTap: _pickImage,
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Edit",
                  style: ConstantStyles.medium.copyWith(
                    fontSize: 16.0,
                    color: Colors.blue,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _groupNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter group name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleImageCapture() {}

  void _pickImage() {}
}
