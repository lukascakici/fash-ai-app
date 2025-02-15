import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
 loadingInAppDialog(BuildContext context) {
  showDialog(
    barrierColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
            ),
            elevation: 0,
            contentPadding: const EdgeInsets.all(8),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            shadowColor: Theme.of(dialogContext).shadowColor,
            surfaceTintColor:
            Theme.of(dialogContext).cardColor.withOpacity(0),
            backgroundColor: Theme.of(dialogContext).cardColor.withOpacity(0),
            clipBehavior: Clip.hardEdge,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Connecting to...",
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.labelMedium,
                ),
                Text(
                  "${Platform.isIOS ? "App Store" : "Google Play Store"}....",
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
