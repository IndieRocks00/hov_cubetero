import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:indierocks_cubetero/Utils/Encriptacion.dart';
import 'package:indierocks_cubetero/Utils/Tools.dart';
import 'package:indierocks_cubetero/core/env/Enviroments.dart';
import 'package:indierocks_cubetero/data/datasources/remote/repositories/remote_repository.dart';
import 'package:indierocks_cubetero/data/models/cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/result_cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/domain/entities/result_api.dart';
import 'package:indierocks_cubetero/domain/entities/user.dart';
import 'package:indierocks_cubetero/data/datasources/helper/Failure.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class HttpDataSource implements IRemoteDataSource{

  HttpDataSource({
    required Client client,
    required String keyAccess,
    required String url
  }) : assert(url != null) ,
        assert(keyAccess != null) ,
        assert(client != null) ,
        _url = url,
        _client = client,
        _keyAccess = keyAccess;

  final String _url;
  final String _keyAccess;
  final Client _client;

  @override
  Future<ResApiModel> doLogin(String version_encripted,String user_encripted) async {
      String url_base = '$_url/wsIRC/wsCL.asmx';
      try{
        print('Inicio de sesion api');
        print(url_base) ;
        /*PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String ver = packageInfo.version;

        String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
        String codigo = Encriptacion().encryptDataE("${user}|${pass}", Encriptacion.keyVersion);*/

        //return ResApiModel(rcode: 0,message: 'ok');

        String soap = '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <ilg xmlns="http://tempuri.org/">
              <k>$_keyAccess</k>
              <codigoV>$version_encripted</codigoV>
              <codigo>$user_encripted</codigo>
            </ilg>
          </soap:Body>
        </soap:Envelope>''';
        //print(soap);
        //Client c = http.Client();
        final response = await _client.post(
          Uri.parse(url_base),
          headers: {
            'content-type': 'text/xml',
            'SOAPAction': IndieService.ilg.getSoapAction(),
          },
          body: utf8.encode(soap),
        ).timeout(
            const Duration(
                seconds: 30
            )
        );

        print(response.body) ;
        print(url_base) ;
        if(response.statusCode == 200 ){

          XmlDocument document = XmlDocument.parse(response.body);
          String res = document.findAllElements("ilgResponse").first.text;
          var json_res = jsonDecode(res);
          print(json_res) ;
          return ResApiModel.fromMap(json_res);
        }else {
          throw Failure(response.statusCode,response.reasonPhrase!);
        }
      }on SocketException catch (_) {
        throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
      } on TimeoutException catch (_) {
        throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
      } on http.ClientException catch (e) {
        throw Failure(FailureStatus.exception, e.message);
      } catch(e){
        if(e is Failure){
          throw Failure(e.statusCode,e.toString());
        }
        else{
          //print('http Exception');
          throw Failure(FailureStatus.exception,e.toString());
        }
      }
  }

  @override
  Future<ResApiModel> payment(String code_version_encripted,String code_client_encripted,String code_user_encripted,int amount, int banco,String reference) async {
    String url_base = '$_url/wsIRC/wsCL.asmx';
    try{
      //return ResApiModel(rcode:0,message: 'Abono realizado correctamente');
      //PackageInfo packageInfo = await PackageInfo.fromPlatform();
      //String ver = packageInfo.version;

      //String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
      String soap = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <payment xmlns="http://tempuri.org/">
          <k>$_keyAccess</k>
          <codigoV>$code_version_encripted</codigoV>
          <codigo>$code_client_encripted</codigo>
          <codigoC>$code_user_encripted</codigoC>
          <amount>$amount</amount>
          <banco>$banco</banco>
          <reference>$reference</reference>
        </payment>
      </soap:Body>
    </soap:Envelope>''';

      print(soap) ;
      //Client c = http.Client();
      final response = await _client.post(Uri.parse(url_base),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.venta.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).timeout(
          const Duration(
              seconds: 30
          )
      );
      if(response.statusCode == 200 ){

        XmlDocument document = XmlDocument.parse(response.body);
        String res = document.findAllElements("paymentResponse").first.text;
        print(res) ;
        var json_res = jsonDecode(res);
        print(json_res) ;
        switch(json_res['rcode']){
          case 0:
            //var msgDesc = Encriptacion().decryptDataD(json_res['msg']!, Encriptacion.keyVersion);
            //var msgArr = msgDesc.split('|');
            //String nameUser = msgArr[0];
            //String balance = msgArr[1];
            /*DataBaseHelper.saveLogin(LoginModel( user, pass, balance, nameUser)).then((value) {

                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PrincipalActivity()));
              },);*/
            return ResApiModel(rcode: 0,message: json_res['msg']);

          case 1:
            throw Failure(1,json_res['msg']);
          default:

            throw Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error));
        }
      }else {
        throw Failure(response.statusCode,response.reasonPhrase!);
      }
    }on SocketException catch (_) {
      throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
    } on TimeoutException catch (_) {
      throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
    } on http.ClientException catch (e) {
      throw Failure(FailureStatus.exception, e.message);
    } catch(e){
      if(e is Failure){
        throw Failure(e.statusCode,e.toString());
      }
      else{
        throw Failure(FailureStatus.exception,e.toString());
      }
    }
  }

  @override
  Future<ResApiModel> detailBalance(String code_version_encripted, String code_client_encripted, String code_user_encripted) async{
    String url_base = '$_url/wsIRC/wsCL.asmx';
    try{
      //return ResApiModel(rcode:1,message: 'Error al consultar balance');
      //PackageInfo packageInfo = await PackageInfo.fromPlatform();
      //String ver = packageInfo.version;
      print('Entro al detalle de balance');
      //String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);

      String soap = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <detailB xmlns="http://tempuri.org/">
            <k>$_keyAccess</k>
            <codigoV>$code_version_encripted</codigoV>
            <codigo>$code_client_encripted</codigo>
          </detailB>
        </soap:Body>
      </soap:Envelope>''';

      print(soap) ;
      //Client c = http.Client();
      final response = await _client.post(Uri.parse(url_base),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.balance.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).timeout(
          const Duration(
              seconds: 30
          )
      );
      if(response.statusCode == 200 ){

        XmlDocument document = XmlDocument.parse(response.body);
        String res = document.findAllElements("detailBResponse").first.text;
        print(res) ;
        var json_res = jsonDecode(res);
        print(json_res) ;
        switch(json_res['rcode']){
          case 0:
            //var msgDesc = Encriptacion().decryptDataD(json_res['msg']!, Encriptacion.keyVersion);
            //var msgArr = msgDesc.split('|');
            //String nameUser = msgArr[0];
            //String balance = msgArr[1];
            return ResApiModel(rcode: 0,message: json_res['msg']);

          case 1:
            throw Failure(1,'Sin información disponible');
          default:

            throw Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error));
        }
      }else {
        throw Failure(response.statusCode,response.reasonPhrase!);
      }
    }on SocketException catch (_) {
      throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
    } on TimeoutException catch (_) {
      throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
    } on http.ClientException catch (e) {
      throw Failure(FailureStatus.exception, e.message);
    } catch(e){
      if(e is Failure){
        throw Failure(e.statusCode,e.toString());
      }
      else{
        throw Failure(FailureStatus.exception,e.toString());
      }
    }
  }

  @override
  Future<ResultCortesiaModel> getCortesiaClient(String code_version_encripted, String code_client_encripted, String code_user_encripted) async {
    String url_base = '$_url/wsIRC/wsCL.asmx';
    try{
      //return ResApiModel(rcode:1,message: 'Error al consultar balance');
      //PackageInfo packageInfo = await PackageInfo.fromPlatform();
      //String ver = packageInfo.version;
      print('Entro al detalle de balance');
      //String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);

      String soap =  '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <getCortesia xmlns="http://tempuri.org/">
          <k>$_keyAccess</k>
          <codigoV>$code_version_encripted</codigoV>
          <codigo>$code_client_encripted</codigo>
          <codigoC>$code_user_encripted</codigoC>
        </getCortesia>
      </soap:Body>
    </soap:Envelope>''';

      print(soap) ;
      //Client c = http.Client();
      final response = await _client.post(Uri.parse(url_base),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.getCortesia.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).timeout(
          const Duration(
              seconds: 30
          )
      );
      if(response.statusCode == 200 ){

        XmlDocument document = XmlDocument.parse(response.body);
        String res = document.findAllElements("getCortesiaResponse").first.text;
        print(res) ;
        var json_res = jsonDecode(res);
        print('Res Api HTTP: ${json_res}') ;
        switch(json_res['rcode']){
          case 0:
          //var msgDesc = Encriptacion().decryptDataD(json_res['msg']!, Encriptacion.keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            return ResultCortesiaModel.fromMap(json_res);

          case 1:

            throw Failure(1,'No se pudo obtener información de las cortesias disponibles.');
          default:

            throw Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error));
        }
      }else {
        throw Failure(response.statusCode,response.reasonPhrase!);
      }
    }on SocketException catch (_) {
      throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
    } on TimeoutException catch (_) {
      throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
    } on http.ClientException catch (e) {
      throw Failure(FailureStatus.exception, e.message);
    } catch(e){
      if(e is Failure){
        throw Failure(e.statusCode,e.toString());
      }
      else{
        throw Failure(FailureStatus.exception,e.toString());
      }
    }
  }

  @override
  Future<List<ProductoModel>> getProductos(String code_version_encripted, String code_user_encripted) async{
    String url_base = '$_url/wsIRC/wsCL.asmx';
    try{
      //Future.delayed(Duration(seconds: 5));
      print('Entro al obtenecion de productos');

      String soap = '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <getSKU xmlns="http://tempuri.org/">
              <k>$_keyAccess</k>
              <codigoV>$code_version_encripted</codigoV>
              <codigo>$code_user_encripted</codigo>
              <general_data>true</general_data>
            </getSKU>
          </soap:Body>
        </soap:Envelope>''';

      print(soap) ;
      //Client c = http.Client();
      final response = await _client.post(Uri.parse(url_base),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.getSKU.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).timeout(
          const Duration(
              seconds: 30
          )
      );
      if(response.statusCode == 200 ){

        XmlDocument document = XmlDocument.parse(response.body);
        String res = document.findAllElements("getSKUResult").first.text;
        print(res) ;
        var json_res = jsonDecode(res);
        print('Res Api get productos HTTP: ${json_res}') ;
        switch(json_res['rcode']){
          case 0:
          //var msgDesc = Encriptacion().decryptDataD(json_res['msg']!, Encriptacion.keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            List<dynamic> msgList = jsonDecode(json_res['msg']);
            return msgList.map(
                  (item) => ProductoModel.fromJson(item),
            ).toList();

          case 1:
            return [];
          default:

            throw Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error));
        }
      }else {
        throw Failure(response.statusCode,response.reasonPhrase!);
      }
    }on SocketException catch (_) {
      throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
    } on TimeoutException catch (_) {
      throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
    } on http.ClientException catch (e) {
      throw Failure(FailureStatus.exception, e.message);
    } catch(e){
      if(e is Failure){
        throw Failure(e.statusCode,e.toString());
      }
      else{
        throw Failure(FailureStatus.exception,e.toString());
      }
    }
  }

  @override
  Future<ResApiModel> sellV2(String code_version_encripted, String code_client_encripted, String code_user_encripted, String code_product_encripted, int total, int banco) async{

    String url_base = '$_url/wsIRC/wsCL.asmx';
    try{
      //Future.delayed(Duration(seconds: 5));
      print('Entro al obtenecion de productos');


      String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <sellV2Cortesia xmlns="http://tempuri.org/">
          <k>$_keyAccess</k>
          <codigoV>$code_version_encripted</codigoV>
          <codigo>$code_client_encripted</codigo>
          <codigoC>$code_user_encripted</codigoC>
          <codigoP>$code_product_encripted</codigoP>
          <propina>0</propina>
          <total>$total</total>
          <banco>$banco</banco>
          <inventario>true</inventario>
        </sellV2Cortesia>
      </soap:Body>
    </soap:Envelope>''';

      print(soap) ;
      //Client c = http.Client();
      final response = await _client.post(Uri.parse(url_base),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.sellV2Cortesia.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).timeout(
          const Duration(
              seconds: 30
          )
      );
      if(response.statusCode == 200 ){

        XmlDocument document = XmlDocument.parse(response.body);
        String res = document.findAllElements("sellV2CortesiaResponse").first.text;
        print(res) ;
        var json_res = jsonDecode(res);
        print('Res Api sellv2 HTTP: ${json_res}') ;


        //return ResApiModel.fromMap(json_res);

        switch(json_res['rcode']){
          case 0:
          //var msgDesc = Encriptacion().decryptDataD(json_res['msg']!, Encriptacion.keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];
            return ResApiModel(rcode: 0, message: json_res['msg']);

          case 1:
            if(json_res['msg'] == null || json_res['msg'] == 'null'){

              return ResApiModel(rcode: 1, message: 'No se pudo procesar la venta.');
            }
            return ResApiModel(rcode: 1, message: json_res['msg']);
          default:

            throw Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error));
        }
      }else {
        throw Failure(response.statusCode,response.reasonPhrase!);
      }
    }on SocketException catch (_) {
      throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
    } on TimeoutException catch (_) {
      throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
    } on http.ClientException catch (e) {
      throw Failure(FailureStatus.exception, e.message);
    } catch(e){
      if(e is Failure){
        throw Failure(e.statusCode,e.toString());
      }
      else{
        throw Failure(FailureStatus.exception,e.toString());
      }
    }
  }

  @override
  Future<List<CortesiaModel>> getOptionsCortesia(String code_version_encripted, String code_user_encripted) async {
    String url_base = '$_url/wsIRC/wsCL.asmx';
    try{
      //Future.delayed(Duration(seconds: 5));
      print('Entro al obtenecion de opciones');


      String soap = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <getOptionsCortesia xmlns="http://tempuri.org/">
            <k>$_keyAccess</k>
            <codigoV>$code_version_encripted</codigoV>
            <codigoC>$code_user_encripted</codigoC>
          </getOptionsCortesia>
        </soap:Body>
      </soap:Envelope>''';

      print(soap) ;
      //Client c = http.Client();
      final response = await _client.post(Uri.parse(url_base),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.getOptionsCortesia.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).timeout(
          const Duration(
              seconds: 30
          )
      );
      if(response.statusCode == 200 ){

        XmlDocument document = XmlDocument.parse(response.body);
        String res = document.findAllElements("getOptionsCortesiaResponse").first.text;
        print(res) ;
        var json_res = jsonDecode(res);
        print('Res Api get options HTTP: ${json_res}') ;
        switch(json_res['rcode']){
          case 0:
          //var msgDesc = Encriptacion().decryptDataD(json_res['msg']!, Encriptacion.keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            List<dynamic> msgList = jsonDecode(json_res['msg']);
            return msgList.map(
                  (item) => CortesiaModel.fromJson(item),
            ).toList();

          case 1:

            return [];
          default:

            throw Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error));
        }
      }else {
        throw Failure(response.statusCode,response.reasonPhrase!);
      }
    }on SocketException catch (_) {
      throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
    } on TimeoutException catch (_) {
      throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
    } on http.ClientException catch (e) {
      throw Failure(FailureStatus.exception, e.message);
    } catch(e){
      if(e is Failure){
        throw Failure(e.statusCode,e.toString());
      }
      else{
        throw Failure(FailureStatus.exception,e.toString());
      }
    }
  }

  @override
  Future<ResApiModel> addCortesia(String code_version_encripted, String code_client_encripted, String code_user_encripted, String code_cortesia_encripted) async{
    String url_base = '$_url/wsIRC/wsCL.asmx';
    try{
      //Future.delayed(Duration(seconds: 5));
      print('Entro al obtenecion de productos');
      String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <addCortesia xmlns="http://tempuri.org/">
          <k>$_keyAccess</k>
          <codigoV>$code_version_encripted</codigoV>
          <codigo>$code_client_encripted</codigo>
          <codigoC>$code_user_encripted</codigoC>
          <codigoCortesias>$code_cortesia_encripted</codigoCortesias>
        </addCortesia>
      </soap:Body>
    </soap:Envelope>''';

      print(soap) ;
      //Client c = http.Client();
      final response = await _client.post(Uri.parse(url_base),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.addCortesia.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).timeout(
          const Duration(
              seconds: 30
          )
      );
      if(response.statusCode == 200 ){

        XmlDocument document = XmlDocument.parse(response.body);
        String res = document.findAllElements("addCortesiaResponse").first.text;
        print(res) ;
        var json_res = jsonDecode(res);
        print('Res Api addcortesia HTTP: ${json_res}') ;


        //return ResApiModel.fromMap(json_res);

        switch(json_res['rcode']){
          case 0:
          //var msgDesc = Encriptacion().decryptDataD(json_res['msg']!, Encriptacion.keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];
            return ResApiModel(rcode: 0, message: 'Costesia agregada.');

          case 1:
            return ResApiModel(rcode: 1, message: 'Error al agregar cortesia');
          default:

            throw Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error));
        }
      }else {
        throw Failure(response.statusCode,response.reasonPhrase!);
      }
    }on SocketException catch (_) {
      throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
    } on TimeoutException catch (_) {
      throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
    } on http.ClientException catch (e) {
      throw Failure(FailureStatus.exception, e.message);
    } catch(e){
      if(e is Failure){
        throw Failure(e.statusCode,e.toString());
      }
      else{
        throw Failure(FailureStatus.exception,e.toString());
      }
    }
  }

  @override
  Future<ResApiModel> removeCortesia(String code_version_encripted, String code_client_encripted, String code_user_encripted) async{
    String url_base = '$_url/wsIRC/wsCL.asmx';
    try{
      //Future.delayed(Duration(seconds: 5));
      print('Entro al obtenecion de productos');

      print(code_version_encripted);
      String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <removeCortesia xmlns="http://tempuri.org/">
          <k>$_keyAccess</k>
          <codigoV>$code_version_encripted</codigoV>
          <codigo>$code_client_encripted</codigo>
          <codigoC>$code_user_encripted</codigoC>
        </removeCortesia>
      </soap:Body>
    </soap:Envelope>''';

      print(soap) ;
      //Client c = http.Client();
      final response = await _client.post(Uri.parse(url_base),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.removeCortesia.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).timeout(
          const Duration(
              seconds: 30
          )
      );
      if(response.statusCode == 200 ){

        XmlDocument document = XmlDocument.parse(response.body);
        String res = document.findAllElements("removeCortesiaResponse").first.text;
        print(res) ;
        var json_res = jsonDecode(res);
        print('Res Api sellv2 HTTP: ${json_res}') ;


        //return ResApiModel.fromMap(json_res);

        switch(json_res['rcode']){
          case 0:
          //var msgDesc = Encriptacion().decryptDataD(json_res['msg']!, Encriptacion.keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];
            return ResApiModel(rcode: 0, message: 'Costesia removida.');

          case 1:
            return ResApiModel(rcode: 1, message: 'Error al remover cortesia');
          default:

            throw Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error));
        }
      }else {
        throw Failure(response.statusCode,response.reasonPhrase!);
      }
    }on SocketException catch (_) {
      throw Failure(FailureStatus.not_connection_internet, FailureStatus.getMessage(FailureStatus.not_connection_internet));
    } on TimeoutException catch (_) {
      throw Failure(FailureStatus.timeout, FailureStatus.getMessage(FailureStatus.timeout));
    } on http.ClientException catch (e) {
      throw Failure(FailureStatus.exception, e.message);
    } catch(e){
      if(e is Failure){
        throw Failure(e.statusCode,e.toString());
      }
      else{
        throw Failure(FailureStatus.exception,e.toString());
      }
    }

  }





}