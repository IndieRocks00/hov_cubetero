
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';

class AppBarCustom extends ConsumerStatefulWidget implements PreferredSizeWidget {

  final String name;
  final VoidCallback? onLeadingPress;

  const AppBarCustom( {Key? key,required this.name,  this.onLeadingPress,}) : super(key: key);

  @override
  AppBarCustomState createState() => AppBarCustomState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class AppBarCustomState extends ConsumerState<AppBarCustom> {



  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text("HOV CAJERO",style: TextStyle(fontSize: 18 ,color: AppColors.textAppBarColor)),
      backgroundColor: AppColors.appBarrColor,
      elevation: 2,
      shadowColor: Colors.grey.shade400,
      bottom: PreferredSize(
        preferredSize: Size.zero,
        child: Container(
          margin: const EdgeInsets.only(left: 60),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.centerLeft,
          child: Text(widget.name,
            style: const TextStyle(fontSize: 18 ,color: AppColors.textAppBarColor),
            textAlign: TextAlign.left,),),
      ),
    );
  }
}

