import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/authentication/register_screeen.dart';
import 'package:chat_app/screens/chats/chats_screen.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _firebase = FirebaseAuth.instance;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _login() async {
    if (emailController.text == "") {
      //
    } else if (passwordController.text == "") {
      //
    } else {
      try {
        final credential = await _firebase.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        String uid = uId(credential.user?.uid);

        DatabaseReference usersRef = FirebaseDatabase.instance.ref(
          "/chat/users",
        );
        final snapshot = await usersRef.child(uid).get();
        if (snapshot.exists) {
          UserData user = UserData(
            uid: uid,
            name: credential.user?.displayName ?? '',
            imageUrl: "",
            status: "",
            email: credential.user?.email ?? '',
            online: true,
            lastSeenOnline: 0,
          );
          // await usersRef.child(user.uid).update(user.toMap()); // update only online status
          ref.read(userProvider.notifier).saveUserData(user);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (ctx) => ChatsScreen()),
            );
          }
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
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: 'Password'),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: _login,
                child: Container(
                  height: 50,
                  width: double.infinity,
                  color: Colors.green,
                  child: Center(child: Text("Login")),
                ),
              ),
              TextButton(
                onPressed:
                    () => {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (ctx) => RegisterScreen()),
                      ),
                    },
                child: Center(child: Text("Don't have account? Register")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
