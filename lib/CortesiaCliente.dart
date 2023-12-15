import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:indierocks_cubetero/PaymentCortesia.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'Principal.dart';
import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/Tools.dart';
import 'Utils/UITools.dart';

class PCortesia extends StatefulWidget {
  const PCortesia({Key? key}) : super(key: key);

  @override
  State<PCortesia> createState() => _PCortesiaState();
}

class _PCortesiaState extends State<PCortesia> {

  String _name = "";
  String version_code = "";
  String _balance = "0.0";
  bool banQR = false;
  String text_title = "";
  var jsoncortesia = [];
  var _codeV = "";
  var _code = "";
  List<TextEditingController> _controllers = [];

  var dialog ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {});
      getVersionApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("CUBETERO", style: TextStyle(color: Colors.white),), backgroundColor: ColorsIndie.colorGC1.getColor()),
        backgroundColor: ColorsIndie.colorGC2.getColor(),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width),
                    height: 55,
                    decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38,
                              blurRadius: 5,
                              offset: Offset(0, 5)
                          )
                        ]
                    ),
                    child: ElevatedButton(onPressed: () {
                      //eventPayProduct();
                      //-------------------------------------------------------------------------------
                      _MenuOptionsPay();

                    },
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                              color: ColorsIndie.colorGC1.getColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                          primary: ColorsIndie.colorGC2.getColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),
                      child: Text("Escanear Cliente", style: TextStyle(
                          color: ColorsIndie.colorGC1.getColor())),
                    ),

                  ),
                  !banQR? Container(
                    alignment: Alignment.center,
                    child: Text('Sin información de cliente disponible')):
                      Column(
                        children: [
                          SizedBox(height: 40,),
                          Text(r'Balance: $'+_balance, style: TextStyle(fontSize: 30),)
                        ],
                      ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 50),
                    child:  Text('Cortesias disponibles',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),

                  SizedBox(height: 20,),
                  jsoncortesia.isEmpty || jsoncortesia[0]['ID']==-1 ? Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 100),
                    child:  Text('No cuentas con cortesias.',
                      style: TextStyle(fontSize: 30),
                    ),
                  ):
                  //Center(child: Text(jsoncortesia, style: TextStyle(fontSize: 30),),),
                  ListView.builder(
                    itemCount: jsoncortesia.isEmpty ? 0 : jsoncortesia.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      //_controllers.add(new TextEditingController( text: '0'));
                      return Card(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.only( left: 20, right: 20, top: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child:
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text( '${jsoncortesia[index]['SERVICE']}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),),
                                  Expanded(child:
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text( '${jsoncortesia[index]['Cantidad']}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),),
                                  /*Expanded(child:
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: TextField(
                                      textAlign: TextAlign.start,
                                      controller:   _controllers[index],
                                      keyboardType: TextInputType.numberWithOptions(decimal: false),),
                                  ),),*/

                                ],
                              ),



                              SizedBox(height: 20,)
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20,),
                  /*Container(
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width),
                    height: 55,
                    decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38,
                              blurRadius: 5,
                              offset: Offset(0, 5)
                          )
                        ]
                    ),
                    child: ElevatedButton(onPressed: () {
                      //eventPayProduct();
                      //_EnviarCortesia();
                    },
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                              color: ColorsIndie.colorGC1.getColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                          primary: ColorsIndie.colorGC2.getColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),
                      child: Text("Entregar Cortesia", style: TextStyle(
                          color: ColorsIndie.colorGC1.getColor())),
                    ),

                  ),*/

                  SizedBox(height: 20,),
                  Container(
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width),
                    height: 55,
                    decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black38,
                              blurRadius: 5,
                              offset: Offset(0, 5)
                          )
                        ]
                    ),
                    child: ElevatedButton(onPressed: () {
                      //eventPayProduct();
                      //_MenuOptionsPay();
                      /*if(jsoncortesia.isEmpty){
                        Tools().showMessageBox(context, "Debes escanear una pulsera para continuar.");
                        return;
                      }*/
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PrincipalActivity(json_cortesia: jsoncortesia,),), (route) => false);

                    },
                      style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                              color: ColorsIndie.colorGC1.getColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                          ),
                          primary: ColorsIndie.colorGC2.getColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),
                      child: Text("Agregar mas productos", style: TextStyle(
                          color: ColorsIndie.colorGC1.getColor())),
                    ),

                  ),
                ],
              ),
            ),

          ],
        ),
        drawer: UITools.getMenulateral(context)
    );
  }

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

                  _codeV = '';
                  _code = '';
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

                        _codeV = arrayUser[0];
                        _code = arrayUser[1];
                        jsoncortesia = [];
                        fetchBalance(_codeV, _code).then((value) {
                          switch(value['rcode']){
                            case -1:
                            //Tools().showMessageBox(context,value['msg']);
                              setState(() {
                                text_title = value['msg'];
                                _balance = '0';
                                jsoncortesia = [];
                                banQR=false;
                              });
                              break;

                            case 0:

                              setState(() {
                                text_title = 'Hola. \nTu saldo disponible es de:';
                                print('json corteria');
                                _balance = value['balance'];
                                banQR=true;

                                jsoncortesia = jsonDecode(value['msg']);
                                print('json cortesia: ${jsonDecode(value['msg'])}');
                              });
                              /*setState(() {
                banQR = false;
                dataQR = value['msg'];
              });*/
                              break;
                            case 1:

                              setState(() {
                                _balance = '0';
                                jsoncortesia = [];
                                text_title = 'Error al obtener el balance del cliente';
                                banQR=false;
                              });
                              //Tools().showMessageBox(context,'Error al obtener el balance del cliente');
                              break;
                            default:

                              setState(() {
                                _balance = '0';
                                jsoncortesia = [];
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

                  _codeV = '';
                  _code = '';
                  jsoncortesia = [];
                  Navigator.of(context).pop();
                  if(await NfcManager.instance.isAvailable()){
                    final dialogContextCompleter = Completer<BuildContext>();
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        if(!dialogContextCompleter.isCompleted) {
                          dialogContextCompleter.complete(dialogContext);
                        }
                        return  ProgressDialog(message: "Acerque Su pulsera");;
                      },
                    );
                    dialog = await dialogContextCompleter.future;
                    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
                      Navigator.pop(dialog);
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

                          _codeV = arrayUser[0];
                          _code = arrayUser[1];

                          jsoncortesia = [];
                          fetchBalance(_codeV, _code).then((value) {

                            switch(value['rcode']){
                              case -1:
                              //Tools().showMessageBox(context,value['msg']);
                                setState(() {
                                  text_title = value['msg'];
                                  _balance = '0';
                                  jsoncortesia = [];
                                  banQR=false;
                                });
                                break;

                              case 0:

                                setState(() {
                                  text_title = 'Hola. \nTu saldo disponible es de:';
                                  //_balance = value['msg'];
                                  _balance = value['balance'];
                                  jsoncortesia = jsonDecode(value['msg']);
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
                                  jsoncortesia = [];
                                  text_title = 'Error al obtener el balance del cliente';
                                  banQR=false;
                                });
                                //Tools().showMessageBox(context,'Error al obtener el balance del cliente');
                                break;
                              default:

                                setState(() {
                                  _balance = '0';
                                  jsoncortesia = [];
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

    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);


    print("Init Balance");
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <getCortesia xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigo</codigo>
          <codigoC>$codigoC</codigoC>
        </getCortesia>
      </soap:Body>
    </soap:Envelope>''';
    print(soap);
    showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    print("Init process 2");
    print('Responde: ${IndieService.getCortesia.getURL()}');
    print('Responde: ${IndieService.getCortesia.getSoapAction()}');
    final response =
    await http.post(Uri.parse( IndieService.getCortesia.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.getCortesia.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {

      print("Init process 3");
      print('Responde: $response');
      Navigator.pop(context);
      print("Init process ${response.statusCode}");
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);
        String element = document.findAllElements("getCortesiaResponse").first.text;
        String? res = "0";
        if (element == ""){
          res = "0";
        }
        else{
          String res = document.findAllElements("getCortesiaResponse").first.text;
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
/*
  void _EnviarCortesia() {

    print('codeV $_codeV');
    print('code $_code');

    bool banTexto = false;
    var json_send = [];
    int i = 0;
    var data = jsonEncode(jsoncortesia);
    //print(jsoncortesia[0]);
    for(Map<String,dynamic> object in jsoncortesia){
      TextEditingController data = _controllers[i];
      if(data.text != '' && data.text != '0'&& data.text != null){
        json_send.add(
            {
              '"sku"': '"${object['sku']}"',
              '"nProd"': data.text
            }
        );
      }
      i++;
    }

    if (json_send.length == 0){
      Tools().showMessageBox(context, "Debe ingresar cantidad en las cortesias a entregar");
      return;
    }
    print(json_send);

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentCortesia(codigo: _code, codigoV: _codeV, codigoP: '[]', monto: 0, propina: 0, inventario: (!false).toString(), modePayment: 1, banco: 1, referencia: "", codigoPCosrtesia: '$json_send',),));

  }*/


  Future<void> getVersionApp() async{
    if (!mounted) {
      return; // Just do nothing if the widget is disposed.
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version_code = Encriptacion().encryptDataE(packageInfo.version, Encriptacion.keyIdVer);
    print(version_code);
  }

}
