import 'dart:developer';
import 'dart:io';

import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/chats_screen.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/widgets/app_button.dart';
import 'package:chat_app/widgets/app_header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final _firebase = FirebaseAuth.instance;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _pickedImageFile;
  bool _isLoading = false;
  bool _isObscured = true;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    setState(() {
      _pickedImageFile = File(pickedImage!.path);
    });
  }

  void _register(WidgetRef ref, BuildContext context) async {
    if (_nameController.text == "") {
      showToast(context, "Enter Name");
    } else if (_emailController.text == "") {
      showToast(context, "Enter Email");
    } else if (_passwordController.text == "") {
      showToast(context, "Enter Password");
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        final credential = await _firebase.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // image upload
        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child('${credential.user!.uid}.jpg');
        await storageRef.putFile(_pickedImageFile!);
        // download image and get path
        final imageUrl = await storageRef.getDownloadURL();
        log("imageUrl $imageUrl");

        credential.user?.updateProfile(
          displayName: _nameController.text,
          photoURL: imageUrl,
        );
        String uid = uId(credential.user?.uid);

        DatabaseReference usersRef = FirebaseDatabase.instance.ref(
          "/chat/users",
        );
        UserData user = UserData(
          uid: uid,
          name: _nameController.text,
          imageUrl: imageUrl,
          status: "",
          email: credential.user?.email ?? '',
          online: true,
          lastSeenOnline: 0,
        );
        await usersRef.child(user.uid).set(user.toMap());
        ref.read(userProvider.notifier).saveUserData(user);
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (ctx) => ChatsScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        switch (e.code) {
          case 'email-already-in-use':
            if (context.mounted) {
              showToast(
                context,
                'That email address is already in use!',
                ToastTypes.error,
              );
            }
            break;
          case 'invalid-email':
            if (context.mounted) {
              showToast(context, 'Email address is invalid!', ToastTypes.error);
            }
            break;
          case 'weak-password':
            if (context.mounted) {
              showToast(
                context,
                'The given password is invalid',
                ToastTypes.error,
              );
            }
            break;
          default:
            showToast(context, 'Error', ToastTypes.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Register"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            1.0,
          ), // Define the height of the divider
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  _pickedImageFile != null
                      ? FileImage(_pickedImageFile!)
                      : AssetImage("assets/images/default_profile.png"),
              child: GestureDetector(onTap: _pickImage),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: _isObscured,
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            AppButton(
              text: "Register",
              onPress: () => _register(ref, context),
              isLoading: _isLoading,
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => {Navigator.pop(context)},
              child: Center(child: Text("Already have account? Login")),
            ),
          ],
        ),
      ),
    );
  }
}
