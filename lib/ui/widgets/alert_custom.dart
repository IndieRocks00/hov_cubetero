
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/ui/enum/enum_alert_status.dart';

class AlertCustomDialog {

  final BuildContext context;
  final AlertCustomDialogType alert_type;
  final String msg;
  const AlertCustomDialog({Key? key,required this.context, required this.alert_type, required this.msg});

  void show(){
    IconData _icon = Icons.error;
    Color color_cirlce = AppColors.alert_ok;

    switch (alert_type) {
      case AlertCustomDialogType.INFO:
        _icon = Icons.info;
        color_cirlce = AppColors.alert_information;
        break;
      case AlertCustomDialogType.ERROR:
        _icon = Icons.warning;
        color_cirlce = AppColors.alert_error;
        break;
      case AlertCustomDialogType.CORRECT:
        _icon = Icons.done;
        color_cirlce = AppColors.alert_ok;
        break;
      default:
        _icon = Icons.error;
        color_cirlce = AppColors.alert_ok;
        break;
    }

    showDialog(context: context, builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: AppColors.backgroundColor,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.width * 0.6,
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration:  BoxDecoration(
                        color: color_cirlce,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.alert_information,
                            blurRadius: 10,
                            offset: Offset(4, 8), // Shadow position
                          ),
                        ],
                      ),
                      child: Icon(_icon,
                          color: AppColors.textColorError,
                          size: 40
                      ),
                    ),
                    const Spacer(),
                    Text(msg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    const Spacer(),
                    GestureDetector(
                      child: const Text('Cerrar',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        );
      },
    );
  }

}

