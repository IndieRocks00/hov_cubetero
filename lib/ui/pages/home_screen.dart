
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';
import 'package:indierocks_cubetero/data/models/cortesia_cliente_model.dart';
import 'package:indierocks_cubetero/data/models/res_scan_dialog_model.dart';
import 'package:indierocks_cubetero/data/models/result_cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/ui/components/dialog_options_scan.dart';
import 'package:indierocks_cubetero/ui/components/dialog_scan_handler.dart';
import 'package:indierocks_cubetero/ui/enum/enum_alert_status.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/formater/formater.dart';
import 'package:indierocks_cubetero/ui/widgets/alert_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/app_bar_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/loading_screen.dart';
import 'package:indierocks_cubetero/ui/widgets/menu_drawer_app.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {

  UserModel? userOperativo = null;
  var isLoading = false;
  ResultCortesiaModel? resCortesia;



  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    userOperativo = ref.read(userLogued.notifier).state;
  }


  @override
  Widget build(BuildContext context) {

    final getcortesiasNotifier = ref.watch(getCortesiaNotifier);
    getcortesiasNotifier.when(
      available: (resultCortesiaModel) {
        setState(() {
          isLoading = false;
          resCortesia = resultCortesiaModel;
        });
        print('cortesia disponible AVAIBLE ${resCortesia?.toJson()}');
        print('Es nulo?  ${resCortesia == null}');
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          ref.read(getCortesiaNotifier.notifier).reset();
        });
      },
      initial: () {
        setState(() {

          isLoading = false;
        });
        //print('cortesia disponible inicial');
      },
      loading: () {
        setState(() {

          isLoading = true;
        });
        print('cortesia disponible cargando');
      },
      error: (statusCode, message) {

        setState(() {
          resCortesia = null;
          isLoading = false;

        });
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
          ref.read(getCortesiaNotifier.notifier).reset();
          AlertCustomDialog(
            context: context,
            alert_type: AlertCustomDialogType.ERROR,
            msg: message,).show();
        });
        /**/

        print('cortesia disponible error ${message}');
      },);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarCustom(name:userOperativo?.user ?? '',),
      drawer: MenuDrawerApp(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [

                ButtomCustom(text: 'Escanear Cliente',
                  background: AppColors.backgroundColor,
                  onPressed: () async {
                    DialogScanHandler(
                        process: ProcessType.READ_PULSERA,
                        parentContext: context,
                        dataCallback: (data, banco) {
                          print('Data_leido Escaner Cliente: $data');

                          ref.read(getCortesiaNotifier.notifier).getCortesiasClient(data, userOperativo!.data_encripted);
                          //ref.read(getCortesiaNotifier.notifier).reset();

                        },
                    ).showDialogOption().whenComplete(() {
                      if(Navigator.of(context).canPop()){
                        Navigator.of(context).pop();
                      }
                    },);
                    /*var dialog = DialogOptionScan(context: context, process: ProcessType.READ_PULSERA);

                    ResScanDialogModel res = await dialog.showDialogOption();
                    //print(res.toJson());
                    if(res.rcode == 0){
                      ref.read(getCortesiaNotifier.notifier).getCortesiasClient(res.message, userOperativo!.data_encripted);
                    }
                    else{
                      SnackbarCustom(
                        message: res.message,
                        backgroundColor: AppColors.alert_information,
                        textColor: AppColors.textColorInformation,
                        icon: Icons.info,
                        context: context,
                      ).showdialog();
                    }*/
                  },
                  textColor: AppColors.primaryColor,
                ),
                const SizedBox(
                  height: 10,
                ),

                resCortesia == null ?
                     const Column(
                      children: [
                        Text(
                          'Sin información por mostrar',
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          'Debes escanear una pulsera para poder ver informacion de cortesias',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ):
                    Column(
                      children: [
                        const Text('Saldo disponible:',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(DataFormater.formatCurrency( double.parse(resCortesia!.balance.toString())),
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        resCortesia!.cortesias.isEmpty ?
                        const Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'Sin cortesias disponibles',
                              style: TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ):
                            Column(
                              children: [
                                Text(
                                  'Cortesias disponibles',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: ListView.builder(
                                    itemCount: resCortesia!.cortesias.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Card(
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.only(right: 30),
                                          margin: const EdgeInsets.only( left: 20, right: 20, top: 20),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child:
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Text( resCortesia!.cortesias.elementAt(index).service,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),),
                                                  Expanded(child:
                                                  Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    child: Text( resCortesia!.cortesias.elementAt(index).cantidad.toString(),
                                                      textAlign: TextAlign.right,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),),

                                                ],
                                              ),



                                              SizedBox(height: 20,)
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),

                      ],
                    ),
                const SizedBox(
                  height: 30,
                ),
                ButtomCustom(text: 'Agregar productos',
                  background: AppColors.backgroundColor,
                  onPressed: () async {
                    List<CortesiaClienteModel> cortesias = [];
                    if(resCortesia!=null){
                      cortesias = resCortesia!.cortesias;
                    }
                    Navigator.pushReplacementNamed(context, AppPageRoutes.PRODUCTS.getPage(), arguments: {'cortesias' :cortesias });

                  },
                  textColor: AppColors.primaryColor,
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
          isLoading? const LoadingScreen() : const SizedBox(),
        ],
      ),
    );
  }
}


