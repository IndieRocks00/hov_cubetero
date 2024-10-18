
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/login/login_state.dart';

class ButtomLoading extends StatefulWidget {

  final String text;
  final Future<void> Function() onPressed;
  final LoginState loading;

  const ButtomLoading({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.loading
  }) : super(key: key);

  @override
  State<ButtomLoading> createState() => _ButtomLoadingState();
}

class _ButtomLoadingState extends State<ButtomLoading> {

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 55,
        margin: const EdgeInsets.only(left: 40,right: 40, top: 50),
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
              textStyle: const TextStyle(color: AppColors.backgroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Helvetica',
              ),
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              )
          ),
          child: widget.loading == Loading()
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.backgroundColor),
            ),
          )
              : Text(widget.text, style: TextStyle(color: AppColors.backgroundColor),),
        )
    );
  }
}
