
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';

class TextfieldComponent extends StatefulWidget {
  final TextEditingController controller;
  final String hint_label;
  final TextInputType textInputType ;
  late bool obscureText;
  final IconData? icon;


  bool _isObscure = true;

  TextfieldComponent({
    Key? key,
    required this.controller,
    required this.hint_label,
    this.textInputType = TextInputType.text,
    this.obscureText = false,
    this.icon,
  }) : super(key: key);

  @override
  State<TextfieldComponent> createState() => _TextfieldComponentState();
}

class _TextfieldComponentState extends State<TextfieldComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 40,right: 40, top: 25),
      decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                offset: Offset(0, 5)
            )
          ]
      ),
      child: TextField(
        controller: widget.controller,
        maxLines: 1,
        obscureText: widget.obscureText?widget._isObscure:false,
        keyboardType: widget.textInputType,
        style: TextStyle(color: AppColors.backgroundColor,),
        decoration: InputDecoration(
            hintText: widget.hint_label,
            hintStyle: TextStyle(color: AppColors.backgroundColor,),
            filled: true,
            fillColor: AppColors.textfield_background,
            prefixIcon: widget.icon != null ? Icon(widget.icon, color: AppColors.backgroundColor,) : SizedBox(),
            suffixIcon: widget.obscureText ? IconButton(
              icon:  Icon(widget.obscureText ? Icons.visibility : Icons.visibility_off, color: AppColors.backgroundColor,),
              onPressed: () {
                setState(() {
                  var pass = widget._isObscure;
                  widget._isObscure  = !pass ;
                });
              },
            ) : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                )
            )
        ),
      ),
    );
  }
}
