


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
  final Function(String data, BankType banco)? dataCallback;
  DialogScanHandler({
    required this.parentContext,
    required this.process,
    this.dataCallback,
  });


  Future<void> showDialogOption() async{
    await showDialog(
        context: parentContext,
        builder: (context){
          return  SimpleDialog(
            backgroundColor: AppColors.backgroundColor,
            title: Text("¿Que deseas usar?"),
            children: [
              SimpleDialogOption(
                onPressed: () async {
                  print('Inicio de escaner qe');
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
                        return  ScanController(process: ProcessType.READ_PULSERA,
                          json_cortesia: [],
                          onDataChange: (data) {
                            dataCallback!(data, BankType.QR);
                          },
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

                  showDialog(context: context,
                      barrierDismissible: false, builder: (context){
                        return NFCController(process: process,
                          json_cortesia: [],
                          onDataChange: (data) {
                            dataCallback!(data, BankType.NFC);
                            Navigator.of(context).pop();
                            print('data');
                          },
                          onCancel: () {
                            Navigator.of(context).pop();
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