import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/chats/chats_screen.dart';
import 'package:chat_app/utils/chat_handler.dart';
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
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends ConsumerState<RegisterScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  File? _pickedImageFile;

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
    if (emailController.text == "") {
      //
    } else if (passwordController.text == "") {
      //
    } else {
      try {
        final credential = await _firebase.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        log("credential $credential");

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
          displayName: nameController.text,
          photoURL: imageUrl,
        );
        String uid = uId(credential.user?.uid);

        DatabaseReference usersRef = FirebaseDatabase.instance.ref(
          "/chat/users",
        );
        UserData user = UserData(
          uid: uid,
          name: nameController.text,
          imageUrl: imageUrl,
          status: "",
          email: credential.user?.email ?? '',
          online: true,
          lastSeenOnline: 0,
        );
        await usersRef.child(user.uid).set(user.toMap());
        ref.read(userProvider.notifier).saveUserData(user);
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (ctx) => ChatsScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  _pickedImageFile != null
                      ? FileImage(_pickedImageFile!)
                      : AssetImage("assets/images/default_profile.png"),
              child: GestureDetector(onTap: _pickImage),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () => _register(ref, context),
              child: Container(
                height: 50,
                width: double.infinity,
                color: Colors.green,
                child: Center(child: Text("Register")),
              ),
            ),
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
