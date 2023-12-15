

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/ui/components/nfc_controller.dart';
import 'package:indierocks_cubetero/ui/enum/enum_process.dart';
import 'package:indierocks_cubetero/ui/enum/enum_scan_type.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class DialogScanHandlerV2 {
  Future<String?> hanlderScan(ScanType type, BuildContext context){
    switch(type){
      case ScanType.QR:
        return _scanQR();
      case ScanType.NFC:
        return _scanNFC(context);
      default:
        return _scanQR();
    }
  }

  Future<String?> _scanQR() async {
    String? cameraScanResult = '';

    print('Inicio de metodo _scanQR');
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      //cameraScanResult = await FlutterBarcodeScanner.scanBarcode(
      //'#ff6666', 'Cancel', true, ScanMode.QR);
      cameraScanResult = await scanner.scan();
      print('Data recibido ${cameraScanResult}');
    } on PlatformException {
      cameraScanResult = '';
      print("Exception al escanear : Plataform esception");
    }catch(e){

      print("Exception al escanear : ${e.toString()}");
    }
    return cameraScanResult;
  }

  Future<String?> _scanNFC(BuildContext context) async {
    Completer<String?> completer = Completer<String?>();
    // Lógica para leer NFC
    // Simulando la lectura de NFC
    String? nfc_red = '';
    showDialog(context: context,
        barrierDismissible: false, builder: (context){
          return NFCController(process: ProcessType.READ_PULSERA,
            json_cortesia: [],
            onDataChange: (data) {

              completer.complete(data);

            },
          );
        });
    /*showDialog(context: context,barrierDismissible: false, builder: (context) {

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          Ndef? ndef = Ndef.from(tag);
          if (ndef != null) {
            NdefMessage? message = await ndef.read();
            if (message != null) {
              for (NdefRecord record in message.records) {
                var decodedPayload = Utf8Decoder().convert(record.payload);
                NfcManager.instance.stopSession();
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo

                completer.complete(decodedPayload);
              }
            }
          }
        },

      );

      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius:BorderRadius.circular(20.0)),
        child: Container(
          color: AppColors.backgroundColor,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              const Spacer(),
              const CircularProgressIndicator(color: AppColors.primaryColor,),
              const Spacer(),
              const Spacer(),
              const Text("Esperando",style:TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              const Text("Acerca la pulsera",style:TextStyle(fontSize: 20),),
              const Spacer(),
              GestureDetector(
                child: const Text('Cancelar', style: TextStyle(color: AppColors.primaryColor,fontSize: 15),),
                onTap: () {

                  NfcManager.instance.stopSession();
                  return completer.complete('');
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      );
    },);*/
    return completer.future;

  }

}