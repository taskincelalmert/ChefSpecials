import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';

/// Asks the user for the password of their existing email/password account so
/// a pending Google credential can be linked to it. Returns the entered
/// password, or null if the user cancels.
Future<String?> showLinkPasswordDialog(BuildContext context, String email) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  var obscure = true;

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return AlertDialog(
            title: Text(l10n.linkAccountTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(l10n.linkAccountMessage),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                  onSubmitted: (value) =>
                      Navigator.of(dialogContext).pop(value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(controller.text),
                child: Text(l10n.linkAccountButton),
              ),
            ],
          );
        },
      );
    },
  );
}
