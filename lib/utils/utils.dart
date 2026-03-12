import 'dart:convert';

import 'package:chat_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void logging(text) {
  // if (kDebugMode) {
  print(text);
  // }
}

void prettyPrintJson(dynamic jsonObject) {
  // Use JsonEncoder.withIndent to specify the indentation (e.g., '  ' for two spaces)
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');

  // Convert the Dart object (Map or List) to a pretty-printed JSON string
  final prettyString = encoder.convert(jsonObject);

  // Print the string to the console
  // Use debugPrint for long strings in Flutter to avoid truncation in the console/logcat
  debugPrint(prettyString);
}

void showToast(context, title, [toastType = ToastTypes.info]) {
  var type = ToastificationType.info;
  if (toastType == ToastTypes.error) {
    type = ToastificationType.error;
  } else if (toastType == ToastTypes.success) {
    type = ToastificationType.success;
  }
  toastification.show(
    context: context,
    type: type,
    title: Text(title),
    autoCloseDuration: const Duration(seconds: 3),
    style: ToastificationStyle.minimal,
    alignment: Alignment.bottomCenter,
    direction: TextDirection.ltr,
  );
}
