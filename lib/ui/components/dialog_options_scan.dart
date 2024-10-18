

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/res_scan_dialog_model.dart';
import 'package:indierocks_cubetero/domain/constants/enum_api_option.dart';
import 'package:indierocks_cubetero/ui/components/nfc_controller.dart';
import 'package:indierocks_cubetero/ui/enum/enum_banks.dart';
import 'package:indierocks_cubetero/ui/enum/enum_permisos.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/enum/enum_scan_type.dart';
import 'package:indierocks_cubetero/ui/helper/permisos_helper.dart';
import 'package:indierocks_cubetero/ui/widgets/snackbar_custom.dart';

import 'dialog_scan_handlerV2.dart';

class DialogOptionScan {

  final BuildContext _context;
  final ProcessType _process;
  DialogOptionScan( {
    required BuildContext context,
    required ProcessType process
  }): assert(context!= null),
        assert(process!= null),
        _context = context,
        _process = process;

  Future<ResScanDialogModel> showDialogOption() async {
    Completer<ResScanDialogModel> completer = Completer<ResScanDialogModel>();
    await showDialog(
        context: _context,
        builder: (context){
          return  SimpleDialog(
            backgroundColor: AppColors.background_general_second,
            title: Text("¿Que deseas usar?"),
            children: [
              SimpleDialogOption(
                onPressed: () async {
                  print('Inicio de escaner qr');
                  bool permisos = await PermisosHelper().helperPermisos(PermisosType.CAMERA);
                  if (!permisos){
                    SnackbarCustom(
                      message: 'Debes conceder permisos de camara para poder escanear.',
                      backgroundColor: AppColors.alert_information,
                      textColor: AppColors.textColorInformation,
                      icon: Icons.error,
                      context: context,
                    ).showdialog();

                  }
                  else{

                    print('Scaner QR');
                    String? string_scan  = await DialogScanHandlerV2().hanlderScan(ScanType.QR, context);
                    print('TextEscaneado: $string_scan');
                    if(string_scan.toString().length == 0 || string_scan.toString() == ''){
                      completer.complete(ResScanDialogModel(rcode: -1,banco: BankType.QR, message: 'Sin Informacion Escaneada'));
                    }
                    else{
                      completer.complete(ResScanDialogModel(rcode: 0,banco: BankType.QR, message: string_scan.toString()));
                    }


                  }

                  Navigator.of(context).pop();

                },
                child: Text("Escanear QR"),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  print('Scaneo de NFC');

                  showDialog(context: context,
                      barrierDismissible: false, builder: (context){
                        return NFCController(process: _process,
                          json_cortesia: [],
                          onDataChange: (data) {

                            Navigator.of(context).pop(); // Cierra el cuadro de diálogo
                            if(data.toString().length == 0 || data.toString() == ''){
                              completer.complete(ResScanDialogModel(rcode: 0,banco: BankType.NFC, message: 'Sin Informacion Leida'));
                              return completer.future;
                            }
                            else{
                              completer.complete(ResScanDialogModel(rcode: 0,banco: BankType.NFC, message: data));
                              return completer.future;
                            }

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
    ); // Cierra el cuadro de diálogo);
    return completer.future;
  }
}