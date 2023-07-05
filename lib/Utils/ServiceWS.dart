import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';

import 'DataBaseHelper.dart';
import 'Encriptacion.dart';
import 'ProgressDialog.dart';
import 'Tools.dart';
import 'package:http/http.dart' as http;


class ServiceWS{


  static Future<Map<String,dynamic>> fetchLogin(String _user, String _pass, BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("$_user|$_pass", Encriptacion.keyVersion);


    String soap = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <ilg xmlns="http://tempuri.org/">
            <k>${Tools.keyIndie}</k>
            <codigoV>$codigoV</codigoV>
            <codigo>$codigo</codigo>
          </ilg>
        </soap:Body>
      </soap:Envelope>''';
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });


    var resApi = null;
    try{
      final response =
      await http.post(Uri.parse( IndieService.ilg.getURL()),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.ilg.getSoapAction(),
        },
        body: utf8.encode(soap),
      )
          /*.timeout(const Duration(seconds: 30))*/
          .then((response) {
        print('Responde: $response');
        Navigator.pop(context);
        if (response.statusCode == 200) {
          // Si la llamada al servidor fue exitosa, analiza el JSON
          print(response.body);
          XmlDocument document = XmlDocument.parse(response.body);
          String res = document.findAllElements("ilgResponse").first.text;
          print(res);
          resApi= jsonDecode(res);

        } else {
          // Si esta respuesta no fue OK, lanza un error.
          //throw Exception('Failed to load post');
          //showMessageBox(context, "Error al procesar la solicitud");
          print("Error al realizar la solicitud");

          resApi = {
            'rcode':-1,
            'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde.'
          };

          //return resError;
        }

      }, onError:(error) {
        print('Error: $error');
        Navigator.pop(context);
        resApi = {
          'rcode':-1,
          'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$error]'
        };

      });
    }
    catch( e){

      //Navigator.pop(context);
      resApi= {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$e]'
      };
    }


    //print(response);
    return resApi;

  }



  static Future<Map<String,dynamic>> fetchPaymentTerminal(String _monto, String _codigoP, bool _inventario, BuildContext context) async {
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
    <getTerminalPayment xmlns="http://tempuri.org/">
      <k>${Tools.keyIndie}</k>
      <codigoV>$codigoV</codigoV>
      <codigo>$codigo</codigo>
      <codigoC>$codigoC</codigoC>
      <codigoP>$jsonEncriptCarrito</codigoP>
      <total>$mo</total>
      <banco>6</banco>
      <propina>0</propina>
      <inventario>$_inventario</inventario>
      <referencia></referencia>
    </getTerminalPayment>
  </soap:Body>
</soap:Envelope>''';
    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    var resApi = null;
    final response =
    await http.post(Uri.parse( IndieService.getTerminalPayment.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.getTerminalPayment.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("getTerminalPaymentResponse").first.text;
        print(jsonDecode(res));
        resApi= jsonDecode(res);
      } else {
        print("Error al realizar la solicitud");

        resApi = {
          'rcode':-1,
          'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde.'
        };

      }
    }, onError:(error) {
      print('Error: $error');
      Navigator.pop(context);
      resApi = {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$error]'
      };

    });
    print(response);
    return resApi;


  }

  static Future<Map<String,dynamic>> fetchApplyPaymentTerminal(String _monto, String _codigoP, bool _inventario, BuildContext context) async {
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
    <getTerminalPayment xmlns="http://tempuri.org/">
      <k>${Tools.keyIndie}</k>
      <codigoV>$codigoV</codigoV>
      <codigo>$codigo</codigo>
      <codigoC>$codigoC</codigoC>
      <codigoP>$jsonEncriptCarrito</codigoP>
      <total>$mo</total>
      <banco>6</banco>
      <propina>0</propina>
      <inventario>$_inventario</inventario>
      <referencia></referencia>
    </getTerminalPayment>
  </soap:Body>
</soap:Envelope>''';
    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    var resApi = null;
    final response =
    await http.post(Uri.parse( IndieService.getTerminalPayment.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.getTerminalPayment.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("getTerminalPaymentResponse").first.text;
        print(jsonDecode(res));
        resApi= jsonDecode(res);
      } else {
        print("Error al realizar la solicitud");

        resApi = {
          'rcode':-1,
          'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde.'
        };

      }
    }, onError:(error) {
      print('Error: $error');
      Navigator.pop(context);
      resApi = {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$error]'
      };

    });
    print(response);
    return resApi;


  }

  static Future<Map<String,dynamic>> fetchValidateTerminal(String _monto, String _codigoP, bool _inventario,String reference, BuildContext context) async {
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
    <validatePaymentTerminal xmlns="http://tempuri.org/">
      <k>${Tools.keyIndie}</k>
      <codigoV>$codigoV</codigoV>
      <codigo>$codigo</codigo>
      <codigoC>$codigoC</codigoC>
      <codigoP>$jsonEncriptCarrito</codigoP>
      <total>$mo</total>
      <banco>6</banco>
      <propina>0</propina>
      <inventario>$_inventario</inventario>
      <referencia>$reference</referencia>
    </validatePaymentTerminal>
  </soap:Body>
</soap:Envelope>''';
    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    var resApi = null;
    final response =
    await http.post(Uri.parse( IndieService.validatePaymentTerminal.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.validatePaymentTerminal.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("validatePaymentTerminalResponse").first.text;
        print(jsonDecode(res));
        resApi =jsonDecode(res);
      } else {
        print("Error al realizar la solicitud");

        resApi= {
          'rcode':-1,
          'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde.'
        };

      }
    }, onError:(error) {
      print('Error: $error');
      Navigator.pop(context);
      resApi = {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$error]'
      };

    });
    print(response);
    return resApi;


  }

  static Future<Map<String,dynamic>> fetchCancelPaymentTerminal(String reference, BuildContext context) async {
    var today = DateTime.now();
    var formatter = DateFormat("yyyyMMddHHmmss");

    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);


    String soap = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <cancelTerminalPayment xmlns="http://tempuri.org/">
      <k>${Tools.keyIndie}</k>
      <codigoV>$codigoV</codigoV>
      <codigo>$codigo</codigo>
      <codigoC>$codigoC</codigoC>
      <referencia>$reference</referencia>
    </cancelTerminalPayment>
  </soap:Body>
</soap:Envelope>''';
    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    var resApi = null;
    final response =
    await http.post(Uri.parse( IndieService.cancelTerminalPayment.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.cancelTerminalPayment.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("cancelTerminalPaymentResponse").first.text;
        print(jsonDecode(res));
        resApi= jsonDecode(res);
      } else {
        print("Error al realizar la solicitud");

         resApi = {
          'rcode':-1,
          'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde.'
        };

      }
    }, onError:(error) {
      print('Error: $error');
      Navigator.pop(context);
      resApi = {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$error]'
      };

    });
    print(response);
    return resApi;


  }

}