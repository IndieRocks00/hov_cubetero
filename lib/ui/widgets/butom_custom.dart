
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/login/login_state.dart';

class ButtomCustom extends StatefulWidget {

  final String text;
  final Future<void> Function() onPressed;
  final Color background;
  final Color textColor;
  final EdgeInsetsGeometry margin;
  final double radius;

  const ButtomCustom({
    Key? key,
    required this.text,
    required this.onPressed,
    this.background = AppColors.secondaryColor,
    this.textColor = AppColors.backgroundColor,
    this.margin = const EdgeInsets.only(left: 40,right: 40, top: 30),
    this.radius = 12,
  }) : super(key: key);

  @override
  State<ButtomCustom> createState() => _ButtomCustomState();
}

class _ButtomCustomState extends State<ButtomCustom> {

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 55,
        padding: EdgeInsets.only(top:5),
        margin: widget.margin ,
        decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 5)
              )
            ]
        ),
        child: ElevatedButton(onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
              textStyle:  TextStyle(color: widget.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Helvetica',
              ),
              alignment: Alignment.center,
              backgroundColor: widget.background,
              foregroundColor: widget.textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.radius),
              )
          ),
          child:  Text(widget.text),
        )
    );
  }
}
