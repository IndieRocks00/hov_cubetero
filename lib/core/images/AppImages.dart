

import 'package:flutter/cupertino.dart';

class AppImages{
  static Widget getLogoBlack(double width, double heigth){
    return  Image.asset(
      "assets/images/hov_logo_black.png",
      width: width,
      height: heigth,
    );
  }
  static Widget getLogowhite(double width, double heigth){
    return  Image.asset(
      "assets/images/hov_logo_white.png",
      width: width,
      height: heigth,
    );
  }
}