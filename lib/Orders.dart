import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

import 'AddProductos.dart';
import 'Login.dart';
import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/ServiceWS.dart';
import 'Utils/Tools.dart';
import 'Utils/UITools.dart';

class OrderActivity extends StatefulWidget {
  const OrderActivity({Key? key}) : super(key: key);

  @override
  State<OrderActivity> createState() => _OrderActivityState();
}

class _OrderActivityState extends State<OrderActivity> {
  var selectedCategoria;
  var selectedProducto;

  var version_code = "";

  String name_user = "";
  String text_title = "";
  var banOrder = false;

  String status_comanda = "";
  var json_order = [];

  //final _controller = ActionSliderController();

  //Color _colorstatus = ColorsIndie.colorAmarillo.getColor();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {

      getVersionApp();
      getUser();
      setState(() {
        json_order = [];
      });

      getOrders();

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UITools.getAppBar(context, name_user),
      drawer: UITools.getMenulateral(context),
      backgroundColor: ColorsIndie.colorGC2.getColor(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20,),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  child: const Text( 'LISTA DE PEDIDOS',
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
                  itemCount: json_order == null ? 0 : json_order.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: (){
                        setState(() {

                          status_comanda = json_order[index]['Id_Status'].toString();
                        });
                        _displayProducts(context,json_order[index]['list_product'],json_order[index]['Referencia'],json_order[index]['Cliente'].toString(), MoneyFormatter(amount: double.parse(json_order[index]['Monto'].toString().replaceAll('-', ''))).output.symbolOnLeft,status_comanda,json_order[index]['ID'].toString(), index);
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
                                      color: ColorsIndie.colorgris.getColor(),
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

                              /*Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(DateFormat('dd-MMM-yyyy HH:mm').format(DateFormat('dd/MM/yyyy HH:mm').parse(json_order[index]['Fecha_Abonado'].toString(), true).toLocal()),
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ),*/
                              /*Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(json_order[index]['Cliente'].toString(),
                                  style: const TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),*/
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
    );
  }


  Future<void> _displayTextInputDialog(BuildContext context) async {
    /*jsonCarrito = listCarrito.map((e) => e.toJson()).toString();
    print('SJ Json: $jsonCarrito');
    var jsonCarritoMap = [];
    setState(() {

      var sj2 = listCarrito.map((e) {
        jsonCarritoMap.add(e.toJson());
      },);
      //jsonCarrito = listCarrito.map((e) => e.toJson()).toString().substring(1,sj.length-1);
      jsonCarrito = sj2.toString();
    });*/


    var etPropinaController = TextEditingController();
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            /*title: Text("Monto total a pagar: ${monto + propina} ¿Como quieres pagar?"),*/
            content: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children:  [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      margin: EdgeInsets.only(top: 10),
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
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto, propina: 0, inventario: (banInventario).toString(), modePayment: 2, banco: 1, referencia: "CORTESIA",),));

                      },
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                            primary: ColorsIndie.colorGC1.getColor(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )
                        ),
                        child: const Text("Cortesia"),
                      ),

                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      margin: EdgeInsets.only(top: 10),
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
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto, propina: propina, inventario: (banInventario).toString(), modePayment: 2, banco: 1, referencia: "EFECTIVO",),));

                      },
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                            primary: ColorsIndie.colorgris.getColor(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )
                        ),
                        child: const Text("Pago en Efectivo"),
                      ),

                    ),

                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      margin: EdgeInsets.only(top: 10),
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
                        /*ServiceWS.fetchPaymentTerminal((monto + propina).toString(), '$jsonCarritoMap', banInventario, context).then((value) {

                          print('Res Login: $value');
                          switch(value['rcode']){
                            case -1:
                              Tools().showMessageBox(context,value['msg']);
                              break;
                            case 0:


                              var js = jsonEncode(value['msg']);
                              print('Codigo referencia: ${value['msg']}');
                              etPropinaController.text = value['msg'] ;

                              break;
                            case 1:
                              new Tools().showMessageBox(context, value['msg']);

                              break;
                            default:

                              Tools().showMessageBox(context,'No se pudo conetar con la terminal. Intenta de nuevo mas tarde[1]');
                              break;
                          }

                        });*/

                      },
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                            primary: ColorsIndie.colorgris.getColor(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )
                        ),
                        child: const Text("Iniciar pago en Terminal"),
                      ),

                    ),

                    SizedBox(height: 20,),
                    Text('Folio de Terminal'),

                    Container(
                      margin: const EdgeInsets.only( top: 25, bottom: 20),
                      decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                offset: Offset(0, 5)
                            )
                          ]
                      ),
                      child: TextField(
                        controller: etPropinaController,
                        maxLines: 1,
                        enabled: false,
                        decoration: InputDecoration(
                            hintText: "000",
                            filled: true,
                            fillColor: ColorsIndie.colorGC2.getColor(),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  width: 0,
                                  style: BorderStyle.none,
                                )
                            )
                        ),
                      ),
                    ),


                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      margin: EdgeInsets.only(top: 10),
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
                        if(etPropinaController.text.isEmpty){
                          Tools().showMessageBox(context, "Debe iniciar el pago en terminal antes");
                          return;
                        }
                        String ref_pay = etPropinaController.text;
                        print(ref_pay);
                        /*ServiceWS.fetchValidateTerminal(monto.toString(), '$jsonCarritoMap', banInventario, ref_pay, context).then((value) {

                          print('Res Login: $value');
                          switch(value['rcode']){
                            case -1:
                              Tools().showMessageBox(context,value['msg']);
                              break;
                            case 0:

                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto, propina: propina, inventario: (banInventario).toString(), modePayment: 2, banco: 6, referencia: ref_pay ,),));


                              break;
                            case 1:
                              new Tools().showMessageBox(context, value['msg']);

                              break;
                            default:

                              Tools().showMessageBox(context,'No se pudo conetar con la terminal. Intenta de nuevo mas tarde[1]');
                              break;
                          }

                        });*/


                      },
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                            primary: ColorsIndie.colorgris.getColor(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )
                        ),
                        child: const Text("Aplicar Compra"),
                      ),

                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 55,
                      margin: EdgeInsets.only(top: 10),
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
                        if(etPropinaController.text.isEmpty){
                          Tools().showMessageBox(context, "Debe iniciar el pago en terminal antes");
                          return;
                        }
                        String ref_pay = etPropinaController.text;
                        print(ref_pay);
                        ServiceWS.fetchCancelPaymentTerminal(ref_pay, context).then((value) {

                          print('Res Login: $value');
                          switch(value['rcode']){
                            case -1:
                              Tools().showMessageBox(context,value['msg']);
                              break;
                            case 0:


                              Tools().showMessageBox(context,"El pago ha sido cancelado.");

                              break;
                            case 1:
                              new Tools().showMessageBox(context, value['msg']);

                              break;
                            default:

                              Tools().showMessageBox(context,'No se pudo conetar con la terminal. Intenta de nuevo mas tarde[1]');
                              break;
                          }

                        });


                      },
                        style: ElevatedButton.styleFrom(
                            textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                            primary: ColorsIndie.colorGC3.getColor(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            )
                        ),
                        child: const Text("Cancelar Compra"),
                      ),

                    ),
                  ],
                )
            )
            /*TextField(
              controller: etTextAlert,
              keyboardType: TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(hintText: "Ingresa tu propina"),
            */,
            actions: <Widget>[

              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Text( style: TextStyle(fontWeight: FontWeight.bold),
                      "Cortesia")
              ),
              TextButton(onPressed: (){
                Navigator.of(context).pop();
              },
                  child: Text("Cancelar")
              ),
            ],
          );
        });
  }
  Future<void> getVersionApp() async{

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version_code = Encriptacion().encryptDataE(packageInfo.version, Encriptacion.keyIdVer);
    print(version_code);
  }

  getUser() async {
    String data_user = await DataBaseHelper.getValue(DBHelperItem.nameClient.getValue());
    setState(() {
      name_user = data_user;
    });
  }
//
  Future<void> _displayProducts(BuildContext context, json_products, reference, cliente, monto, status, id_order, index ) async {

    return showDialog(
        context: context,
        builder: (context) {
          return AlertOrder(reference:reference, cliente:cliente, monto:monto, status : status, id_order: id_order, json_products: json_products);
        }).then((value) {
          if(value == "ADD"){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddProductos(reference: reference,),));

          }
          if(value == "COBRAR"){
            //Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddProductos(reference: reference,),));
            _displayTextInputDialog(context);
          }
    }).whenComplete(() => getOrders());
  }



  getOrders(){

    fetchOrders().then((value) {
      switch(value['rcode']){
        case -1:
        //Tools().showMessageBox(context,value['msg']);
          setState(() {
            text_title = value['msg'];
            banOrder=false;
          });
          break;

        case 0:

          setState(() {
            text_title = '';
            print(value['msg']);
            var jlist = jsonDecode(value['msg']);
            json_order = jlist['list_order'];
            banOrder=true;
          });
          /*setState(() {
                banQR = false;
                dataQR = value['msg'];
              });*/
          break;
        case 1:

          setState(() {
            text_title = 'Error al obtener información de las ordenes';
            banOrder=false;
          });
          //Tools().showMessageBox(context,'Error al obtener el balance del cliente');
          break;
        default:

          setState(() {
            text_title = 'No se pudo obtener información de las ordenes[1]';
            banOrder=false;
          });
          //Tools().showMessageBox(context,'No se pudo obtener información del balance[1]');
          break;
      }
    },);
  }

  Future<Map<String,dynamic>> fetchOrders() async {
    /*String res = '{ "rcode": 0, "list_order": [ { "ID": "32", "Fecha_Abonado": "13/12/2022 05:03:13 p. m.", "Cajero": "cubetero7", "Cliente": "Liliana Maranyeli", "Banco": "", "Referencia": "O909219058", "Monto": "-414.7500", "list_product": [ { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "RON BACARDI SENCILLO", "MONTO": "125", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "RON BACARDI SENCILLO", "MONTO": "125", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "ALCOHOL", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "MEZCAL UNIÓN SENCILLO", "MONTO": "145", "COMANDA_ESTATUS": "Solicitada" }, { "ID": "32", "FECHA": "13/12/2022 05:03:13 p. m.", "CATEGORIA": "PROPINA", "TIPO_CLIENTE": "IOS", "Usuario": "7761233719", "Cliente": "Liliana Maranyeli", "ORDEN_COMPRA": "O909219058", "producto": "Propina", "MONTO": "19.75", "COMANDA_ESTATUS": "Solicitada" } ] } ] }';
    print(jsonDecode(res));
    return jsonDecode(res);*/

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <getListorderPay xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
            <codigoV>$codigoV</codigoV>
            <codigo>$codigo</codigo>
          <nD>1</nD>
        </getListorderPay>
      </soap:Body>
    </soap:Envelope>''';
    print(soap);
    showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    final response =
    await http.post(Uri.parse( IndieService.getListorderPay.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.getListorderPay.getSoapAction(),
      },
      body: utf8.encode(soap),
    ).then((response) {
      print('Responde: $response');
      Navigator.pop(context);
      if (response.statusCode == 200) {
        // Si la llamada al servidor fue exitosa, analiza el JSON
        print(response.body);
        XmlDocument document = XmlDocument.parse(response.body);


        String res = document.findAllElements("getListorderPayResult").first.text;
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

  void logout() {
    //Tools().saveUser("", "", "", "");
    DataBaseHelper.deleteLogin();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login() ));
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


  //final _controller = ActionSliderController();

  _AlertOrderState(this.json_products, this.reference, this.cliente, this.monto, this.status, this.id_order);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
      setState(() {

        /*if(status == '4'){
          _controller.success();
        }
        else{

          _controller.reset();
        }*/
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              color: ColorsIndie.colorgris.getColor(),
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
            /*const Text('Cliente', style: TextStyle(
              fontSize: 20,
            ),),
            Text(cliente, style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),),*/
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
                const Text('Pedidos', style: TextStyle(
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
                              Expanded(child:
                              Container(
                                alignment: Alignment.center,
                                height: 55,
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

                SizedBox(height: 20,),
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
                    //eventContinuar();
                    //Navigator.of(context).pop("COBRAR");
                    //_displayTextInputDialog(context);

                    Navigator.of(context).pop("COBRAR");
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
                    child: const Text("COBRAR"),
                  ),

                ),
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
                    //eventContinuar();
                    //Navigator.of(context).pop("CANCELAR");
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
                    child: const Text("CANCELAR"),
                  ),

                ),
                /*const SizedBox(height: 10,),
                ActionSlider.standard(
                  controller: _controller,
                  actionThresholdType: ThresholdType.release,
                  backgroundColor: ColorsIndie.colorGC1.getColor(),
                  toggleColor: ColorsIndie.colorGC2.getColor(),
                  action: (controller) async {
                    controller.loading(); //starts loading animation
                    await Future.delayed(const Duration(seconds: 3));
                    fetchSetOrder(reference).then((value) {
                      switch(value['rcode']){
                        case -1:
                        //Tools().showMessageBox(context,value['msg']);
                          setState(() {
                            //json_order[index]['Id_Status'] = '2';
                            status = '2';
                            controller.reset(); //resets the slider
                          });
                          break;

                        case 0:

                          setState(() {
                            controller.success(); //starts success animation
                            //status_comanda = '4';
                            status = '4';
                            //7json_order[index]['Id_Status'] = '4';

                            //print("Terminado: status - $status_comanda");
                          });
                          break;
                        case 1:

                          setState(() {

                            status = '2';
                            //json_order[index]['Id_Status'] = '2';
                            controller.reset(); //resets the slider
                          });
                          //Tools().showMessageBox(context,'Error al obtener el balance del cliente');
                          break;
                        default:

                          setState(() {

                            status = '2';
                            //json_order[index]['Id_Status'] = '2';
                            controller.reset(); //resets the slider
                          });
                          //Tools().showMessageBox(context,'No se pudo obtener información del balance[1]');
                          break;
                      }
                    },);

                    //print("Terminado: status - $status_comanda");
                    //print("Terminado: status - ${json_order[index]['Id_Status']}");
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child:  Expanded(child: Text('LISTO', style: TextStyle(color: ColorsIndie.colorGC2.getColor()),)),
                ),
                const SizedBox(height: 10,),
                ActionSlider.standard(
                  actionThresholdType: ThresholdType.release,
                  backgroundColor: ColorsIndie.colorSec5.getColor(),
                  toggleColor: ColorsIndie.colorGC2.getColor(),
                  action: (controller) async {
                    controller.loading(); //starts loading animation
                    await Future.delayed(const Duration(seconds: 3));
                    fetchSetCancelOrder(id_order,json_products).then((value) {
                      switch(value['rcode']){
                        case -1:
                        //Tools().showMessageBox(context,value['msg']);
                        //_colorstatus = ColorsIndie.colorAmarillo.getColor();
                          setState(() {

                            controller.reset(); //resets the slider
                          });
                          break;

                        case 0:

                        //_colorstatus = ColorsIndie.colorVerde.getColor();
                          setState(() {
                            controller.success(); //starts success animation
                          });
                          break;
                        case 1:

                        //_colorstatus = ColorsIndie.colorAmarillo.getColor();
                          setState(() {

                            controller.reset(); //resets the slider
                          });
                          Tools().showMessageBox(context,'${value['msg']}. ');
                          break;
                        default:

                        //_colorstatus = ColorsIndie.colorAmarillo.getColor();
                          setState(() {

                            controller.reset(); //resets the slider
                          });
                          //Tools().showMessageBox(context,'No se pudo obtener información del balance[1]');
                          break;
                      }
                    },);



                    print("Terminado");
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: Expanded(child: Text('CANCELAR', style: TextStyle(color: ColorsIndie.colorGC2.getColor()),),) ,
                ),*/
              ],
            ),
          )
      ),
      actions: <Widget>[

        TextButton(onPressed: (){

          Navigator.of(context).pop("ADD");
        },
            child: Text("Agregar productos")
        ),
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


class Productos extends StatefulWidget {
  final String reference_order;



  const Productos({Key? key,required this.reference_order}) : super(key: key);

  @override
  State<Productos> createState() => _ProductosState(reference_order);
}

class _ProductosState extends State<Productos> {


  final String reference_order;


  //final _controller = ActionSliderController();

  _ProductosState( this.reference_order);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp){
      setState(() {

        /*if(status == '4'){
          _controller.success();
        }
        else{

          _controller.reset();
        }*/
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              color: ColorsIndie.colorgris.getColor(),
              child: Column(
                children: [
                  Center(child: Text('Order: ${reference_order}'),),

                ],
              ),
            ),

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
                const Text('Agregar productos', style: TextStyle(
                  fontSize: 20,
                ),),
                const SizedBox(height: 20,),

              ],
            ),
          )
      ),
      actions: <Widget>[

        TextButton(onPressed: (){  Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  AddProductos(reference: reference_order),));

          Navigator.of(context).pop("ADD");
        },
            child: Text("Agregar productos")
        ),
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


