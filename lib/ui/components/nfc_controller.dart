


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/api/api_provider.dart';
import 'package:indierocks_cubetero/core/providers/api/api_state.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/widgets/loading_widget.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCController extends ConsumerStatefulWidget {
  final ProcessType process;
  final List<dynamic> json_cortesia;
  final Function(String data)? onDataChange;
  final Function()? onCancel;
  final String eventId;
  NFCController( {Key? key,
    required this.process,
    this.json_cortesia = const [],
    this.onDataChange,
    this.onCancel,
    this.eventId = '0'
  }) : super(key: key);

  @override
  _NFCControllerState createState() => _NFCControllerState();

  static void _defaultCallback(String data) { }
}

class _NFCControllerState extends ConsumerState<NFCController> {

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

      print('json_cortesias nfcController: ${widget.json_cortesia}');

    });

    NfcManager.instance.startSession(
        onDiscovered: _handleDiscovered
    );
  }

  Future<void> _handleDiscovered(NfcTag tag) async {

    pulsera_lectura = true;
    //await Future.delayed(Duration(seconds: 3));
    Ndef? ndef = Ndef.from(tag);
    if (ndef != null) {
      try {
        NdefMessage? message = await ndef.read();
        if (message != null) {
          for (NdefRecord record in message.records) {
            var decodedPayload = Utf8Decoder().convert(record.payload);
            print(decodedPayload);
            setState(() {
              if (decodedPayload == null) {
                text_title = 'Pulsera no escaneada. Intenta de nuevo';
                pulsera_lectura = false;
                return;
              }
              var arrayUser = decodedPayload.split('|');
              if (arrayUser.length != 2) {
                text_title = 'Pulsera no valida';
                pulsera_lectura = false;
              }
              else {
                pulsera_lectura = true;
                text_title = 'Pulsera Escaneada';
                //cant_pulsera++;
                if(widget.process == ProcessType.READ_PULSERA){

                  widget.onDataChange!(decodedPayload);
                  NfcManager.instance.stopSession();
                  Navigator.of(context).pop();
                }
                else if(widget.process == ProcessType.ADD_CORTESIA){

                  ref.read(apiNotiier.notifier).reset();
                  ref.read(apiNotiier.notifier).addCortesia(decodedPayload, userOperativo!.data_encripted, widget.json_cortesia.toString(), widget.eventId);
                }
                else if(widget.process == ProcessType.REMOVE_CORTESIA){

                  ref.read(apiNotiier.notifier).reset();
                  ref.read(apiNotiier.notifier).removeCortesias(decodedPayload, userOperativo!.data_encripted);
                }
              }
            });
          }
        }
        else {
          setState(() {
            pulsera_lectura = false;
            text_title = 'Pulsera no escaneada. Intenta de nuevo';
          });
        }
      } catch (e) {

        setState(() {
          pulsera_lectura = false;
          text_title ='Error al escanear pulsera';
        });
      }
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
        color: AppColors.background_general_second,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            Text(widget.process.getName(),style:TextStyle(fontSize: 20, ), textAlign: TextAlign.center),
            const SizedBox(height: 50),
            widget.process == ProcessType.READ_PULSERA ?
              LoadingWidget():
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
                    return const LoadingWidget();
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

                setState(() {

                  cant_pulsera = 0;
                });
                NfcManager.instance.stopSession();
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
