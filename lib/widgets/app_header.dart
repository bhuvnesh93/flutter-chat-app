import 'package:chat_app/constants/constant_styles.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: ConstantStyles.semiBold.copyWith(fontSize: 18));
  }
}
