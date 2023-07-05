import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {

  final String? message;

  ProgressDialog({
    this.message
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize:  MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 14),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.black),
            ),
          ),
          Text(message.toString()),
        ],
      ),
    );
  }
}
