import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/Tools.dart';
import 'Utils/UITools.dart';

class AddCortesiaV2 extends StatefulWidget {
  const AddCortesiaV2({Key? key}) : super(key: key);

  @override
  State<AddCortesiaV2> createState() => _AddCortesiaV2State();
}

class _AddCortesiaV2State extends State<AddCortesiaV2> {

  var _codeV = "";
  var _code = "";
  var _banco = "0";

  var json_cortesia_options = [];

  var version_code = "";
  String name_user = "";
  var etCantidadControlloler = TextEditingController();
  List<TextEditingController> _controllers = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {});
      getVersionApp();
      getUser();
      _controllers = [];
      fetchGetCortesiaOptions().then((value) {
        switch(value['rcode']){
          case -1:
          //Tools().showMessageBox(context,value['msg']);
            setState(() {
              json_cortesia_options = [];
            });
            break;

          case 0:

            setState(() {
              json_cortesia_options = jsonDecode(value['msg']);
            });
            /*setState(() {
                banQR = false;
                dataQR = value['msg'];
              });*/
            break;
          case 1:

            setState(() {
              json_cortesia_options = [];
            });
            //Tools().showMessageBox(context,'Error al obtener el balance del cliente');
            break;
          default:

            setState(() {
              json_cortesia_options = [];
            });
            //Tools().showMessageBox(context,'No se pudo obtener información del balance[1]');
            break;
        }

      });
    });
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: UITools.getAppBar(context, name_user),
      drawer: UITools.getMenulateral(context),
      backgroundColor: ColorsIndie.colorGC2.getColor(),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(20),
          child: Column(
            children: [

              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 100,
                padding: const EdgeInsets.only(top: 5, left: 20,),
                color: ColorsIndie.colorGC2.getColor(),
                child: Row(
                  children: [
                    Expanded(flex: 1, child:
                    Center(
                      child: Image.asset("assets/images/foro_ir_white.png",
                        height: 150,
                      ),
                    ),
                    ),
                  ],
                ),
              ),

              Text("Ingresa la cantidad de cortesias para el cliente",
                style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 20,),
              ),
              json_cortesia_options.isEmpty || json_cortesia_options[0]['ID']==-1 ? Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 100),
                child:  Text('No hay categorias disponibles para asignar las cortesias, intenta mas tarde o revisa con tu administrador',
                  style: TextStyle(fontSize: 30),
                ),
              ):
              //Center(child: Text(jsoncortesia, style: TextStyle(fontSize: 30),),),
              ListView.builder(
                itemCount: json_cortesia_options.isEmpty ? 0 : json_cortesia_options.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var controller = new TextEditingController(text: '0');
                  _controllers.add(controller);

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
                                child: Text( '${json_cortesia_options[index]['SERVICE']}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),),
                              Expanded(child:
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text( '${json_cortesia_options[index]['DESCRIPCION']}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),),
                              Expanded(child:
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: TextField(
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          _controllers[index].text = '0';
                                        } else if (value.startsWith('0')) {
                                          _controllers[index].value = TextEditingValue(
                                            text: value.substring(1),
                                            selection: TextSelection.collapsed(offset: 1),
                                          );
                                        }
                                      },
                                      textAlign: TextAlign.start,
                                      controller:   _controllers[index],
                                      keyboardType: TextInputType.numberWithOptions(decimal: false),),

                                  ),
                              ),

                            ],
                          ),



                          SizedBox(height: 20,)
                        ],
                      ),
                    ),
                  );
                },
              ),
              /*TextField(
                controller: etCantidadControlloler,

                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2)
                ],
                keyboardType: TextInputType.numberWithOptions(
                    decimal: false),
                maxLines: 1,
                style: TextStyle(fontSize: 22,
                    color: ColorsIndie.colorGC1.getColor()),
                decoration: InputDecoration(
                    filled: true,
                    hintText: "Cantidad",
                    fillColor: ColorsIndie.colorGC3.getColor(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          width: 0,
                          style: BorderStyle.none,
                        )
                    )
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
                  eventAddCortesia();
                },
                  style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                          color: ColorsIndie.colorGC1.getColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                      backgroundColor: ColorsIndie.colorGC2.getColor(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                  ),
                  child: Text("Cargar cortesia", style: TextStyle(
                      color: ColorsIndie.colorGC1.getColor())),
                ),

              ),
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
                  eventARemoveCortesia();
                },
                  style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(
                          color: ColorsIndie.colorGC1.getColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                      backgroundColor: ColorsIndie.colorGC2.getColor(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                  ),
                  child: Text("Remover cortesia", style: TextStyle(
                      color: ColorsIndie.colorGC1.getColor())),
                ),

              )
            ],
          ),
        ),
      ),
    );
  }



  Future<void> getVersionApp() async{
    if (!mounted) {
      return; // Just do nothing if the widget is disposed.
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version_code = Encriptacion().encryptDataE(packageInfo.version, Encriptacion.keyIdVer);
    print(version_code);
  }

  getUser() async {if (!mounted) {
    return; // Just do nothing if the widget is disposed.
  }
  String data_user = await DataBaseHelper.getValue(DBHelperItem.nameClient.getValue());
  setState(() {
    name_user = data_user;
  });
  }

  void eventARemoveCortesia() {

    /*if( etCantidadControlloler.text.isEmpty){
      Tools().showMessageBox(context, "Debe especificar una cantidad de cortesias para asignar cortesias");
      return;
    }*/
    //_displayTextInputDialog(context);
    _MenuOptionsRemoveCortesia();

  }

  Future<Map<String,dynamic>>  fetchGetCortesiaOptions() async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);


    print("Init Balance");
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <getOptionsCortesia xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigoC>$codigoC</codigoC>
        </getOptionsCortesia>
      </soap:Body>
    </soap:Envelope>''';
    print(soap);
    showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    print("Init process 2");
    print('Responde: ${IndieService.getOptionsCortesia.getURL()}');
    print('Responde: ${IndieService.getOptionsCortesia.getSoapAction()}');
    final response =
    await http.post(Uri.parse( IndieService.getOptionsCortesia.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.getOptionsCortesia.getSoapAction(),
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
        String element = document.findAllElements("getOptionsCortesiaResponse").first.text;
        String? res = "0";
        if (element == ""){
          res = "0";
        }
        else{
          String res = document.findAllElements("getOptionsCortesiaResponse").first.text;
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

  Future<SimpleDialog> _MenuOptionsRemoveCortesia() async{

    return await showDialog(
        context: context,
        builder: (context){
          return  SimpleDialog(
            title: Text("¿Que desea usar?"),
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

                  var arrayUser = getString(cameraScanResult!);
                  setState(() {
                    if(arrayUser == null){

                      _codeV = '';
                      _code ='';
                      _banco = "0";
                    }
                    else{
                      _banco = "2";

                      _codeV = arrayUser[0];
                      _code = arrayUser[1];

                      //var jsonEncriptCarrito = Encriptacion().encryptDataE('$jsonCarritoMap', Encriptacion.keyVersion);
                      //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto+propina, propina: propina, inventario: (!banInventario).toString(), modePayment: 1, banco: 1, referencia: "",),));
                      fetchRemoveCortesia(_codeV, _code).then((value) {
                        print('Res Login: $value');
                        switch(value['rcode']){
                          case -1:
                            Tools().showMessageBox(context,value['msg']);
                            break;
                          case 0:


                            Tools().showMessageBox(context,'Cortesia removida correctamente');
                            break;
                          case 1:
                            setState(() {

                              Tools().showMessageBox(context,'Error al remover la cortesia: ${value['msg']}');
                            });
                            break;
                          default:

                            Tools().showMessageBox(context,'Error al remover la cortesia[1]');
                            break;
                        }
                      });
                    }
                  });
                },
                child: Text("QR"),
              ),
              SimpleDialogOption(
                onPressed: () async {
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
                          _codeV = "";
                          _code = "";
                          _banco = "0";
                        }
                        else{
                          _banco = "2";
                          _codeV = arrayUser[0];
                          _code = arrayUser[1];
                          //var jsonEncriptCarrito = Encriptacion().encryptDataE('$jsonCarritoMap', Encriptacion.keyVersion);

                          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto+propina, propina: propina, inventario: (!banInventario).toString(), modePayment: 1,banco: 2, referencia: ""),));
                          fetchRemoveCortesia(_codeV, _code).then((value) {
                            print('Res Login: $value');
                            switch(value['rcode']){
                              case -1:
                                Tools().showMessageBox(context,value['msg']);
                                break;
                              case 0:


                                Tools().showMessageBox(context,'Cortesia removida correctamente');
                                break;
                              case 1:
                                setState(() {

                                  Tools().showMessageBox(context,'Error al remover la cortesia: ${value['msg']}');
                                });
                                break;
                              default:

                                Tools().showMessageBox(context,'Error al remover la cortesia[1]');
                                break;
                            }
                          });
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
                child: Text("pulsera"),
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

  Future<Map<String,dynamic>>  fetchRemoveCortesia(String codigoV, String codigo) async {


    print("Init Balance");

    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <removeCortesia xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigo</codigo>
          <codigoC>$codigoC</codigoC>
        </removeCortesia>
      </soap:Body>
    </soap:Envelope>''';

    print(soap);
    showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    print("Init process 2");
    print('Responde: ${IndieService.removeCortesia.getURL()}');
    print('Responde: ${IndieService.removeCortesia.getSoapAction()}');
    final response =
    await http.post(Uri.parse( IndieService.removeCortesia.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.removeCortesia.getSoapAction(),
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
        String element = document.findAllElements("removeCortesiaResponse").first.text;
        String? res = "0";
        if (element == ""){
          res = "0";
        }
        else{
          String res = document.findAllElements("removeCortesiaResponse").first.text;
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
  Future<Map<String,dynamic>>  fetchAddCortesia(String codigoV, String codigo, var jsonCortseria) async {


    print("Init Balance");
    String jsonEncriptado = Encriptacion().encryptDataE("${jsonCortseria}", Encriptacion.keyVersion);

    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <addCortesia xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigo</codigo>
          <codigoC>$codigoC</codigoC>
          <codigoCortesias>$jsonEncriptado</codigoCortesias>
        </addCortesia>
      </soap:Body>
    </soap:Envelope>''';


    print(soap);
    showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    print("Init process 2");
    print('Responde: ${IndieService.addCortesia.getURL()}');
    print('Responde: ${IndieService.addCortesia.getSoapAction()}');
    final response =
    await http.post(Uri.parse( IndieService.addCortesia.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.addCortesia.getSoapAction(),
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
        String element = document.findAllElements("addCortesiaResponse").first.text;
        String? res = "0";
        if (element == ""){
          res = "0";
        }
        else{
          String res = document.findAllElements("addCortesiaResponse").first.text;
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

  void eventAddCortesia() {

    bool banTexto = false;
    var json_send = [];
    int i = 0;
    var data = jsonEncode(json_cortesia_options);
    //print(jsoncortesia[0]);
    for(Map<String,dynamic> object in json_cortesia_options){
      TextEditingController data = _controllers[i];
      if(data.text != '' && data.text != '0'&& data.text != null){
        json_send.add(
            {
              '"service"': '"${object['SERVICE']}"',
              '"cantidad"': data.text
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
    //_displayTextInputDialog(context);
    _MenuOptionsPay(json_send);
  }

  Future<SimpleDialog> _MenuOptionsPay(var json_send) async{



    return await showDialog(
        context: context,
        builder: (context){
          return  SimpleDialog(
            title: Text("¿Que desear usar?"),
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

                  var arrayUser = getString(cameraScanResult!);
                  setState(() {
                    if(arrayUser == null){

                      _codeV = '';
                      _code ='';
                      _banco = "0";
                    }
                    else{
                      _banco = "2";

                      _codeV = arrayUser[0];
                      _code = arrayUser[1];

                      //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto+propina, propina: propina, inventario: (!banInventario).toString(), modePayment: 1, banco: 1, referencia: "",),));
                      fetchAddCortesia(_codeV, _code, json_send).then((value) {
                        print('Res Login: $value');
                        switch(value['rcode']){
                          case -1:
                            Tools().showMessageBox(context,value['msg']);
                            break;
                          case 0:


                            Tools().showMessageBox(context,'Cortesia agregada correctamente');
                            break;
                          case 1:
                            setState(() {

                              Tools().showMessageBox(context,'Error al agregar la cortesia: ${value['msg']}');
                            });
                            break;
                          default:

                            Tools().showMessageBox(context,'Error al agregar la cortesia[1]');
                            break;
                        }
                      });
                    }
                  });
                },
                child: Text("QR"),
              ),
              SimpleDialogOption(
                onPressed: () async {
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
                          _codeV = "";
                          _code = "";
                          _banco = "0";
                        }
                        else{
                          _banco = "2";
                          _codeV = arrayUser[0];
                          _code = arrayUser[1];

                          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto+propina, propina: propina, inventario: (!banInventario).toString(), modePayment: 1,banco: 2, referencia: ""),));
                          fetchAddCortesia(_codeV, _code, json_send).then((value) {
                            print('Res Login: $value');
                            switch(value['rcode']){
                              case -1:
                                Tools().showMessageBox(context,value['msg']);
                                break;
                              case 0:


                                Tools().showMessageBox(context,'Cortesia agregada correctamente');
                                break;
                              case 1:
                                setState(() {

                                  Tools().showMessageBox(context,'Error al agregar la cortesia: ${value['msg']}');
                                });
                                break;
                              default:

                                Tools().showMessageBox(context,'Error al agregar la cortesia[1]');
                                break;
                            }
                          });
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
                child: Text("pulsera"),
              ),
            ],
          );
        }
    );
  }

}
