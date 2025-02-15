import 'package:flutter/material.dart';

void showLimitExceededDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        actionsPadding: EdgeInsets.zero,
        title: const Text('Limit Exceeded'),
        content: const Text(
            'You have reached your daily limit of 20 consultations. Please try again tomorrow.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
