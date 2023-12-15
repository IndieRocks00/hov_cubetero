import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:indierocks_cubetero/Utils/UITools.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/Tools.dart';

class ConsultarBalance extends StatefulWidget {
  const ConsultarBalance({Key? key}) : super(key: key);

  @override
  State<ConsultarBalance> createState() => _ConsultarBalanceState();
}

class _ConsultarBalanceState extends State<ConsultarBalance> {

  String _name = "";
  String version_code = "";
  String _balance = "0.0";
  bool banQR = false;
  String text_title = "";

  var _codeV = "";
  var _code = "";

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {

      getUser();
      getVersionApp();
      getBalanceScan();

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UITools.getAppBar(context, _name),
      drawer: UITools.getMenulateral(context),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              padding: const EdgeInsets.only(top: 10, left: 20,),
              color: ColorsIndie.colorGC2.getColor(),
              child: Row(
                children: [
                  Expanded(flex: 2,child:
                  Center(
                    child: Image.asset("assets/images/foro_ir_white.png",
                      height: 150,
                    ),
                  ),
                  ),
                  Expanded(flex: 1,
                    child:
                    Center(
                        child: GestureDetector(
                          onTap: (){
                            getBalanceScan();
                          },
                          child: Image.asset("assets/images/scanqr.png",
                            height: 30,
                          ),
                        )
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40,),
            Container(
              margin: EdgeInsets.only(left: 40,right: 40),
              child: Text(text_title,
                  style: TextStyle(fontSize: 30)
              ),
            ),

            SizedBox(height: 40,),
            Container(
              margin: EdgeInsets.only(left: 40,right: 40),
              child: Text(MoneyFormatter(amount: double.parse(_balance)).output.symbolOnLeft,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)
              ),
            ),
            !banQR? SizedBox(height: 0,):
            Container(
              alignment: Alignment.center,
              child: QrImageView(data: _balance,
                size: MediaQuery.of(context).size.width/2,
              ),
            ),
          ],
        ),
      ),
    );
  }


  getUser() async {
    String data_user = await DataBaseHelper.getValue(DBHelperItem.nameClient.getValue());
    setState(() {
      _name = data_user;
    });
  }


  Future<void> getBalanceScan() async {
    _MenuOptionsPay();
    /*if (Permission.camera.status != PermissionStatus.granted){
      if (await Permission.camera.request().isDenied) {
        Tools().showMessageBox(context, "Debe conceder permiso de camara, para poder escanear la información de QR");
        return;
      }
    }

    String? cameraScanResult = '';

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {

      //cameraScanResult = await FlutterBarcodeScanner.scanBarcode(
          //'#ff6666', 'Cancel', true, ScanMode.QR);
      cameraScanResult = await scanner.scan();
      print(cameraScanResult);
    } on PlatformException {
      cameraScanResult = '';
    }
    print(cameraScanResult);
    var arrayUser = getString(cameraScanResult!);
    setState(() {
      if(arrayUser == null){
        //Tools().showMessageBox(context, "No se pudo obtener información del escaneo. Intenta de nuevo mas tarde");

        text_title = 'No se pudo obtener información del escaneo. Intenta de nuevo mas tarde';

        banQR=false;
      }
      else{

        String _codeV = arrayUser[0];
        String _code = arrayUser[1];
        fetchBalance(_codeV, _code).then((value) {
          switch(value['rcode']){
            case -1:
              //Tools().showMessageBox(context,value['msg']);
              setState(() {
                text_title = value['msg'];
                _balance = '0';
                banQR=false;
              });
              break;

            case 0:

              setState(() {
                text_title = 'Hola. \nTu saldo disponible es de:';
                _balance = value['msg'];
                banQR=true;
              });
              /*setState(() {
                banQR = false;
                dataQR = value['msg'];
              });*/
              break;
            case 1:

              setState(() {
                _balance = '0';
                text_title = 'Error al obtener el balance del cliente';
                banQR=false;
              });
              //Tools().showMessageBox(context,'Error al obtener el balance del cliente');
              break;
            default:

              setState(() {
                _balance = '0';
                text_title = 'No se pudo obtener información del balance[1]';
                banQR=false;
              });
              //Tools().showMessageBox(context,'No se pudo obtener información del balance[1]');
              break;
          }

        },);
      }
    });*/

    /*DataBaseHelper.updateBalance(cameraScanResult!);
    setState(() {

      textBalance = double.parse(cameraScanResult);
    });*/
  }

  var msg ;
  Future<SimpleDialog> _MenuOptionsPay() async{
    return await showDialog(
        context: context,
        builder: (context){
          return  SimpleDialog(
            title: Text("¿Que deseas escanear?"),
            children: [
              SimpleDialogOption(
                onPressed: () async {
                  if (Permission.camera.status != PermissionStatus.granted){
                    if (await Permission.camera.request().isDenied) {
                      Tools().showMessageBox(context, "Debe conceder permiso de camara, para poder escanear la información de QR");
                      return;
                    }
                  }

                  String? cameraScanResult = '';

                  // Platform messages may fail, so we use a try/catch PlatformException.
                  try {
                    //cameraScanResult = await FlutterBarcodeScanner.scanBarcode(
                    //'#ff6666', 'Cancel', true, ScanMode.QR);
                    cameraScanResult = await scanner.scan();
                    print(cameraScanResult);
                  } on PlatformException {
                    cameraScanResult = '';
                  }
                  print(cameraScanResult);
                  print("Inicio de pago en efectivo");
                  setState(() {

                    var arrayUser = getString(cameraScanResult!);

                    /*_name_code = arrayUser[0];
                  _user_code = arrayUser[1];
                  _pass_code = arrayUser[2];*/

                    Navigator.of(context).pop();
                    setState(() {
                      if(arrayUser == null){
                        //Tools().showMessageBox(context, "No se pudo obtener información del escaneo. Intenta de nuevo mas tarde");

                        text_title = 'No se pudo obtener información del escaneo. Intenta de nuevo mas tarde';

                        banQR=false;
                      }
                      else{

                        String _codeV = arrayUser[0];
                        String _code = arrayUser[1];
                        fetchBalance(_codeV, _code).then((value) {
                          switch(value['rcode']){
                            case -1:
                            //Tools().showMessageBox(context,value['msg']);
                              setState(() {
                                text_title = value['msg'];
                                _balance = '0';
                                banQR=false;
                              });
                              break;

                            case 0:

                              setState(() {
                                text_title = 'Hola. \nTu saldo disponible es de:';
                                _balance = value['msg'];
                                banQR=true;
                              });
                              /*setState(() {
                banQR = false;
                dataQR = value['msg'];
              });*/
                              break;
                            case 1:

                              setState(() {
                                _balance = '0';
                                text_title = 'Error al obtener el balance del cliente';
                                banQR=false;
                              });
                              //Tools().showMessageBox(context,'Error al obtener el balance del cliente');
                              break;
                            default:

                              setState(() {
                                _balance = '0';
                                text_title = 'No se pudo obtener información del balance[1]';
                                banQR=false;
                              });
                              //Tools().showMessageBox(context,'No se pudo obtener información del balance[1]');
                              break;
                          }

                        },);
                      }
                    });
                  });

                  //txUsuarioControll.text = _name_code;


                },
                child: Text("QR"),
              ),
              SimpleDialogOption(
                onPressed: () async {

                  Navigator.of(context).pop();
                  if(await NfcManager.instance.isAvailable()){

                    Tools().showMessageBox(context, "Acerque su pulsera al dispositivo para escanear");
                    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {

                      print("NFC: ${tag.data}");
                      Ndef? ndf = Ndef.from(tag);
                      print("Tag: ${ndf?.cachedMessage!.records[0].payload}");
                      var res = Utf8Decoder().convert(ndf!.cachedMessage!.records[0].payload);
                      res = res.substring(3);
                      print("Content: ${res}");
                      NfcManager.instance.stopSession();
                      var arrayUser = getString(res);
                      print(arrayUser[0]);
                      //Tools().showMessageBox(context, arrayUser[0]);
                      setState(() {

                        if(arrayUser == null){
                          //Tools().showMessageBox(context, "No se pudo obtener información del escaneo. Intenta de nuevo mas tarde");

                          text_title = 'No se pudo obtener información del escaneo. Intenta de nuevo mas tarde';

                          banQR=false;
                        }
                        else{

                          String _codeV = arrayUser[0];
                          String _code = arrayUser[1];
                          fetchBalance(_codeV, _code).then((value) {
                            switch(value['rcode']){
                              case -1:
                              //Tools().showMessageBox(context,value['msg']);
                                setState(() {
                                  text_title = value['msg'];
                                  _balance = '0';
                                  banQR=false;
                                });
                                break;

                              case 0:

                                setState(() {
                                  text_title = 'Hola. \nTu saldo disponible es de:';
                                  _balance = value['msg'];
                                  banQR=true;
                                });
                                /*setState(() {
                banQR = false;
                dataQR = value['msg'];
              });*/
                                break;
                              case 1:

                                setState(() {
                                  _balance = '0';
                                  text_title = 'Error al obtener el balance del cliente';
                                  banQR=false;
                                });
                                //Tools().showMessageBox(context,'Error al obtener el balance del cliente');
                                break;
                              default:

                                setState(() {
                                  _balance = '0';
                                  text_title = 'No se pudo obtener información del balance[1]';
                                  banQR=false;
                                });
                                //Tools().showMessageBox(context,'No se pudo obtener información del balance[1]');
                                break;
                            }

                          },);
                        }
                      });
                    });
                    return;
                  }
                  else{
                    Tools().showMessageBox(context, "Dispositivo no cuenta con lector NFC disponible");
                    return;
                  }
                },
                child: Text("Pulsera"),
              ),
            ],
          );
        }
    );
  }

  Future<void> getVersionApp() async{

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version_code = Encriptacion().encryptDataE(packageInfo.version, Encriptacion.keyIdVer);
    print(version_code);
  }

  getString(String data)  {
    print('Data QR: $data');
    var array = data.split('|');
    var cont = 0;
    print('Tamaño : ${array.length} ');
    if(array.length ==1){

      setState(() {

        array = [version_code,data];
      });
    }
    else if(array.length > 2){
      return null;
    }

    print('Data QR: ${array[0]} : ${array[1]}');
    return array;
  }

  Future<Map<String,dynamic>>  fetchBalance(String codigoV, String codigo) async {


    print("Init Balance");
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <detailB xmlns="http://tempuri.org/">
            <k>${Tools.keyIndie}</k>
            <codigoV>$codigoV</codigoV>
            <codigo>$codigo</codigo>
          </detailB>
        </soap:Body>
      </soap:Envelope>''';

    print(soap);
    showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    final response =
    await http.post(Uri.parse( IndieService.balance.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.balance.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);
        String element = document.findAllElements("detailBResponse").first.text;
        String? res = "0";
        if (element == ""){
          res = "0";
        }
        else{
          String res = document.findAllElements("detailBResponse").first.text;
          print(jsonDecode(res));
          return jsonDecode(res);
        }

        print(jsonDecode(res));
        return jsonDecode(res);
      } else {
        // Si esta respuesta no fue OK, lanza un error.
        //throw Exception('Failed to load post');

        var resError = {
          'rcode':-1,
          'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde.'
        };

        return resError;
      }
    }, onError:(error) {
      print('Error: $error');
      Navigator.pop(context);
      var resError = {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$error]'
      };

      return resError;
    });
    print(response);
    return response;


  }
}
