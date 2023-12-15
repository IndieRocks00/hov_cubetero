
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/api/api_provider.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/widgets/butom_custom.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class ScanController extends ConsumerStatefulWidget {
  final ProcessType process;
  final List<dynamic> json_cortesia;
  final Function(String data)? onDataChange;
  final Function()? onCancel;
  const ScanController({Key? key,
    required this.process,
    this.json_cortesia = const [],
    this.onDataChange,
    this.onCancel
  }) : super(key: key);

  @override
  _ScanControllerState createState() => _ScanControllerState();
}

class _ScanControllerState extends ConsumerState<ScanController> {

  UserModel? userOperativo = null;
  int cant_pulsera = 0;
  bool pulsera_lectura = true;
  String text_title = '';

  var apiRes;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {

      WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
        ref.read(apiNotiier.notifier).reset();
      });
      text_title = 'ESPERANDO';
      cant_pulsera = 0;
      userOperativo = ref.read(userLogued.notifier).state;
      getcode();
    });


  }

  Future<String?> getScan() async {
    Completer<String> completer = Completer<String>();
    completer.complete(await scanner.scan() ?? '');
    return completer.future;
  }

  Future<void> getcode() async {
    String? text_scan = '';
    try {
      //cameraScanResult = await FlutterBarcodeScanner.scanBarcode(
      //'#ff6666', 'Cancel', true, ScanMode.QR);

      text_scan =  await getScan();
      print('Data recibido en el escaner ${text_scan!}');
      if (text_scan == null || text_scan == '') {
        print('Se cancelo el escaneo Scan controller');
        if(widget.process == ProcessType.READ_PULSERA){

          widget.onCancel!();
          Navigator.of(context).pop();
          //Navigator.of(context).pop();
        }
        text_title = 'Pulsera no escaneada. Intenta de nuevo';
        pulsera_lectura = false;
        setState(()  { });
        return;
      }
      var arrayUser = text_scan!.split('|');
      if (arrayUser.length != 2) {
        text_title = 'Pulsera no valida';
        pulsera_lectura = false;
        setState(()  { });
      }
      else {
        pulsera_lectura = true;
        text_title = 'Pulsera Escaneada';
        setState(()  { });
        //cant_pulsera++;
        if(widget.process == ProcessType.READ_PULSERA){

          widget.onDataChange!(text_scan!);
          Navigator.of(context).pop();
        }
        else if(widget.process == ProcessType.ADD_CORTESIA){

          ref.read(apiNotiier.notifier).reset();
          ref.read(apiNotiier.notifier).addCortesia(text_scan!, userOperativo!.data_encripted, widget.json_cortesia.toString());
        }
        else if(widget.process == ProcessType.REMOVE_CORTESIA){

          ref.read(apiNotiier.notifier).reset();
          ref.read(apiNotiier.notifier).removeCortesias(text_scan!, userOperativo!.data_encripted);
        }
      }
      setState(()  { });

    } on PlatformException {
      text_scan = '';
      print("Exception al escanear : Plataform esception");
      if(widget.process == ProcessType.READ_PULSERA){

        widget.onDataChange!(text_scan!);
        Navigator.of(context).pop();
      }
    }catch(e){
      print("Exception al escanear : ${e.toString()}");
      if(widget.process == ProcessType.READ_PULSERA){

        widget.onDataChange!('');
        Navigator.of(context).pop();
      }
      print("Exception al escanear : ${e.toString()}");
    }
  }


  @override
  Widget build(BuildContext context) {
    print(userOperativo!.user);

    apiRes = ref.watch(apiNotiier);


    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius:BorderRadius.circular(20.0)),
      child: Container(
        color: AppColors.backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            Text(widget.process.getName(),style:TextStyle(fontSize: 20, ), textAlign: TextAlign.center),
            const SizedBox(height: 50),
            widget.process == ProcessType.READ_PULSERA ? const CircularProgressIndicator(color: AppColors.primaryColor,)
            :
            pulsera_lectura ?
            apiRes.when(
              available: (apiState) {
                print('Entro al apistate');
                print('api res Pulsera ok');
                if(apiState.rcode == 0){
                  setState(() {
                    cant_pulsera++;
                    text_title = 'Pulsera lista';
                  });
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
                      ButtomCustom(text: 'Escanear', onPressed: () async{
                        getcode();
                      },)
                    ],
                  );
                }
                else{

                  setState(() {
                    text_title = 'Error';
                  });
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
                      Text(apiState.message,style:const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      ButtomCustom(text: 'Escanear', onPressed: () async{
                        getcode();
                      },)
                    ],
                  );
                }
              },
              initial: () {
                print('Inicial');
                return Container(
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
                  child: const Icon(Icons.circle_outlined,
                      color: AppColors.backgroundColor,
                      size: 40
                  ),
                );
              },
              loading: () {
                print('Cargando');
                setState(() {
                  text_title = 'Procesando...';
                });
                return const CircularProgressIndicator(color: AppColors.primaryColor,);
              },
              error: (statuscode, message) {
                setState(() {
                  text_title = 'Error';
                });

                print('api res Pulsera Error');
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
                    ButtomCustom(text: 'Escanear', onPressed: () async{
                      getcode();
                    },)
                  ],
                );
              },
            )
                : Container(
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
              child: const Icon(Icons.error,
                  color: AppColors.textColorError,
                  size: 40
              ),
            ),
            const SizedBox(height: 30),
            Text(text_title,style:TextStyle(fontSize: 25, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            widget.process == ProcessType.READ_PULSERA ? SizedBox() : Text("Pulseras listas: ${cant_pulsera}",style:TextStyle(fontSize: 20), textAlign: TextAlign.center,),
            const SizedBox(height: 50),
            GestureDetector(
              child: const Text('Cancelar', style: TextStyle(color: AppColors.primaryColor,fontSize: 15),),
              onTap: () {
                if(widget.process != ProcessType.READ_PULSERA){
                  widget.onCancel!();
                }
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
