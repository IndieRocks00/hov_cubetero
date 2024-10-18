
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/images/AppImages.dart';
import 'package:indierocks_cubetero/core/providers/api/api_provider.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/ui/widgets/app_bar_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';
import 'package:indierocks_cubetero/ui/widgets/menu_drawer_app.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';
import 'package:nfc_manager/nfc_manager.dart';


class TokenPulserasScreen extends ConsumerStatefulWidget {
  const TokenPulserasScreen({Key? key}) : super(key: key);

  @override
  _TokenPulserasScreenState createState() => _TokenPulserasScreenState();
}

class _TokenPulserasScreenState extends ConsumerState<TokenPulserasScreen> {

  UserModel? userOperativo = null;
  Ndef? ndef;
  bool ban = false;
  int status = 0;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    userOperativo = ref.read(userLogued.notifier).state;
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
      //ref.read(getOptionsCortesiaNotifier.notifier).getOptionsCortesia(userOperativo!.data_encripted);
      //ref.read(apiNotiier.notifier).getTokenPulsera("code_user_encripted");

      initLectura();
    });


  }

  initLectura(){
    status = 0;
    setState(() {

    });
    ref.read(apiNotiier.notifier).reset();
    NfcManager.instance.startSession(
        onDiscovered: _handleDiscovered
    );
  }

  Future<void> _handleDiscovered(NfcTag tag) async {
  print('status: $status');
    if(status == 1){
      ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackbarCustom(
            message: 'El token ya fue grabado, obten uno nuevo',
            backgroundColor: AppColors.alert_information,
            textColor: AppColors.textColorInformation,
            icon: Icons.warning,
            context: context,
          )
      );
      return;
    }
    ban = false;
    //ref.read(apiNotiier.notifier).reset();
    setState(() {

    });
    print('Inicio de lectura: $ban');
    //pulsera_lectura = true;
    //await Future.delayed(Duration(seconds: 3));
    ndef = Ndef.from(tag);
    if (ndef != null) {
      print('Se detecto pulsera');
      if(!ndef!.isWritable){
        ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackbarCustom(
              message: 'La pulsera no permite escritura.',
              backgroundColor: AppColors.alert_error,
              textColor: AppColors.textColorError,
              icon: Icons.error,
              context: context,
            )
        );
        return;
      }
      print('Se detecto pulsera');
      ref.read(apiNotiier.notifier).getTokenPulsera(userOperativo!.data_encripted);
      //NfcManager.instance.stopSession();

    }
    else{
      ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackbarCustom(
            message: 'No se pudo obtener información de la pulsera',
            backgroundColor: AppColors.alert_error,
            textColor: AppColors.textColorError,
            icon: Icons.error,
            context: context,
          )
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    final gettoken = ref.watch(apiNotiier);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBarCustom(name:userOperativo?.user ?? '',),
      drawer: const MenuDrawerApp(),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 100,
                padding: const EdgeInsets.only(top: 5, left: 20,),
                child: Row(
                  children: [
                    Expanded(flex: 1, child:
                    Center(
                      child: AppImages.getLogoBlack(MediaQuery.of(context).size.width - 100, 150),
                    ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15,),
              Text('Configurar pulsera',style:const TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 20,),
              gettoken.when(
                  available: (apiState) {
                    print('OK');
                    if(apiState.rcode == 0){

                      NfcManager.instance.startSession(
                        onDiscovered: (tag) async{

                          print('status: $status');
                          if(status == 1){
                            NfcManager.instance.stopSession();
                            ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackbarCustom(
                                  message: 'El token ya fue grabado, obten uno nuevo',
                                  backgroundColor: AppColors.alert_information,
                                  textColor: AppColors.textColorInformation,
                                  icon: Icons.warning,
                                  context: context,
                                )
                            );
                            return;
                          }
                          print('Se escribira en pulsera');
                          try{
                            var ndf = Ndef.from(tag);
                            NdefRecord record = NdefRecord.createText(apiState.message);
                            NdefMessage msg = NdefMessage([record]);
                            await ndf!.write(msg);
                            ban = true;
                            status = 1;
                            setState(() {

                            });
                            NfcManager.instance.stopSession();
                            //res(true);
                          }catch(e){
                            print('No se escribio');
                            print(e);
                            //NfcManager.instance.stopSession();
                            ban = false;
                            status = 2;
                            setState(() {

                            });
                            NfcManager.instance.stopSession();
                            //res(false);
                            //return false;
                          }
                        },
                      );
                      //NfcManager.instance.stopSession();
                      print('Resultado de escribir: $ban');
                      if(status == 0){
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: AppColors.alert_information,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.alert_information,
                                    blurRadius: 10,
                                    offset: Offset(4, 8), // Shadow position
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.near_me,
                                  color: AppColors.textColorInformation,
                                  size: 40
                              ),
                            ),

                            SizedBox(height: 15,),
                            Text('Token Obtenido.',style:const TextStyle(fontSize: 30, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            Text('Vuelve a escanear la pulsera para grabar información.',style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ],
                        );
                      }
                      else if(status == 1){
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: AppColors.alert_ok,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.alert_ok,
                                    blurRadius: 10,
                                    offset: Offset(4, 8), // Shadow position
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.done,
                                  color: AppColors.textColorOk,
                                  size: 40
                              ),
                            ),

                            SizedBox(height: 15,),
                            Text('Pulsera lista.',style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ],
                        );
                      }
                      else{
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: const BoxDecoration(
                                color: AppColors.alert_information,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.alert_information,
                                    blurRadius: 10,
                                    offset: Offset(4, 8), // Shadow position
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.error_outline,
                                  color: AppColors.textColorInformation,
                                  size: 40
                              ),
                            ),
                            SizedBox(height: 15,),
                            Text('No se pudo escribir en la pulsera, intenta de nuevo.',style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ],
                        );
                      }
                    }
                    else{

                      print(apiState.message);
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                              color: AppColors.alert_information,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.alert_information,
                                  blurRadius: 10,
                                  offset: Offset(4, 8), // Shadow position
                                ),
                              ],
                            ),
                            child: const Icon(Icons.info,
                                color: AppColors.textColorInformation,
                                size: 40
                            ),
                          ),
                          SizedBox(height: 15,),
                          Text('No se pudo obtener el token. Intenta de nuevo mas tarde',style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        ],
                      );
                    }
                  },
                  initial: () {
                    print('Inicial');
                    return Column(

                      children: [

                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: AppColors.alert_information,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.alert_information,
                                blurRadius: 10,
                                offset: Offset(4, 8), // Shadow position
                              ),
                            ],
                          ),
                          child: const Icon(Icons.nfc_outlined,
                              color: AppColors.backgroundColor,
                              size: 40
                          ),
                        ),

                        SizedBox(height: 30,),
                        Text('Acerca la pulsera para configurarla',style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ],
                    );
                  },
                  loading: () {
                    return Column(

                      children: [

                        CircularProgressIndicator(color: AppColors.primaryColor,),

                        SizedBox(height: 30,),
                        Text('Obteniendo información. No muevas la pulsera',style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ],
                    );
                  },
                  error: (statuscode, message) {
                    print(statuscode);
                    print(message);
                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            color: AppColors.alert_error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.alert_error,
                                blurRadius: 10,
                                offset: Offset(4, 8), // Shadow position
                              ),
                            ],
                          ),
                          child: const Icon(Icons.error,
                              color: AppColors.textColorError,
                              size: 40
                          ),
                        ),
                        SizedBox(height: 20,),
                        Text(message,style:const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ],
                    );
                  },),

              SizedBox(height: 20,),
              ButtomCustom(text: "Nueva pulsera",
                margin: EdgeInsets.all(0),
                radius: 0,
                onPressed: () async {
                  initLectura();
                },
              )

            ],
          ),
        ),
      ),
    );

  }
}
