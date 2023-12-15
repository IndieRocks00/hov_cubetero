

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/api/api_provider.dart';
import 'package:indierocks_cubetero/core/providers/api/api_state.dart'as api_state;
import 'package:indierocks_cubetero/core/providers/sql/sql_provider.dart';
import 'package:indierocks_cubetero/core/providers/sql/sql_user_state.dart' as sql_user_state;
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/res_scan_dialog_model.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/ui/components/dialog_options_scan.dart';
import 'package:indierocks_cubetero/ui/enum/enum_alert_status.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/alert_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/app_bar_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/loading_screen.dart';
import 'package:indierocks_cubetero/ui/widgets/menu_drawer_app.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';

class ConsultaBalanceScreen extends ConsumerStatefulWidget {
  const ConsultaBalanceScreen({Key? key}) : super(key: key);

  @override
  ConsultaBalanceScreenState createState() => ConsultaBalanceScreenState();
}

class ConsultaBalanceScreenState extends ConsumerState<ConsultaBalanceScreen> {

  var userOperativo = UserModel(user: 'Cargando...', password: '', balance: '', nameClient: '',data_encripted: '');

  var isLoading = false;
  double _balance = 0.0;
  late Future<Widget> _initialization;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialization = initApp(context, ref);
  }

  Future<Widget> initApp(BuildContext context, WidgetRef ref) async {
    Completer<Widget> completer = Completer<Widget>();
    Future.microtask(() async {
      try {
        await ref.read(sqlUserNotifier.notifier).getUser();
        final userState = ref.watch(sqlUserNotifier);

        if (userState is sql_user_state.UserAvailable) {
          userOperativo = userState.userModel;

          print('user devuleto: ${userState.userModel.user}');
          ref.read(sqlUserNotifier.notifier).reset();
        } else if (userState is sql_user_state.Error) {
          print('user Error: ${userState}');
          ref.read(sqlUserNotifier.notifier).reset();
          Navigator.pushReplacementNamed(context, AppPageRoutes.LOGIN.getPage());
        }
      } catch (error) {
        print('Error en initApp: $error');
      }
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {

    /*WidgetsBinding.instance?.addPostFrameCallback((timeStamp)  {
      final  userState = ref.watch(sqlUserNotifier);
      Future.microtask(() async {
        ref.read(sqlUserNotifier.notifier).getUser();
        final userNotifier =   ref.read(sqlUserNotifier);
        //print('Inicio de Home ${userNotifier}');
        if(userState is sql_user_state.UserAvailable){
          setState(() {

            userOperativo = userState.userModel;
          });
          ref.read(sqlUserNotifier.notifier).reset();
        }
        else if(userState is sql_user_state.Error){
          //print('Splash Usuario Error ${userNotifier}');
          ref.read(sqlUserNotifier.notifier).reset();
          Navigator.pushReplacementNamed(context, AppPageRoutes.LOGIN.getPage());
        }
      },);

    });*/

    final  apiState = ref.watch(apiNotiier);

    if (apiState is api_state.ApiAvailable) {
      isLoading = false;
      _balance = double.parse(apiState.apiState.message);
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        ref.read(apiNotiier.notifier).reset();
        //Navigator.pushReplacementNamed(context, AppPageRoutes.PAYMENT_RESULT.getPage(), arguments: arg_send);
      });

    } else if (apiState is api_state.Error) {

      //var logins = apiState;
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {

        isLoading = false;
        var api_error = apiState;
        _balance = 0.0;
        AlertCustomDialog(context: context,alert_type: AlertCustomDialogType.INFO,msg: api_error.message,).show();
        ref.read(apiNotiier.notifier).reset();
      });
    } else if(apiState is api_state.Loading){
      isLoading = true;
    }
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        return Scaffold(
        appBar: AppBarCustom(name: userOperativo.user),
        drawer: const MenuDrawerApp(),
        backgroundColor: AppColors.backgroundColor,
        body:Stack(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(top: 10, left: 20, bottom: 10),
                    color: AppColors.primaryColor,
                    child: Row(
                      children: [
                        Expanded(flex: 2,child:
                        Center(
                          child: Image.asset("assets/images/foro_ir_white.png",
                            height: 80,
                          ),
                        ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  const Text('Saldo disponible:',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20,),
                  Text(DataFormater.formatCurrency(_balance),
                    style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            isLoading? const LoadingScreen() : const SizedBox(),
          ],
        ),
        floatingActionButton: Visibility(
            visible: !isLoading,
            child: FloatingActionButton(
              onPressed: () async {

                var dialog = DialogOptionScan(context: context, process: ProcessType.READ_PULSERA);

                ResScanDialogModel res = await dialog.showDialogOption();
                print(res.toJson());
                if(res.rcode == 0){

                  ref.read(apiNotiier.notifier).detailBalance(res.message, userOperativo.data_encripted);
                }
                else{
                  SnackbarCustom(
                    message: res.message,
                    backgroundColor: AppColors.alert_information,
                    textColor: AppColors.textColorInformation,
                    icon: Icons.info,
                    context: context,
                  ).showdialog();
                }
              }, // Icono del botón flotante
              backgroundColor: AppColors.primaryColor,
              child: Image.asset("assets/images/scanqr.png",
                height: 25,
              ),
            )
        ),
      );
      },
    );
  }
}
