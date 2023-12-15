import 'package:flutter/material.dart';
import 'package:path/path.dart';

class SnackbarCustom extends SnackBar {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final BuildContext context;

  SnackbarCustom({
    required this.context,
    required this.message,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
    this.icon,
  }) : super(
    content: Row(
      children: <Widget>[
        if (icon != null) ...[
          Icon(icon, color: textColor),
          const SizedBox(width: 8.0),
        ],
        Expanded(
          child: Text(
            message,
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    margin: const EdgeInsets.only(
        bottom: 20,//MediaQuery.of(context).size.height - 100,
        right: 20,
        left: 20),
    backgroundColor: backgroundColor,
    duration: Duration(seconds: 3),
  );

  void showdialog(){
    ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackbarCustom(
          message: message,
          backgroundColor: backgroundColor,
          textColor: textColor,
          icon: icon,
          context: context,
        )
    );
  }
}
