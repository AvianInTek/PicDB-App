// lib/widgets/common/dialog_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dialog_theme.dart';

/// A collection of reusable dialog widgets for the app
class AppDialogs {
  // Show a confirmation dialog with customizable content
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    IconData? icon,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AppDialogTheme.animatedDialogBuilder(
          context,
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: AppDialogTheme.dialogDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          icon ?? (destructive ? Icons.warning_amber : Icons.help_outline),
                          color: destructive ? Colors.red : const Color(0xFF0D1F2D),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: AppDialogTheme.titleStyle.copyWith(
                              color: destructive ? Colors.red : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: AppDialogTheme.contentPadding,
                    child: Text(
                      content,
                      style: AppDialogTheme.contentStyle,
                    ),
                  ),
                  Padding(
                    padding: AppDialogTheme.actionsPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: AppDialogTheme.getCancelButtonStyle(),
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(cancelText),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: destructive
                              ? FilledButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red,
                                  minimumSize: const Size(100, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                )
                              : AppDialogTheme.getConfirmButtonStyle(Colors.blue),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(confirmText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  // Show an alert dialog with just an OK button
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    IconData? icon,
    bool isError = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AppDialogTheme.animatedDialogBuilder(
          context,
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: AppDialogTheme.dialogDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          icon ?? (isError ? Icons.error_outline : Icons.info_outline),
                          color: isError ? Colors.red : const Color(0xFF0D1F2D),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            style: AppDialogTheme.titleStyle.copyWith(
                              color: isError ? Colors.red : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: AppDialogTheme.contentPadding,
                    child: Text(
                      content,
                      style: AppDialogTheme.contentStyle,
                    ),
                  ),
                  Padding(
                    padding: AppDialogTheme.actionsPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                          style: AppDialogTheme.getConfirmButtonStyle(Colors.blue),
                          onPressed: () => Navigator.pop(context),
                          child: Text(buttonText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show a permission denied dialog with option to open settings
  static Future<bool> showPermissionDeniedDialog({
    required BuildContext context,
    required String content,
    required VoidCallback onOpenSettings,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AppDialogTheme.animatedDialogBuilder(
          context,
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: AppDialogTheme.dialogDecoration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.no_accounts,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Permission Required',
                            style: AppDialogTheme.titleStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: AppDialogTheme.contentPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content,
                          style: AppDialogTheme.contentStyle,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You need to enable permissions in your device settings to use this feature.',
                                  style: TextStyle(color: Colors.orange.shade800, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: AppDialogTheme.actionsPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: AppDialogTheme.getCancelButtonStyle(),
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: AppDialogTheme.getConfirmButtonStyle(Colors.blue),
                          onPressed: () {
                            Navigator.pop(context, true);
                            onOpenSettings();
                          },
                          child: const Text('Open Settings'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
