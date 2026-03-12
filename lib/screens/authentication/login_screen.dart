import 'package:chat_app/constants/app_colors.dart';
import 'package:chat_app/constants/constants.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/provider/user_provider.dart';
import 'package:chat_app/screens/authentication/register_screen.dart';
import 'package:chat_app/screens/chats/chats_screen.dart';
import 'package:chat_app/utils/chat_handler.dart';
import 'package:chat_app/utils/utils.dart';
import 'package:chat_app/widgets/app_button.dart';
import 'package:chat_app/widgets/app_header.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscured = true;

  void _login(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      showToast(context, "Enter Email");
    } else if (_passwordController.text.isEmpty) {
      showToast(context, "Enter Password");
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        final credential = await _firebase.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        String uid = uId(credential.user?.uid);
        updateOnlineOfflineStatus(uid, true);
        DatabaseReference usersRef = FirebaseDatabase.instance.ref(
          "/chat/users/$uid",
        );
        final snapshot = await usersRef.once();
        final originalMap = snapshot.snapshot.value as Map<Object?, Object?>;
        Map<String, dynamic> castedMap = originalMap.cast<String, dynamic>();
        try {
          UserData userData = UserData.fromMap(castedMap);
          ref.read(userProvider.notifier).saveUserData(userData);
        } on Exception catch (e) {
          logging("e $e");
        }

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
        if (e.code == 'invalid-email') {
          if (context.mounted) {
            showToast(context, "Invalid Email", ToastTypes.error);
          }
        } else if (e.code == 'user-not-found') {
          if (context.mounted) {
            showToast(context, "Account does not exist", ToastTypes.error);
          }
        } else if (e.code == 'wrong-password') {
          if (context.mounted) {
            showToast(context, "Wrong password.", ToastTypes.error);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppHeader(text: "Login"),
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
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Email",
              ),
            ),
            SizedBox(height: 30),
            TextField(
              obscureText: _isObscured,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30),
            AppButton(
              text: "Login",
              onPress: () => _login(context),
              isLoading: _isLoading,
            ),
            SizedBox(height: 30),
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
    );
  }
}
