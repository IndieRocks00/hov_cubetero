


import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/ui/components/nfc_controller.dart';
import 'package:indierocks_cubetero/ui/components/scan_controller.dart';
import 'package:indierocks_cubetero/ui/enum/enum_banks.dart';
import 'package:indierocks_cubetero/ui/enum/enum_permisos.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/helper/permisos_helper.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';

class DialogScanHandler{

  final BuildContext parentContext;
  final ProcessType process;
  final List<dynamic> json_cortesia;
  final String eventId;
  final Function(String data, BankType banco)? dataCallback;
  DialogScanHandler({
    required this.parentContext,
    required this.process,
    this.json_cortesia = const [],
    this.dataCallback,
    this.eventId = '0'
  });


  Future<void> showDialogOption() async{
    print('json_cortesias: $json_cortesia');
    await showDialog(
        context: parentContext,
        builder: (context){
          return  SimpleDialog(
            backgroundColor: AppColors.background_general_second,
            title: Text("¿Que deseas usar?"),
            children: [
              SimpleDialogOption(
                onPressed: () async {
                  print('Inicio de escaner qr');
                  bool permisos = await PermisosHelper().helperPermisos(PermisosType.CAMERA);
                  print('Permisos de camera: ${permisos}');
                  if (!permisos){
                    SnackbarCustom(
                      message: 'Debes conceder permisos de camara para poder escanear.',
                      backgroundColor: AppColors.alert_information,
                      textColor: AppColors.textColorInformation,
                      icon: Icons.error,
                      context: context,
                    ).showdialog();
                    return;

                  }

                  showDialog(context: context,
                      barrierDismissible: false, builder: (context){
                        return  ScanController(process: process,
                          json_cortesia: json_cortesia,
                          onDataChange: (data) {
                            dataCallback!(data, BankType.QR);
                          },
                          onCancel: () {

                          }, eventId: eventId,
                        );
                      }).whenComplete(() {

                        if(Navigator.of(context).canPop()){
                          Navigator.of(context).pop();
                        }
                      },);

                },
                child: Text("Escanear QR"),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  print('Scaneo de NFC');

                  print('json_cortesias: $json_cortesia');
                  showDialog(context: context,
                      barrierDismissible: false, builder: (context){
                        /*return NFCController(process: process,
                          json_cortesia: [],
                          onDataChange: (data) {
                            dataCallback!(data, BankType.NFC);
                            Navigator.of(context).pop();
                            print('data');
                          },
                          onCancel: () {

                            if(Navigator.of(context).canPop()){
                              Navigator.of(context).pop();
                            }
                          },
                        );*/
                        return NFCController(process: process,
                          json_cortesia: json_cortesia,
                          onDataChange: (data) {

                            dataCallback!(data, BankType.NFC);
                            Navigator.of(context).pop();

                            print('Data Devuelto de lectura : ${data}');
                          },
                        );
                      });

                  /*String? string_scan  = await DialogScanHandler().hanlderScan(ScanType.NFC, context);
                  Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                  print('Retorno de nfc $string_scan-');
                  if(string_scan.toString().length == 0 || string_scan.toString() == ''){
                    completer.complete(ResScanDialogModel(rcode: 0,banco: BankType.NFC, message: 'Sin Informacion Leida'));
                  }
                  else{
                    completer.complete(ResScanDialogModel(rcode: 0,banco: BankType.NFC, message: string_scan.toString()));
                  }*/


                },
                child: Text("Leer pulsera"),
              ),
            ],
          );
        }
    );
  }

}