
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/ui/enum/enum_banks.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';

class PaymentResultScreen extends StatefulWidget {

  final ResApiModel resTransaction;
  final double monto;
  final BankType banco;

  const PaymentResultScreen({
    Key? key,
    required this.resTransaction,
    required this.monto,
    required this.banco
  }) : super(key: key);

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          children: [
            Spacer(),

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
            Text(widget.banco.name,
              style: TextStyle(fontSize: 20),
            ),
            Text(DataFormater.formatCurrency(widget.monto),
              style: TextStyle(fontSize: 60),
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
            const Spacer(),
            ButtomCustom(text: 'Continuar',
              onPressed: () async {
                Navigator.pushReplacementNamed(context, AppPageRoutes.HOME.getPage());
              },
            ),
            Spacer(),
          ],
        ),
      )
    );
  }
}
