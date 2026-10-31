import 'package:chat_app/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

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
