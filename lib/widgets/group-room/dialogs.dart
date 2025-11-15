// lib/widgets/dialogs.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../common/dialog_theme.dart';

class CreateGroupResult {
  final String? name;
  final String password;
  CreateGroupResult({this.name, required this.password});
}

class JoinGroupResult {
  final String code;
  final String password;
  JoinGroupResult({required this.code, required this.password});
}

Future<CreateGroupResult?> showCreateGroupDialog(BuildContext context) async {
  final nameCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  return showDialog<CreateGroupResult>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (BuildContext context) {
      return AppDialogTheme.animatedDialogBuilder(
        context,
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: AppDialogTheme.dialogDecoration,
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 8, top: 16, bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.group_add, color: const Color(0xFF0D1F2D), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Create Group', style: AppDialogTheme.titleStyle),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 24),
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                backgroundColor: Colors.grey[100],
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(32, 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Content
                      Padding(
                        padding: AppDialogTheme.contentPadding,
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: nameCtrl,
                                decoration: AppDialogTheme.getInputDecoration(
                                  'Group name',
                                  prefixIcon: Icons.label
                                ),
                                textCapitalization: TextCapitalization.words,
                              ).animate()
                                  .slideX(begin: -0.2, end: 0, duration: const Duration(milliseconds: 300))
                                  .fadeIn(delay: const Duration(milliseconds: 200)),

                              const SizedBox(height: 16),

                              // Password Field
                              TextFormField(
                                controller: passCtrl,
                                obscureText: obscurePassword,
                                decoration: AppDialogTheme.getInputDecoration(
                                  'Password',
                                  prefixIcon: Icons.lock
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                              ).animate()
                                  .slideX(begin: -0.2, end: 0, duration: const Duration(milliseconds: 300))
                                  .fadeIn(delay: const Duration(milliseconds: 400)),

                              const SizedBox(height: 24),

                              // Create Button (centered)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: AppDialogTheme.getConfirmButtonStyle(Colors.blue),
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      Navigator.pop(
                                        context,
                                        CreateGroupResult(
                                          name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
                                          password: passCtrl.text,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Create Group'),
                                ).animate()
                                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
                                    .fadeIn(delay: const Duration(milliseconds: 600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Future<JoinGroupResult?> showJoinGroupDialog(BuildContext context) async {
  final List<TextEditingController> codeControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> codeFocusNodes = List.generate(6, (index) => FocusNode());
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

  return showDialog<JoinGroupResult>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (BuildContext context) {
      return AppDialogTheme.animatedDialogBuilder(
        context,
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: AppDialogTheme.dialogDecoration,
            child: StatefulBuilder(
              builder: (context, setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with close button
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 8, top: 16, bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.group, color: const Color(0xFF0D1F2D), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Join Group', style: AppDialogTheme.titleStyle),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, size: 24),
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.grey[600],
                                backgroundColor: Colors.grey[100],
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(32, 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),

                      // Content
                      Padding(
                        padding: AppDialogTheme.contentPadding,
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Group Code Label
                              Text(
                                'Group Code',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // 6-Character OTP Style Input with underlines
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (index) {
                                    return SizedBox(
                                      width: 30,
                                      child: TextFormField(
                                        controller: codeControllers[index],
                                        focusNode: codeFocusNodes[index],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(1),
                                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                        ],
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey, width: 1),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey, width: 1),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.blue, width: 1),
                                          ),
                                          contentPadding: EdgeInsets.only(bottom: 8),
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            if (index < 5) {
                                              codeFocusNodes[index + 1].requestFocus();
                                            } else {
                                              codeFocusNodes[index].unfocus();
                                            }
                                          } else if (value.isEmpty && index > 0) {
                                            codeFocusNodes[index - 1].requestFocus();
                                          }
                                        },
                                        validator: (v) => (v == null || v.isEmpty) ? '' : null,
                                      ),
                                    ).animate()
                                        .scale(
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1.0, 1.0),
                                          delay: Duration(milliseconds: 200 + (index * 100)),
                                        )
                                        .fadeIn(delay: Duration(milliseconds: 200 + (index * 100)));
                                  }),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Password Field
                              TextFormField(
                                controller: passCtrl,
                                obscureText: obscurePassword,
                                decoration: AppDialogTheme.getInputDecoration(
                                  'Password',
                                  prefixIcon: Icons.lock_rounded,
                                  accentColor: Colors.blue,
                                ).copyWith(
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.all(4),
                                    child: IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                              ).animate()
                                  .slideX(begin: -0.2, end: 0, duration: const Duration(milliseconds: 300))
                                  .fadeIn(delay: const Duration(milliseconds: 800)),

                              const SizedBox(height: 24),

                              // Join Button (centered)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  style: AppDialogTheme.getConfirmButtonStyle(Colors.blue),
                                  onPressed: () {
                                    String code = codeControllers.map((c) => c.text).join();
                                    if (code.length == 6 && passCtrl.text.isNotEmpty) {
                                      Navigator.pop(
                                        context,
                                        JoinGroupResult(
                                          code: code.toUpperCase(),
                                          password: passCtrl.text,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please enter a complete 6-character code and password'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Join Group'),
                                ).animate()
                                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
                                    .fadeIn(delay: const Duration(milliseconds: 1000)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
