import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/Principal.dart';
import 'package:indierocks_cubetero/Utils/UITools.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/Tools.dart';
import 'package:http/http.dart' as http;

import 'Utils/UITools.dart';
class TransactionsActivity extends StatefulWidget {
  const TransactionsActivity({Key? key}) : super(key: key);

  @override
  State<TransactionsActivity> createState() => _TransactionsActivityState();
}

class _TransactionsActivityState extends State<TransactionsActivity> {

  String user = "";
  String pass = "";
  String name = "";
  int cont = 1;

  var json_transact = [];

  String status_comanda = "";
  var json_order = [];
  var json_comanda = [];

  String text_title = "";
  var banOrder = false;
  var dialogS;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {


      setState(() {
        json_transact = [];
        var json_order = [];
        var json_comanda = [];
      });

      GetTransactions();

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CUBETERO"), backgroundColor: ColorsIndie.colorGC1.getColor()),
      backgroundColor: ColorsIndie.colorGC2.getColor(),
      body: RefreshIndicator(
        onRefresh: ()  async {
          GetTransactions();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20,),
                  Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: const Text( 'Ultimos pedidos',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  json_order.isEmpty? Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 100),
                    child:  Text('Sin registros por mostrar',
                      style: TextStyle(fontSize: 20),
                    ),
                  ):
                  ListView.builder(
                    itemCount: json_comanda == null ? 0 : json_comanda.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: (){
                          setState(() {

                            status_comanda = json_comanda[index]['Id_Status'].toString();
                          });
                          _displayProducts(context,json_comanda[index]['list_product'],json_comanda[index]['Referencia'],json_comanda[index]['Cliente'].toString(), MoneyFormatter(amount: double.parse(json_comanda[index]['Monto'].toString().replaceAll('-', ''))).output.symbolOnLeft,status_comanda,json_comanda[index]['ID'].toString(), index);
                        },
                        child: Card(
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
                                      child: Text( 'PEDIDO ${json_order[index]['ID'].toString()}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),),
                                    Expanded(child:
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Tools.getColorStatusBarra(json_order[index]['Id_Status'].toString()),
                                      ),
                                    ),
                                    )
                                  ],
                                ),

                                Row(
                                  children: [
                                    Expanded(child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text('${json_order[index]['Referencia'].toString()}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),),
                                    Expanded(child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(MoneyFormatter(amount: double.parse(json_order[index]['Monto'].toString().replaceAll('-', ''))).output.symbolOnLeft,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),)
                                  ],
                                ),

                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(DateFormat('dd-MMM-yyyy HH:mm').format(DateFormat('dd/MM/yyyy HH:mm').parse(json_order[index]['Fecha_Abonado'].toString(), true).toLocal()),
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(json_order[index]['Cliente'].toString(),
                                    style: const TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(json_order[index]['Nombre_Cajero'].toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 20,)
                              ],
                            ),
                          ),
                        ),
                      ) ;
                    },
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
      drawer: UITools.getMenulateral(context),
    );
  }

  void GetTransactions(){
    fetchGetTransactions().then((value) {
      print(value);
      switch(value['rcode']){
        case -1:
          Tools().showMessageBox(context,value['msg']);
          break;

        case 0:

          setState(() {
            text_title = '';
            json_order = value['list_order'];
            json_comanda = value['list_comanda'];
            print('LISTA COMANDA : $json_comanda');
            banOrder=true;
          });

          cont ++;
          break;
        case 1:
          Tools().showMessageBox(context,'No se pudo obtener información de transacciones. Intenta mas tarde.');
          break;
        default:

          Tools().showMessageBox(context,'Error[1] al obtener información de transacciones. Intenta de nuevo mas tarde');
          break;
      }
    },);
  }
  Future<void> _displayProducts(BuildContext context, json_products, reference, cliente, monto, status, id_order, index ) async {
    print("lista Prodcutos Comanda: $json_products");
    return showDialog(
        context: context,
        builder: (context) {
          return AlertOrder(reference:reference, cliente:cliente, monto:monto, status : status, id_order: id_order, json_products: json_products);
        }).whenComplete(() =>GetTransactions());
  }

  Future<Map<String,dynamic>> fetchGetTransactions() async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
          <getTXNCub xmlns="http://tempuri.org/">
            <k>${Tools.keyIndie}</k>
            <codigoV>$codigoV</codigoV>
            <codigo>$codigo</codigo>
            <nD>$cont</nD>
          </getTXNCub>
        </soap:Body>
      </soap:Envelope>''';
    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    final response =
    await http.post(Uri.parse( IndieService.getTXNCub.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.getTXNCub.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("getTXNCubResult").first.text;
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



class AlertOrder extends StatefulWidget {
  final json_products ;
  final String reference;
  final String cliente;
  final String monto;
  final String status;
  final String id_order;



  const AlertOrder({Key? key,required this.json_products, required this.reference, required this.cliente,required this.monto, required this.status, required this.id_order}) : super(key: key);

  @override
  State<AlertOrder> createState() => _AlertOrderState(json_products,reference,cliente,monto,status,id_order);
}

class _AlertOrderState extends State<AlertOrder> {

  final json_products ;
  final String reference;
  final String cliente;
  final String monto;
  String status;
  final String id_order;



  _AlertOrderState(this.json_products, this.reference, this.cliente, this.monto, this.status, this.id_order);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              color: Tools.getColorStatusBarra(status),
              child: Column(
                children: [
                  Center(child: Text('Order: ${reference}'),),

                ],
              ),
            ),
            Text(monto, style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),),
            const Text('Cliente', style: TextStyle(
              fontSize: 20,
            ),),
            Text(cliente, style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),),
          ],
        ),
      ),
      content: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            width:  MediaQuery.of(context).size.width,
            child: Column(
              children:  [
                const SizedBox(height: 10,),
                const Text('Lista de Ordenes', style: TextStyle(
                  fontSize: 20,
                ),),
                const SizedBox(height: 20,),
                ListView.builder(
                  itemCount: json_products== null ? 0: json_products.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        /*mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,*/
                        children: [

                          Row(
                            /*mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,*/
                            children: [
                              Expanded(
                                flex: 1,
                                child:
                                Container(
                                  alignment: Alignment.center,
                                  height: 75,
                                  margin: const EdgeInsets.only(top: 10),
                                  child:Text(json_products[index]['producto'],
                                    style: const TextStyle(fontSize: 20),
                                  ) ,
                                ),
                              ),
                              Expanded(child:
                              Container(
                                alignment: Alignment.center,
                                height: 55,
                                margin: const EdgeInsets.only(top: 10),
                                child:Text(json_products[index]['CANTIDAD'],
                                  style: const TextStyle(fontSize: 20),
                                ) ,
                              ),
                              ),
                              Expanded(child:
                              Container(
                                alignment: Alignment.center,
                                height: 55,
                                margin: const EdgeInsets.only(top: 10),
                                child:Text(MoneyFormatter(amount: double.parse(json_products[index]['MONTO'].toString().replaceAll('-', ''))).output.symbolOnLeft,
                                  style: const TextStyle(fontSize: 20),),

                              ),)
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10,),
              ],
            ),
          )
      ),
      actions: <Widget>[
        TextButton(onPressed: (){
          Navigator.of(context).pop();

          //getOrders();
        },
            child: Text("Cerrar")
        ),
      ],
    );
  }

  Future<Map<String,dynamic>> fetchSetOrder(String reference) async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <setStatusBarra xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigo</codigo>
          <reference>$reference</reference>
          <status>4</status>
        </setStatusBarra>
      </soap:Body>
    </soap:Envelope>''';
    print(soap);
    /*showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });
*/
    final response =
    await http.post(Uri.parse( IndieService.setstatusBarra.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.setstatusBarra.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      //Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("setStatusBarraResult").first.text;
        //String res = '{ "rcode": 0, "list_order": [ { "ID": "32", "Fecha_Abonado": "13/12/2022 05:03:13 p. m.", "Cajero": "cubetero7", "Cliente": "Liliana Maranyeli", "Banco": "", "Referencia": "O909219058", "Monto": "-414.7500", "list_product": [ { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "RON BACARDI SENCILLO", "MONTO": "125", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "RON BACARDI SENCILLO", "MONTO": "125", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "MEZCAL UNIÓN SENCILLO", "MONTO": "145", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "PROPINA", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "Propina", "MONTO": "19.75", "COMANDA_ESTATUS": "Solicitada" } ] } ] }';
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
      //Navigator.pop(context);
      var resError = {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$error]'
      };

      return resError;
    });

    print(response);
    return response;


  }

  Future<Map<String,dynamic>> fetchSetCancelOrder(String id_order,  json_prod) async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String id_prod = "";
    for(Map<String,dynamic> data in json_prod){

      print('Producto: $data');
      id_prod = '${data['ID']},$id_prod';
    }
    id_prod = id_prod.substring(0, id_prod.length-1);
    print('ID_Productos: $id_prod');

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <rollBPedido xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigo</codigo>
          <idP>$id_order</idP>
          <idD>$id_prod</idD>
        </rollBPedido>
      </soap:Body>
    </soap:Envelope>''';

    print(soap);
    /*showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });
*/
    final response =
    await http.post(Uri.parse( IndieService.rollBPedido.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.rollBPedido.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      //Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("rollBPedidoResult").first.text;
        //String res = '{ "rcode": 0, "list_order": [ { "ID": "32", "Fecha_Abonado": "13/12/2022 05:03:13 p. m.", "Cajero": "cubetero7", "Cliente": "Liliana Maranyeli", "Banco": "", "Referencia": "O909219058", "Monto": "-414.7500", "list_product": [ { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "RON BACARDI SENCILLO", "MONTO": "125", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "RON BACARDI SENCILLO", "MONTO": "125", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "MEZCAL UNIÓN SENCILLO", "MONTO": "145", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "PROPINA", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "Propina", "MONTO": "19.75", "COMANDA_ESTATUS": "Solicitada" } ] } ] }';
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
      //Navigator.pop(context);
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