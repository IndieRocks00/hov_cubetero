import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';

class AlertTopMessage extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Duration displayDuration;

  const AlertTopMessage({
    Key? key,
    required this.message,
    required this.displayDuration,
    this.backgroundColor = AppColors.alert_information,
    this.textColor = AppColors.textColorInformation,
    this.icon,
  }) : super(key: key);

  @override
  State<AlertTopMessage> createState() => _AlertTopMessageState();
}

class _AlertTopMessageState extends State<AlertTopMessage> {

  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _hideMessageAfterDuration();
  }

  void _hideMessageAfterDuration() async {
    await Future.delayed(widget.displayDuration);
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Container(
        color: widget.backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon != null ?
              Icon(
                widget.icon,
                color: widget.textColor,
              )
                : SizedBox(),
            SizedBox(width: 8.0),
            Text(
              widget.message,
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
