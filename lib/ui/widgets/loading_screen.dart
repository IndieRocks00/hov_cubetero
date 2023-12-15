
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLoadingScreen,
      child: const Column(
        children: [
          Spacer(),
          Center(
            child: CircularProgressIndicator( color: AppColors.textColorLoadingScreen),
          ),
          SizedBox(
            height: 40,
          ),
          Text('Cargando..',
            style: TextStyle(fontSize: 20, color: AppColors.textColorLoadingScreen, ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
