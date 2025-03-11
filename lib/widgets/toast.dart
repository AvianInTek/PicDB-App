import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:toastification/toastification.dart';

void toaster(
    BuildContext context, {
      required String message,
      required ToastificationType type, // Use ToastificationType
      required String iconPath, // Path to your icon asset
      Color? backgroundColor, // Optional background color
    }) {
  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.flat, // You can choose a different style
    title: Text(message), // Use the message as the title
    autoCloseDuration: const Duration(seconds: 5),
    alignment: Alignment.bottomCenter, // Show at the bottom
    showProgressBar: true, // Show the progress bar
    dragToClose: true, // Allow dragging to close
    closeOnClick: true,
    pauseOnHover: true,
    icon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
    ), // Use Image.asset for asset icons
    // Customize appearance if needed
    foregroundColor: Colors.white,
    backgroundColor: backgroundColor ??
        (type == ToastificationType.success
            ? Colors.green
            : type == ToastificationType.error
            ? Colors.red
            : Colors.blue), // Default colors based on type
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    borderRadius: BorderRadius.circular(12),
    boxShadow: lowModeShadow,
  );
}