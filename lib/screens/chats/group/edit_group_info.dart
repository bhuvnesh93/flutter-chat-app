import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditGroupInfo extends ConsumerStatefulWidget {
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
  ConsumerState<EditGroupInfo> createState() => _EditGroupInfoState();
}

class _EditGroupInfoState extends ConsumerState<EditGroupInfo> {
  late final TextEditingController _groupNameController;
  late String _uid;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.groupName);

    _uid = ref.read(userProvider).user.uid;
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
        backgroundColor: AppColors.whiteColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.greyColor,
                  width: 1.0, // Choose your thickness
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(onPressed: _onSave, child: Text("Save")),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                    color: AppColors.primaryColor,
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

  void _handleImageCapture() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    // logging('image : ${pickedImage!.path}');
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    // logging('image : ${pickedImage!.path}');
  }

  void _onSave() {
    if (_groupNameController.text.trim().isNotEmpty) {
      updateGroupName(_uid, widget.groupId, _groupNameController.text, () {
        Navigator.pop(context);
      });
    }
  }
}
