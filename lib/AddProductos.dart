import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indierocks_cubetero/addProductsStatus.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/Model/CarritoModel.dart';
import 'Utils/Model/CategoriaModel.dart';
import 'Utils/Model/ProductoModel.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/Tools.dart';
import 'Utils/UITools.dart';

class AddProductos extends StatefulWidget {

  final String reference ;
  const AddProductos({Key? key, required this.reference}) : super(key: key);

  @override
  State<AddProductos> createState() => _AddProductosState(reference);
}

class _AddProductosState extends State<AddProductos> {

  var reference;

  var selectedCategoria;
  var selectedProducto;
  List<CategoriaModel> listCategoria = [];
  List<ProdcutoVenta> listProducto = [];
  List<ProdcutoVenta> listProductoAll = [];
  List<CarritoModel> listCarrito = [];

  var etMontoControlloler = TextEditingController();
  var etCantidadControlloler = TextEditingController();
  var etPropinaController = TextEditingController(text: '\$0');
  var etTextAlert = TextEditingController();

  var _user = "";
  var _pass = "";
  var _name = "";
  var jsonCarrito = "";
  var _codeV = "";
  var _code = "";
  var _banco = "0";
  double monto = 0;
  double propina = 0;
  var version_code = "";
  var inventario = "1";

  var banInventario = true;
  var banGetProduct = false;
  var msgGetProducts = "";

  String name_user = "";

  _AddProductosState(this.reference);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {


      getProductos(banInventario);

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
            child: Container(
              child: Column(
                children: [

                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    padding: const EdgeInsets.only(top: 5, left: 20,),
                    color: ColorsIndie.colorGC1.getColor(),
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
                              child: Switch(value: banInventario,onChanged: (value) {
                                banInventario = value;

                                getProductos(banInventario);
                              },)
                          ),
                        )
                      ],
                    ),
                  ),
                  banGetProduct? Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(msgGetProducts,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          width: MediaQuery.of(context).size.width,
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
                          child: ElevatedButton(onPressed: (){
                            getProductos(banInventario);
                          },
                            style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                ),
                                primary: ColorsIndie.colorGC2.getColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )
                            ),
                            child:  Text("Reintentar", style: TextStyle(color: ColorsIndie.colorGC1.getColor())),
                          ),

                        ),
                      ],
                    ),
                  ) :
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        DropdownButtonFormField<CategoriaModel>(
                          isExpanded: true,
                          style: TextStyle(fontSize: 22, color: ColorsIndie.colorGC1.getColor()),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorsIndie.colorGC2.getColor(), width: 0),
                            ),
                            filled: true,
                            fillColor: ColorsIndie.colorGC3.getColor(),
                          ),
                          dropdownColor: ColorsIndie.colorGC3.getColor(),
                          value: selectedCategoria,
                          onChanged: (CategoriaModel? newValue) {

                            print(listCategoria.indexOf(newValue!));
                            print(newValue.index);
                            listProducto = [];
                            /*setState(() {

                              selectedCategoria = newValue;
                            });
                            listProducto = Tools().getProdcutos(selectedCategoria);
                            selectedProducto = null;
                            selectedProducto = listProducto.elementAt(0);
                            etMontoControlloler.text =  MoneyFormatter(amount: selectedProducto.costo).output.symbolOnLeft;*/

                            setState(() {
                              selectedCategoria = newValue;
                              listProducto = listProductoAll.where((element) {
                                return element.categoria.index == (selectedCategoria as CategoriaModel).index;
                              },).toList();
                              selectedProducto = listProducto.elementAt(0);
                              etMontoControlloler.text =  MoneyFormatter(amount: (selectedProducto as ProdcutoVenta).costo).output.symbolOnLeft;
                            });
                          },
                          items: listCategoria.map((CategoriaModel? value){
                            return DropdownMenuItem<CategoriaModel>(
                                value: value,
                                child: Text(value!.nombre)
                            );
                          }).toList(),
                        ),
                        DropdownButtonFormField<ProdcutoVenta>(
                          isExpanded: true,
                          style: TextStyle(fontSize: 22, color: ColorsIndie.colorGC1.getColor()),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: ColorsIndie.colorGC2.getColor(), width: 0),
                            ),
                            filled: true,
                            fillColor: ColorsIndie.colorgris.getColor(),
                          ),
                          dropdownColor: ColorsIndie.colorgris.getColor(),
                          value: selectedProducto,
                          onChanged: (ProdcutoVenta? newValue) {

                            selectedProducto = newValue;
                            etMontoControlloler.text =  MoneyFormatter(amount: double.parse ((selectedProducto as ProdcutoVenta).costo.toString())).output.symbolOnLeft;
                            //print(listProducto.indexOf(newValue!));
                          },
                          items: listProducto.map((ProdcutoVenta? value){
                            return DropdownMenuItem<ProdcutoVenta>(
                                value: value,
                                child: Text(value!.nombre.toString())
                            );
                          }).toList(),),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: etMontoControlloler,
                                readOnly: true,
                                maxLines: 1,
                                style: TextStyle(fontSize: 22, color: ColorsIndie.colorGC1.getColor()),
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: ColorsIndie.colorGC3.getColor(),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: const BorderSide(
                                          width: 0,
                                          style: BorderStyle.none,
                                        )
                                    )
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: etCantidadControlloler,

                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2)
                                ],
                                keyboardType: TextInputType.numberWithOptions(decimal: false),
                                maxLines: 1,
                                style: TextStyle(fontSize: 22, color: ColorsIndie.colorGC1.getColor()),
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
                              ),
                            )
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
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
                          child: ElevatedButton(onPressed: (){
                            eventAddProduct();
                          },
                            style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                ),
                                primary: ColorsIndie.colorGC2.getColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )
                            ),
                            child:  Text("Agregar", style: TextStyle(color: ColorsIndie.colorGC1.getColor())),
                          ),

                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child:
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, position){
                              return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) {
                                  setState(() {
                                    monto = monto - ( double.parse( listCarrito.elementAt(position).cantidad.toString()) * double.parse( listCarrito.elementAt(position).prodcutoVenta.costo.toString()));
                                    listCarrito.removeAt(position);
                                  });
                                },
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  padding: const EdgeInsets.only(right: 30),
                                  alignment: Alignment.centerRight,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: Text(
                                            listCarrito.elementAt(position).prodcutoVenta.nombre,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Text(
                                                '1x\$${listCarrito.elementAt(position).prodcutoVenta.costo}',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '${listCarrito.elementAt(position).cantidad}',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '\$${listCarrito.elementAt(position).prodcutoVenta.costo * listCarrito.elementAt(position).cantidad }',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: listCarrito.length,
                          ),
                        ),
                        SizedBox(height: 200,)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                padding: const EdgeInsets.only(top: 5, left: 20,),
                color: ColorsIndie.colorGC1.getColor(),
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
                          child: Switch(value: banInventario,onChanged: (value) {
                            banInventario = value;

                            getProductos(banInventario);
                          },)
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
          banGetProduct? SizedBox(height: 0,):Positioned(
            bottom: 0.0,
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: (MediaQuery.of(context).size.width),
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
                          child: ElevatedButton(onPressed: (){
                            eventsendProducotr();
                          },
                            style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                ),
                                primary: ColorsIndie.colorGC2.getColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )
                            ),
                            child:  Text("Agregar productos", style: TextStyle(color: ColorsIndie.colorGC1.getColor())),
                          ),

                        ),

                      ],
                    )
                  ],
                )

              ],
            ),
          )
        ],
      ),
    );
  }

  void eventAddProduct() {
    if(etCantidadControlloler.text.isEmpty){
      Tools().showMessageBox(context, "Debe ingresar una cantidad valida");
      return;
    }
    setState(() {
      CarritoModel car = CarritoModel(cantidad: int.parse(etCantidadControlloler.text), prodcutoVenta: selectedProducto);
      print("Cantidad carrito = ${car.cantidad}");
      print("Costo Producto = ${car.prodcutoVenta.costo}");
      listCarrito.add(car);
      print("Producto agregado : Monto actual = $monto");
      monto = monto + ( double.parse( car.cantidad.toString()) * double.parse( car.prodcutoVenta.costo.toString()));
      print("Producto agregado : Monto actual = $monto");
      etCantidadControlloler.text = "";
    });
  }

  void getProductos(bool ban){

    listCategoria = [];
    listProducto = [];
    listProductoAll = [];
    listCarrito = [];
    fetchGetProducts(ban).then((value) {
      if (!mounted) {
        return; // Just do nothing if the widget is disposed.
      }
      switch(value['rcode']){
        case -1:
        //Tools().showMessageBox(context,'No se pudieron obtener los productos disponibles. Intenta mas tarde');
        //msgGetProducts = "No se pudieron obtener los productos disponibles. Intenta mas tarde";
          setState(() {
            banGetProduct = true;
            msgGetProducts = "No se pudieron obtener los productos disponibles. Intenta mas tarde";
          });
          break;
        case 0:

          var json_list = jsonDecode(value['msg']);
          print(json_list);
          //print('Res Productos: $j');
          //var jArray = j as Map<String, dynamic>;
          /*print('Primer Item: ');*/
          for(Map<String,dynamic> data in json_list){

            setState(() {
              CategoriaModel cat = CategoriaModel(nombre: data['c'][0]['name'], index: data['c'][0]['ID']);
              if(!listCategoria.any((element) => element.index == cat.index)){
                listCategoria.add(cat);


              }
              ProdcutoVenta prodcutoVenta = ProdcutoVenta(
                  nombre: data['productName'],
                  costo: double.parse(data['sku_monto']),
                  categoria: cat,
                  sku: data['sku'],
                  service: data['service']
              );
              listProductoAll.add(prodcutoVenta);
            });

          }
          setState(() {
            banGetProduct = false;
            selectedCategoria = listCategoria.elementAt(0);
            listProducto = listProductoAll.where((element) {
              return element.categoria.index == (selectedCategoria as CategoriaModel).index;
            },).toList();
            selectedProducto = listProducto.elementAt(0);
            etMontoControlloler.text =  MoneyFormatter(amount: (selectedProducto as ProdcutoVenta).costo).output.symbolOnLeft;
          });
          break;
        case 1:
          setState(() {

            banGetProduct = true;
            listCategoria = [];
            listProducto = [];
            listProductoAll = [];
            listCarrito = [];
            etCantidadControlloler.text="";
            etMontoControlloler.text = "";
            msgGetProducts = "No cuentas con productos diponibles. Acercate a la barra.";
          });
          //Tools().showMessageBox(context,'No cuentas con productos diponibles. Acercate a la barra.');
          break;
        default:


          setState(() {

            banGetProduct = true;
            listCategoria = [];
            listProducto = [];
            listProductoAll = [];
            listCarrito = [];
            etCantidadControlloler.text="";
            etMontoControlloler.text = "";
            msgGetProducts = "No se pudieron obtener los productos disponibles. Intenta mas tarde";
          });
          //Tools().showMessageBox(context,'No se pudieron obtener los productos disponibles. Intenta mas tarde');
          break;
      }

      //print('ListCategoria: ${listCategoria.toString()}');
      //print('ListProducto: ${listProducto.toString()}');

    },);
  }

  Future<Map<String,dynamic>> fetchGetProducts(bool banInventario) async {

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    String codigoV = Encriptacion().encryptDataE(ver, Encriptacion.keyIdVer);
    String codigo = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <getSKU xmlns="http://tempuri.org/">
              <k>${Tools.keyIndie}</k>
              <codigoV>$codigoV</codigoV>
              <codigo>$codigo</codigo>
              <general_data>$banInventario</general_data>
            </getSKU>
          </soap:Body>
        </soap:Envelope>''';
    print(soap);
    showDialog(context: context,barrierDismissible: false, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    var resApi = null;
    try{
      final response =
      await http.post(Uri.parse( IndieService.getSKU.getURL()),
        headers: {
          'content-type': 'text/xml',
          'SOAPAction': IndieService.getSKU.getSoapAction(),
        },
        body: utf8.encode(soap),
      ).then((response) {
        print('Responde: $response');
        Navigator.pop(context);
        if (response.statusCode == 200) {
          // Si la llamada al servidor fue exitosa, analiza el JSON
          print(response.body);
          XmlDocument document = XmlDocument.parse(response.body);


          String res = document.findAllElements("getSKUResult").first.text;
          print(jsonDecode(res));
          resApi =  jsonDecode(res);
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
    }
    catch( e){

      //Navigator.pop(context);
      resApi=   {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$e]'
      };
    }

    //print(response);
    return resApi;


  }

  void eventsendProducotr() {
    jsonCarrito = listCarrito.map((e) => e.toJson()).toString();
    print('SJ Json: $jsonCarrito');
    var jsonCarritoMap = [];
    setState(() {

      var sj2 = listCarrito.map((e) {
        jsonCarritoMap.add(e.toJson());
      },);
      //jsonCarrito = listCarrito.map((e) => e.toJson()).toString().substring(1,sj.length-1);
      jsonCarrito = sj2.toString();
    });
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => addProductsStatus(referencia: this.reference, codigoP: '$jsonCarritoMap'),), (route) => false);

  }
}
