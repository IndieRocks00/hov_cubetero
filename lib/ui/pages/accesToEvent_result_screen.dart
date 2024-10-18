


import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/data/models/categoria_producto_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/ui/components/prodcut_card_result.dart';
import 'package:indierocks_cubetero/ui/components/producto_card.dart';
import 'package:indierocks_cubetero/ui/enum/enum_banks.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';

class AccesToEventScreen extends StatefulWidget {

  final ResApiModel resTransaction;

  const AccesToEventScreen({Key? key,
    required this.resTransaction,
  }) : super(key: key);

  @override
  State<AccesToEventScreen> createState() => _AccesToEventScreenState();
}

class _AccesToEventScreenState extends State<AccesToEventScreen> {


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            Positioned.fill(child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40,),
                  widget.resTransaction.rcode == 0 ? Container(
                    padding: EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.alert_ok,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alert_information,
                          blurRadius: 10,
                          offset: Offset(6, 5), // Shadow position
                        ),
                      ],
                    ),
                    child: const Icon(Icons.done,
                        color: AppColors.textColorOk,
                        size: 50
                    ),
                  ):
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.alert_error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.alert_information,
                          blurRadius: 10,
                          offset: Offset(4, 8), // Shadow position
                        ),
                      ],
                    ),
                    child: const Icon(Icons.error,
                        color: AppColors.textColorError,
                        size: 50
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.only(left: 25,right: 25),
                    child: Text(widget.resTransaction.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textColor,
                        fontSize: 30,

                      ),
                    ),
                  ),




                  const SizedBox(height: 100,),
                ],
              ),
            )),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: ButtomCustom(text: 'Continuar',
                onPressed: () async {
                  Navigator.pushReplacementNamed(context, AppPageRoutes.VALIDAR_BOLETO.getPage());
                },
              ),)
          ],
        )
    );
  }
}
