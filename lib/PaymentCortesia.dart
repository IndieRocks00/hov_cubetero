import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/CortesiaCliente.dart';
import 'package:indierocks_cubetero/Principal.dart';
import 'package:indierocks_cubetero/PuntoVenta.dart';
import 'package:indierocks_cubetero/Utils/Encriptacion.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:xml/xml.dart';

import 'Utils/DataBaseHelper.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/Tools.dart';
import 'package:http/http.dart' as http;

class PaymentCortesia extends StatefulWidget {

  final String codigo ;
  final String codigoV;
  final String codigoP;
  final String codigoPCosrtesia;
  final double monto;
  final double propina;
  final String inventario;
  final int modePayment;
  final int banco;
  final String referencia;
  PaymentCortesia({Key? key,required this.codigo, required this.codigoV, required this.codigoP,required this.codigoPCosrtesia,required this.monto, required this.propina, required this.inventario, required this.modePayment, required this.banco, required this.referencia}) : super(key: key);

  @override
  State<PaymentCortesia> createState() => _PaymentCortesiaState(codigo, codigoV, codigoP, codigoPCosrtesia, monto, propina, inventario, modePayment, banco, referencia);
}

class _PaymentCortesiaState extends State<PaymentCortesia> {
  var _codigoV;
  var _codigo;
  var _codigoP;
  var _codigoPCortesia;
  var _banco;
  var _inventario;
  var _monto;
  var _propina;
  var _msg_res = "";
  var _referencia;
  var banPay = false;
  var version_code = "";
  var modePayment = 1;

  var banError = false;
  var banQR = false;
  var dataQR = "";

  var jsonOK = [];

  var user = "";
  var pass = "";


  _PaymentCortesiaState(this._codigo, this._codigoV, this._codigoP,this._codigoPCortesia, this._monto, this._propina, this._inventario, this.modePayment, this._banco, this._referencia);


  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      print('Codigo P : $modePayment');

      modePayment ==1?

      eventPagar():

      eventPagarPV();

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child:
            Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 35, left: 20, bottom: 10),
                  color: ColorsIndie.colorGC1.getColor(),
                  child: const Text("CUBETERO",
                    style: TextStyle(color: Colors.white,
                        fontSize: 20),
                  ),
                ),
                Center(
                  child: Image.asset("assets/images/foro_ir_white.png",
                    width: MediaQuery.of(context).size.width-100,
                    height: 200,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 40, right: 20),
                  width: MediaQuery.of(context).size.width,
                  child: const Text(
                    "Hola",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                /*Container(
                  margin: const EdgeInsets.only(left: 40, right: 20),
                  width: MediaQuery.of(context).size.width,
                  child:  Text(
                    _name,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 40),
                  ),
                ),*/
                Container(
                  margin: const EdgeInsets.only(left: 40, right: 20, top: 20),
                  width: MediaQuery.of(context).size.width,
                  child: const Text(
                    "El total de su pago es: ",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 40, right: 20,),
                  width: MediaQuery.of(context).size.width,
                  child:  Text(
                    '\$$_monto',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  margin: const EdgeInsets.only(left: 40, right: 20,),
                  width: MediaQuery.of(context).size.width,
                  child:  Text(
                    _msg_res ,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                /*banPay? SizedBox(height: 0,): Container(
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  margin: const EdgeInsets.only(left: 40,right: 40, top: 50),
                  decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 5)
                        )
                      ]
                  ),
                  child: ElevatedButton(onPressed: (){
                    eventPagar();
                  },
                    style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(color: ColorsIndie.colorGC2.getColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                        primary: ColorsIndie.colorGC1.getColor(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )
                    ),
                    child: const Text("Pagar"),
                  ),

                ),*/
                banQR? SizedBox(height: 0,):
                Container(
                  alignment: Alignment.center,
                  child: QrImage(data: _codigo,
                    size: MediaQuery.of(context).size.width/2,
                  ),
                ),
                banPay? SizedBox(height: 0,):
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: jsonOK == null ? 0 : jsonOK.length,

                  itemBuilder: (context, index) {
                    return  Card(
                      child:  Text('${jsonOK[index]["producto"]} - ${jsonOK[index]["monto"]} - ${jsonOK[index]["estatus"]}',
                        style: TextStyle(fontSize: 16),),
                    );
                  },),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 55,
                  margin: const EdgeInsets.only(left: 40,right: 40, top: 10),
                  decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(0, 5)
                        )
                      ]
                  ),
                  child: ElevatedButton(onPressed: (){
                    eventContinuar();
                  },
                    style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(color: ColorsIndie.colorGC2.getColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                        primary: ColorsIndie.colorGC1.getColor(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )
                    ),
                    child: const Text("Continuar"),
                  ),

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void eventContinuar() {
    modePayment ==1?
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PCortesia(),), (route) => false)
        :
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PCortesia(),), (route) => false);

  }

  void eventPagar() {

    fetchPayment().then((value) {

      print('Res Login: $value');
      switch(value['rcode']){
        case -1:
          Tools().showMessageBox(context,value['msg']);
          break;
        case 0:
          setState(() {

            banPay = false;
            banQR = true;
            _msg_res = "Cortesia entregada";
          });
          break;
        case 1:
          setState(() {

            banPay = false;
            banQR = true;
            _msg_res = "Error al realizar la venta. ${value['msg']}";
          });
          break;
        default:

          setState(() {

            banPay = false;
            banQR = true;
          });
          Tools().showMessageBox(context,'Error al realizar la venta[1]');
          break;
      }
    });

  }


  void eventPagarPV() {

    fetchPaymentPV().then((value) {

      print('Res Login: $value');
      switch(value['rcode']){
        case -1:
          Tools().showMessageBox(context,value['msg']);
          break;
        case 0:


          var js = jsonEncode(value['msg']);
          if(js == null){

            setState(() {
              banPay = true;
              banQR = false;
              _msg_res = "Venta realizada correctamente";
            });
            return;
          }
          var list = jsonDecode(value['msg']);
          print(list);
          var jsonError = [];
          jsonOK = [];
          list.forEach((element) {
            print(element.toString());
            setState(() {

              jsonOK.add(element);
            });
            if(element['estatus'] != 'EXITO'){
              setState(() {
                banError = true;
                jsonError.add(element);
              });
            }
          });
          print('Error: $jsonError');
          //print(jsonOK);
          //var jsError = jsonDecode( jsonError);

          if(!banError){


            setState(() {
              banPay = true;
              banQR = false;
              _msg_res = "Venta realizada correctamente";
            });
          }
          else{

            setState(() {

              banPay = false;
              _msg_res = "Error al cobrar productos. La siguiente lista no se pudo cobrar.";
            });
          }
          break;
        case 1:
          setState(() {

            banPay = false;
            banQR = true;
            _msg_res = "Error al realizar la venta. ${value['msg']}";
          });
          break;
        default:

          setState(() {

            banPay = false;
            banQR = true;
          });
          Tools().showMessageBox(context,'Error al realizar la venta[1]');
          break;
      }
      /*
      if(value.toString().isEmpty || value.toString() == ""){
        Tools().showMessageBox(context, "No se pudo procesar el pago. Intentalo mas tarde.");
        return;
      }
      if (value == "true"){
        //Tools().showMessageBox(context, 'El pago ha sido realizado.');
        banPay = true;
        setState(() {

          _msg_res = "Venta realizada correctamente";
        });
        return;
      }
      else {
        //Tools().showMessageBox(context, 'No se pudo realizar el pago.');
        banPay = false;
        setState(() {

          _msg_res = "Error al realizar la venta";
        });
        return;
      }*/
    });

  }


  Future<void> getVersionApp() async{

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version_code = Encriptacion().encryptDataE(packageInfo.version, Encriptacion.keyIdVer);
    print(version_code);
  }

  Future<Map<String,dynamic>>  fetchBalance() async {


    print("Init Balance");
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <detailB xmlns="http://tempuri.org/">
            <k>${Tools.keyIndie}</k>
            <codigoV>$_codigoV</codigoV>
            <codigo>$_codigo</codigo>
          </detailB>
        </soap:Body>
      </soap:Envelope>''';

    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
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


  Future<Map<String,dynamic>> fetchPayment() async {
    var today = DateTime.now();
    var formatter = DateFormat("yyyyMMddHHmmss");
    String key = IndieService.keyIndie.getURL();
    var mo = _monto.toString().toString();
    print(_codigoP);

    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);


    var jsonEncriptCarrito = Encriptacion().encryptDataE(_codigoP, Encriptacion.keyVersion);
    var jsonEncriptCarritoCortesia = Encriptacion().encryptDataE(_codigoPCortesia, Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <sellCortesia xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$_codigoV</codigoV>
          <codigo>$_codigo</codigo>
          <codigoC>$codigoC</codigoC>
          <codigoP>$jsonEncriptCarrito</codigoP>
          <codigoPCortesia>$jsonEncriptCarritoCortesia</codigoPCortesia>
          <propina>$_propina</propina>
          <total>$mo</total>
          <banco>1</banco>
          <inventario>$_inventario</inventario>
        </sellCortesia>
      </soap:Body>
    </soap:Envelope>''';
    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    final response =
    await http.post(Uri.parse( IndieService.sellCortesia.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.sellCortesia.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("sellCortesiaResponse").first.text;
        print(jsonDecode(res));
        return jsonDecode(res);
      } else {
        print("Error al realizar la solicitud");

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


  Future<Map<String,dynamic>> fetchPaymentPV() async {
    var today = DateTime.now();
    var formatter = DateFormat("yyyyMMddHHmmss");
    String key = IndieService.keyIndie.getURL();
    var mo = _monto.toString().toString();
    print(_codigoP);

    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);


    var jsonEncriptCarrito = Encriptacion().encryptDataE(_codigoP, Encriptacion.keyVersion);
    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <sellPV xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigo</codigo>
          <codigoC>$codigoC</codigoC>
          <codigoP>$jsonEncriptCarrito</codigoP>
          <propina>$_propina</propina>
          <total>$mo</total>
          <banco>$_banco</banco>
          <inventario>$_inventario</inventario>
          <referencia>$_referencia</referencia>
        </sellPV>
      </soap:Body>
    </soap:Envelope>''';
    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    final response =
    await http.post(Uri.parse( IndieService.sellPV.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.sellPV.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("sellPVResponse").first.text;
        print(jsonDecode(res));
        return jsonDecode(res);
      } else {
        print("Error al realizar la solicitud");

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