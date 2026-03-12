import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constant_styles.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDetailScreen extends ConsumerWidget {
  const ProfileDetailScreen({super.key});

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    logging('image : ${pickedImage!.path}');
  }

  void _handleImageCapture() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    logging('image : ${pickedImage!.path}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.read(userProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Profile"),
        backgroundColor: AppColors.whiteColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.greyColor, width: 1.0),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  userData.imageUrl != ""
                      ? NetworkImage(userData.imageUrl)
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
            Container(
              margin: EdgeInsets.symmetric(vertical: 32.0),
              child: Row(
                children: [
                  Icon(Icons.person, size: 30.0),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name",
                            style: ConstantStyles.bold.copyWith(fontSize: 16),
                          ),
                          Text(userData.name),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.email, size: 30.0),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: ConstantStyles.bold.copyWith(fontSize: 16),
                        ),
                        Text(userData.email),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
