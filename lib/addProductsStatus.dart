import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/AddProductos.dart';
import 'package:indierocks_cubetero/Orders.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/Tools.dart';

class addProductsStatus extends StatefulWidget {
  final String codigoP;
  final String referencia;
  const addProductsStatus({Key? key, required this.referencia, required this.codigoP}) : super(key: key);

  @override
  State<addProductsStatus> createState() => _addProductsStatusState(this.codigoP, this.referencia);
}

class _addProductsStatusState extends State<addProductsStatus> {

  var codigoP;
  var referencia;

  var _msg_res = "";

  _addProductsStatusState(this.codigoP, this.referencia);

  @override
  void initState() {

    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {

      eventAddProductos().then((value) {

        print('Res Login: $value');
        switch(value['rcode']){
          case -1:
            Tools().showMessageBox(context,value['msg']);
            break;
          case 0:


            var js = jsonEncode(value['msg']);
            if(js == null){

              setState(() {
                _msg_res = "Los producots han sido agregados correctamente";
              });
              return;
            }

            break;
          case 1:
            setState(() {

              _msg_res = "Error al realizar la venta. ${value['msg']}";
            });
            break;
          default:

            setState(() {

              _msg_res = "Error al realizar la venta[1]. ${value['msg']}";
            });
            //Tools().showMessageBox(context,'Error al realizar la venta[1]');
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
                  child: Image.asset("assets/images/foroirblack.png",
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
                    _msg_res,
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
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => OrderActivity(),), (route) => false);

  }

  Future<Map<String,dynamic>> eventAddProductos() async {
    var today = DateTime.now();
    var formatter = DateFormat("yyyyMMddHHmmss");
    String key = IndieService.keyIndie.getURL();



    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    print(this.codigoP);
    var jsonEncriptCarrito = Encriptacion().encryptDataE(codigoP, Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <addProdcuctsOrderPay xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigoC</codigo>
          <codigoC>$codigoC</codigoC>
          <codigoP>$jsonEncriptCarrito</codigoP>
          <order>$referencia</order>
        </addProdcuctsOrderPay>
      </soap:Body>
    </soap:Envelope>''';

    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    final response =
    await http.post(Uri.parse( IndieService.addProdcuctsOrderPay.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.addProdcuctsOrderPay.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("addProdcuctsOrderPayResponse").first.text;
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
