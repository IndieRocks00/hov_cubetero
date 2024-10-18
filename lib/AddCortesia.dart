import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:indierocks_cubetero/Login.dart';
import 'package:indierocks_cubetero/Payment.dart';
import 'package:indierocks_cubetero/Utils/Model/CarritoModel.dart';
import 'package:indierocks_cubetero/Utils/Model/CategoriaModel.dart';
import 'package:indierocks_cubetero/Utils/Model/ProductoModel.dart';
import 'package:indierocks_cubetero/Utils/Tools.dart';
import 'package:indierocks_cubetero/Utils/UITools.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/ProgressDialog.dart';

class AddCortesiaActivity extends StatefulWidget {
  const AddCortesiaActivity({Key? key, }) : super(key: key);

  @override
  State<AddCortesiaActivity> createState() => _AddCortesiaActivityState();
}

class _AddCortesiaActivityState extends State<AddCortesiaActivity> {


  var selectedCategoria;
  late ProdcutoVenta selectedProducto = new ProdcutoVenta(nombre: "", costo: 0, categoria: new CategoriaModel(nombre: "", index: 0 ), sku: "", service: 0);
  List<CategoriaModel> listCategoria = [];
  List<ProdcutoVenta> listProducto = [];
  List<ProdcutoVenta> listProductoAll = [];
  List<CarritoModel> listCarrito = [];

  var etMontoControlloler = TextEditingController();
  var etCantidadControlloler = TextEditingController(text: '0');
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
  var product_select ;



  var dialogS;

  _AddCortesiaActivityState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
    /*listCategoria = Tools().getCategorias();
    selectedCategoria = listCategoria.elementAt(0);
    print(selectedCategoria);
    listProducto = Tools().getProdcutos(selectedCategoria);
    selectedProducto = listProducto.elementAt(0);

    etMontoControlloler.text =  MoneyFormatter(amount: ((selectedProducto as ProdcutoVenta).costo).toDouble()).output.symbolOnLeft;*/
    if (!mounted) {
      return;
    }

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      setState(() {});
      getVersionApp();
      getUser();
      getProductos(banInventario);
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
      print('Resultado devuelto $value' );
      switch(value['rcode']){
        case -1:
        //Tools().showMessageBox(context,'No se pudieron obtener los productos disponibles. Intenta mas tarde');
        //msgGetProducts = "No se pudieron obtener los productos disponibles. Intenta mas tarde";
          if(mounted){
            setState(() {

              listCategoria = [];
              listProducto = [];
              listProductoAll = [];
              listCarrito = [];
              banGetProduct = true;
              msgGetProducts = "No se pudieron obtener los productos disponibles. Intenta mas tarde";
            });
          }

          break;
        case 0:

          var json_list = jsonDecode(value['msg']);
          print(json_list);
          //print('Res Productos: $j');
          //var jArray = j as Map<String, dynamic>;
          /*print('Primer Item: ');*/
          for(Map<String,dynamic> data in json_list){

            if(mounted)setState(() {

              CategoriaModel cat = CategoriaModel(nombre: data['c'][0]['name'], index: data['c'][0]['ID']);
              if(cat.index == 264){
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
              }


            });

          }
          if(mounted)setState(() {
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
          if(mounted)setState(() {

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


          if(mounted)setState(() {

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

    },).whenComplete(() => Navigator.pop(dialogS));
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {

    super.dispose();
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
                        /*Expanded(flex: 1,
                          child:
                          Center(
                              child: Switch(
                                value: banInventario, onChanged: (value) {
                                banInventario = value;

                                getProductos(banInventario);
                              },)
                          ),
                        )*/
                      ],
                    ),
                  ),
                  banGetProduct || listProductoAll.isEmpty?
                      Column(
                        children: [
                          listProductoAll.isEmpty ? Text("No hay productos disponibles para agregar a cortesias, consulta con tu administrador.",
                            style: TextStyle(fontWeight: FontWeight.bold,
                              fontSize: 20,),
                          ):  SizedBox(height: 20,),
                          SizedBox(height: 20,),
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(msgGetProducts,
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                    fontSize: 20,),
                                ),
                                SizedBox(height: 20,),
                                Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
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
                                    getProductos(banInventario);
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
                                    child: Text("Reintentar", style: TextStyle(
                                        color: ColorsIndie.colorGC1.getColor())),
                                  ),

                                ),
                              ],
                            ),
                          )
                        ],
                      )
                   :
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        /*Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),

                          height: 55,
                          width: MediaQuery.of(context).size.width,
                          child:
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, position) {
                              return GestureDetector(child: Card(
                                color: ColorsIndie.colorGC3.getColor(),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color:ColorsIndie.colorgris.getColor(),
                                    ),

                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20,
                                      right: 20,
                                      top: 10,
                                      bottom: 10),
                                  child: Column(
                                    children: [
                                      Container(

                                        child: Text(
                                          listCategoria
                                              .elementAt(position).nombre,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                  onTap: (){
                                    print(listCategoria.elementAt(position).nombre);

                                    listProducto = [];
                                    setState(() {
                                      selectedCategoria = listCategoria.elementAt(position);
                                      listProducto = listProductoAll.where((element) {
                                        return element.categoria.index ==
                                            (selectedCategoria as CategoriaModel).index;
                                      },).toList();
                                      selectedProducto = listProducto.elementAt(0);
                                      etMontoControlloler.text = MoneyFormatter(
                                          amount: (selectedProducto as ProdcutoVenta)
                                              .costo).output.symbolOnLeft;
                                    });

                                  });

                            },
                            itemCount: listCategoria.length,
                          ),
                        ),*/

                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          child:
                          ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, position) {
                              return GestureDetector(onTap: (){
                                print(listProducto.elementAt(position).nombre);
                                selectedProducto = listProducto.elementAt(position);
                                etMontoControlloler.text = MoneyFormatter(
                                    amount: double.parse(
                                        (selectedProducto as ProdcutoVenta).costo
                                            .toString())).output.symbolOnLeft;
                              },child: Card(
                                color: ColorsIndie.colorgris.getColor(),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color:ColorsIndie.colorgris.getColor(),
                                    ),

                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: Padding(

                                  padding: const EdgeInsets.only(left: 20,
                                      right: 20,
                                      top: 5,
                                      bottom: 5),
                                  child: Column(
                                    children: [
                                      Container(

                                        child: Text(
                                          listProducto
                                              .elementAt(position).nombre,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      /*Container(

                                        child: Text(
                                          MoneyFormatter(
                                              amount: double.parse(
                                                  listProducto.elementAt(position).costo
                                                      .toString())).output.symbolOnLeft,
                                          style: const TextStyle(
                                            fontSize: 25,
                                          ),
                                        ),
                                      ),*/
                                    ],
                                  ),
                                ),
                              ),);

                            },
                            itemCount: listProducto.length,
                          ),
                        ),
                        /*DropdownButtonFormField<CategoriaModel>(
                          isExpanded: true,
                          style: TextStyle(fontSize: 22, color: ColorsIndie
                              .colorGC1.getColor()),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorsIndie.colorGC2.getColor(),
                                  width: 0),
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
                                return element.categoria.index ==
                                    (selectedCategoria as CategoriaModel).index;
                              },).toList();
                              selectedProducto = listProducto.elementAt(0);
                              etMontoControlloler.text = MoneyFormatter(
                                  amount: (selectedProducto as ProdcutoVenta)
                                      .costo).output.symbolOnLeft;
                            });
                          },
                          items: listCategoria.map((CategoriaModel? value) {
                            return DropdownMenuItem<CategoriaModel>(
                                value: value,
                                child: Text(value!.nombre)
                            );
                          }).toList(),
                        ),
                        DropdownButtonFormField<ProdcutoVenta>(
                          isExpanded: true,
                          style: TextStyle(fontSize: 22, color: ColorsIndie
                              .colorGC1.getColor()),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorsIndie.colorGC2.getColor(),
                                  width: 0),
                            ),
                            filled: true,
                            fillColor: ColorsIndie.colorgris.getColor(),
                          ),
                          dropdownColor: ColorsIndie.colorgris.getColor(),
                          value: selectedProducto,
                          onChanged: (ProdcutoVenta? newValue) {
                            selectedProducto = newValue;
                            etMontoControlloler.text = MoneyFormatter(
                                amount: double.parse(
                                    (selectedProducto as ProdcutoVenta).costo
                                        .toString())).output.symbolOnLeft;
                            //print(listProducto.indexOf(newValue!));
                          },
                          items: listProducto.map((ProdcutoVenta? value) {
                            return DropdownMenuItem<ProdcutoVenta>(
                                value: value,
                                child: Text(value!.nombre.toString())
                            );
                          }).toList(),),*/
                        Row(
                          children: [

                            Expanded(child: Center(child: Text('${selectedProducto.nombre} ', style: TextStyle(fontSize: 20, )))),
                          ],
                        ),
                        Row(
                          children: [
                            /*Expanded(
                              child: TextField(
                                controller: etMontoControlloler,
                                readOnly: true,
                                maxLines: 1,
                                style: TextStyle(fontSize: 22,
                                    color: ColorsIndie.colorGC1.getColor()),
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
                            ),*/
                            Expanded(child: GestureDetector(
                              onTap: (){
                                int cant = int.parse(etCantidadControlloler.text);
                                print(cant );
                                if(cant>0){
                                  setState(() {

                                    etCantidadControlloler.text = '${cant--}';
                                    etCantidadControlloler = TextEditingController(text: '${cant--}');
                                  });
                                }

                              },
                              child: Icon(Icons.remove),
                            )),
                            Expanded(
                              flex: 3,
                              child: TextField(
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
                              ),
                            ),

                            Expanded(child: GestureDetector(
                              onTap: (){
                                int cant = int.parse(etCantidadControlloler.text);
                                print(cant);

                                setState(() {
                                  etCantidadControlloler.text = '${cant++}';
                                  etCantidadControlloler = TextEditingController(text: '${cant++}');
                                });

                              },
                              child: Icon(Icons.add),
                            )),
                          ],
                        ),
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
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
                            eventAddProduct();
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
                            child: Text("Agregar", style: TextStyle(
                                color: ColorsIndie.colorGC1.getColor())),
                          ),

                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child:
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, position) {
                              return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) {
                                  setState(() {
                                    monto = monto - (double.parse(listCarrito
                                        .elementAt(position)
                                        .cantidad
                                        .toString()) * double.parse(listCarrito
                                        .elementAt(position)
                                        .prodcutoVenta
                                        .costo
                                        .toString()));
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
                                    padding: const EdgeInsets.only(left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          child: Text(
                                            listCarrito
                                                .elementAt(position)
                                                .prodcutoVenta
                                                .nombre,
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            Container(
                                              child: Text(
                                                '1x\$${listCarrito
                                                    .elementAt(position)
                                                    .prodcutoVenta
                                                    .costo}',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '${listCarrito
                                                    .elementAt(position)
                                                    .cantidad}',
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                '\$${listCarrito
                                                    .elementAt(position)
                                                    .prodcutoVenta
                                                    .costo * listCarrito
                                                    .elementAt(position)
                                                    .cantidad }',
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
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 100,
                padding: const EdgeInsets.only(top: 5, left: 20,),
                color: ColorsIndie.colorGC2.getColor(),
                child: Row(
                  children: [
                    Expanded(flex: 2, child:
                    Center(
                      child: Image.asset("assets/images/foro_ir_white.png",
                        height: 150,
                      ),
                    ),
                    ),
                    Expanded(flex: 2, child:
                    Center(
                      child: GestureDetector(
                      onTap: (){
                        removeCortesia();
                      },
                      child: Text("Remover \n cortesia"),
                      ),
                    ),
                    ),
                    /*Expanded(flex: 1,
                      child:
                      Center(
                          child: Switch(
                            value: banInventario, onChanged: (value) {
                            banInventario = value;

                            getProductos(banInventario);
                          },)
                      ),
                    ),*/

                  ],
                ),
              ),
            ],
          ),
          banGetProduct ? SizedBox(height: 0,) : Positioned(
            bottom: 0.0,
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
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
                            eventPayProduct();
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
                            child: Text("Cargar", style: TextStyle(
                                color: ColorsIndie.colorGC1.getColor())),
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
    /*final dialogContextCompleter = Completer<BuildContext>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        if(!dialogContextCompleter.isCompleted) {
          dialogContextCompleter.complete(dialogContext);
        }
        return  ProgressDialog(message: "Cargando...");;
      },
    );*/
    //dialogS = await dialogContextCompleter.future;
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
        //Navigator.pop(context);
        if (response.statusCode == 200) {
          // Si la llamada al servidor fue exitosa, analiza el JSON
          print(response.body);
          XmlDocument document = XmlDocument.parse(response.body);


          String res = document.findAllElements("getSKUResult").first.text;
          print('jsonPrint ${jsonDecode(res)}');
          resApi =  jsonDecode(res);
        } else {
          print("Error al realizar la solicitud");

          resApi = {
            'rcode':-1,
            'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde.'
          };

        }
      }, onError:(error) {
        print('Error1: $error');
        //Navigator.pop(context);
        resApi = {
          'rcode':-1,
          'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$error]'
        };

      });
    }
    catch( e){

      print('Error2: $e');
      //Navigator.pop(context);


      resApi=   {
        'rcode':-1,
        'msg': 'Error al procesar la solicitud. Intenta de nuevo mas tarde. [$e]'
      };
    }

    //print(response);
    return resApi;


  }

  void logout() {
    //Tools().saveUser("", "", "", "");
    DataBaseHelper.deleteLogin();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login() ));
  }

  Future<SimpleDialog> _MenuOptionsPay() async{
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


    print('Carrito Json: ${jsonCarrito.toString()}');
    print('Carrito Json MAP: $jsonCarritoMap');
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

                      var jsonEncriptCarrito = Encriptacion().encryptDataE('$jsonCarritoMap', Encriptacion.keyVersion);
                      //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto+propina, propina: propina, inventario: (!banInventario).toString(), modePayment: 1, banco: 1, referencia: "",),));
                      fetchAddCortesia(_codeV, _code, jsonEncriptCarrito).then((value) {
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
                          var jsonEncriptCarrito = Encriptacion().encryptDataE('$jsonCarritoMap', Encriptacion.keyVersion);

                          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(codigo: _code, codigoV: _codeV, codigoP: '$jsonCarritoMap', monto: monto+propina, propina: propina, inventario: (!banInventario).toString(), modePayment: 1,banco: 2, referencia: ""),));
                          fetchAddCortesia(_codeV, _code, '$jsonEncriptCarrito').then((value) {
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

  Future<SimpleDialog> _MenuOptionsPayCortesia() async{

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
  void eventAddProduct() {
    if(etCantidadControlloler.text.isEmpty || etCantidadControlloler.text == '0'){
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
      etCantidadControlloler.text = "0";
    });
  }

  Future<Map<String,dynamic>>  fetchAddCortesia(String codigoV, String codigo, String jsonCortseria) async {


    print("Init Balance");

    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <addCortesiaClient xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigo</codigo>
          <codigoC>$codigoC</codigoC>
          <codigoP>$jsonCortseria</codigoP>
        </addCortesiaClient>
      </soap:Body>
    </soap:Envelope>''';

    print(soap);
    showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    print("Init process 2");
    print('Responde: ${IndieService.addCortesiaClient.getURL()}');
    print('Responde: ${IndieService.addCortesiaClient.getSoapAction()}');
    final response =
    await http.post(Uri.parse( IndieService.addCortesiaClient.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.addCortesiaClient.getSoapAction(),
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
        String element = document.findAllElements("addCortesiaClientResponse").first.text;
        String? res = "0";
        if (element == ""){
          res = "0";
        }
        else{
          String res = document.findAllElements("addCortesiaClientResponse").first.text;
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
  Future<Map<String,dynamic>>  fetchRemoveCortesia(String codigoV, String codigo) async {


    print("Init Balance");

    String codigoC = Encriptacion().encryptDataE("${await DataBaseHelper.getValue(DBHelperItem.user.getValue())}|${await DataBaseHelper.getValue(DBHelperItem.pass.getValue())}", Encriptacion.keyVersion);

    String soap = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <removeSKUCortesia xmlns="http://tempuri.org/">
          <k>${Tools.keyIndie}</k>
          <codigoV>$codigoV</codigoV>
          <codigo>$codigo</codigo>
          <general_data>true</general_data>
        </removeSKUCortesia>
      </soap:Body>
    </soap:Envelope>''';

    print(soap);
    showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });

    print("Init process 2");
    print('Responde: ${IndieService.removeSKUCortesia.getURL()}');
    print('Responde: ${IndieService.removeSKUCortesia.getSoapAction()}');
    final response =
    await http.post(Uri.parse( IndieService.removeSKUCortesia.getURL()),
      headers: {
        'content-type': 'text/xml',
        'SOAPAction': IndieService.removeSKUCortesia.getSoapAction(),
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
        String element = document.findAllElements("removeSKUCortesiaResponse").first.text;
        String? res = "0";
        if (element == ""){
          res = "0";
        }
        else{
          String res = document.findAllElements("removeSKUCortesiaResponse").first.text;
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
  void eventPayProduct() {
    if(monto == 0){
      Tools().showMessageBox(context, "Carrito vacio. Debe seleccionar productos");
      return;
    }
    //_displayTextInputDialog(context);
    _MenuOptionsPay();
    //Navigator.of(context).push(MaterialPageRoute(builder: (context) => Payment(name: _name_code, user: _user_code, pass: _pass_code, banco: _banco, monto: monto),));
  }


  Future<void> _displayTextInputDialog(BuildContext context) async {
    etPropinaController = TextEditingController(text: '\$0');
    banInventario = false;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('¿Deseas agregar Propina?'),
            content: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children:  [
                    Text('Selecciona una de las opciones.'),
                    Row(
                      children: [

                        Container(
                          width: MediaQuery.of(context).size.width/3.5,
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

                            print('Monto : $monto');
                            print('Propina seleccionada : 0.05');
                            propina = monto * 0.05;
                            print('Propina : $propina');
                            Navigator.of(context).pop();
                            _MenuOptionsPay();
                          },
                            style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                ),
                                backgroundColor: ColorsIndie.colorgris.getColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )
                            ),
                            child: const Text("5%"),
                          ),

                        ),
                        Container(
                          width: MediaQuery.of(context).size.width/3.5,
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
                            propina = monto * 0.10;
                            print('Propina : $propina');
                            Navigator.of(context).pop();
                            _MenuOptionsPay();
                          },
                            style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                ),
                                backgroundColor: ColorsIndie.colorgris.getColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )
                            ),
                            child: const Text("10%"),
                          ),

                        ),
                      ],
                    ),
                    Row(
                      children: [

                        Container(
                          width: MediaQuery.of(context).size.width/3.5,
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
                            propina = monto * 0.15;
                            print('Propina : $propina');
                            Navigator.of(context).pop();
                            _MenuOptionsPay();
                          },
                            style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                ),
                                backgroundColor: ColorsIndie.colorgris.getColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )
                            ),
                            child: const Text("15%"),
                          ),

                        ),
                        Container(
                          width: MediaQuery.of(context).size.width/3.5,
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
                            propina = monto * 0.20;
                            print('Propina : $propina');
                            Navigator.of(context).pop();
                            _MenuOptionsPay();
                          },
                            style: ElevatedButton.styleFrom(
                                textStyle: TextStyle(color: ColorsIndie.colorGC1.getColor(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                ),
                                backgroundColor: ColorsIndie.colorgris.getColor(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )
                            ),
                            child: const Text("20%"),
                          ),

                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Text('Ingresa tu propina en pesos'),

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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CurrencyTextInputFormatter.currency(locale: 'en', symbol: '\$'),
                        ],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                            hintText: "\$00.00",
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
                  ],
                )
            )
            /*TextField(
              controller: etTextAlert,
              keyboardType: TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(hintText: "Ingresa tu propina"),
            */,
            actions: <Widget>[
              /*TextButton(onPressed: () async {
                if(etPropinaController.text.isEmpty){
                  Tools().showMessageBox(context, "Debe ingresar un monto valido para su propina.");
                  return;
                }
                print(etPropinaController.text);
                String prop = etPropinaController.text.toString();
                propina = double.parse(prop.replaceAll('\$', '').replaceAll(',', ''));
                print(propina);
                Navigator.of(context).pop();
                inventario = "2";
                _MenuOptionsPay();
              },
                  child: Text("Mi inventario")
              ),*/
              TextButton(onPressed: () async {
                if(etPropinaController.text.isEmpty){
                  Tools().showMessageBox(context, "Debe ingresar un monto valido para su propina.");
                  return;
                }
                print(etPropinaController.text);
                String prop = etPropinaController.text.toString();
                propina = double.parse(prop.replaceAll('\$', '').replaceAll(',', ''));
                print(propina);
                inventario = "1";
                Navigator.of(context).pop();
                _MenuOptionsPay();
              },
                  child: Text("Continuar")
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

  void removeCortesia() {
    _MenuOptionsPayCortesia();
  }


}