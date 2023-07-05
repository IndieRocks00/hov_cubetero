import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/Login.dart';
import 'package:indierocks_cubetero/Utils/Model/ProductoModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataBaseHelper.dart';
import 'Model/CategoriaModel.dart';
import 'Tools.dart';
import 'Tools.dart';

class Tools{


  static String user = "cubetero9";
  static String pass = "24d7Hr";


  static String keyIndie = r'iut4$5d0218';
  static String mp_clientID = "2417310623023383";
  static String mp_clientSecret = "mW7DjigeD0qcC2s6vGe4dUtdR0ke5Wss";

  //key public Pruebas
  //static String accesToken = "TEST-2417310623023383-081317-5dd8c4e2a684292e53a8fe7b460f5f8b-624415656";
  //static String publicKey = "TEST-70f06bb1-58b5-4840-9f36-387f1dbb9742";

  //Ke public Producción
  static String accesToken = "APP_USR-2417310623023383-081317-eef49e55edb8fcba98df612c53a30d97-624415656";
  static String publicKey = "APP_USR-16a0b94b-ddc4-4024-a923-09f8430ad0a2";


  showMessageBox(BuildContext context, String text){
    AlertDialog dialog = AlertDialog(
      content: Text(text),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();
        },
            child: Text("Aceptar")),
      ],
    );
    showDialog(context: context,
        barrierDismissible: false, builder: (BuildContext context){
      return dialog;
    });
  }
  static Color getColorStatusBarra(status){
    print('Cambio de status : $status');
    switch(status){
    //Preparación
      case "2":
        return ColorsIndie.colorAmarillo.getColor();
      case "4":
        return ColorsIndie.colorVerde.getColor();
      default:
        return ColorsIndie.colorAmarillo.getColor();
    }
  }

  static logout(context) {
    DataBaseHelper.deleteLogin();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login() ));
  }

  List<CategoriaModel> getCategorias(){
    List<CategoriaModel> list = [];
    list.add(CategoriaModel(nombre: Categoria.prod1.getName(), index: 0));
    list.add(CategoriaModel(nombre: Categoria.prod2.getName(), index: 1));
    list.add(CategoriaModel(nombre: Categoria.prod3.getName(), index: 2));
    list.add(CategoriaModel(nombre: Categoria.prod4.getName(), index: 3));
    list.add(CategoriaModel(nombre: Categoria.prod5.getName(), index: 4));
    list.add(CategoriaModel(nombre: Categoria.prod6.getName(), index: 5));
    return list;
  }
  /*
  List<ProdcutoVenta> getProdcutos(CategoriaModel cat){
    List<ProdcutoVenta> list = [];
    switch(cat.index){
    //Alimentos
      case 0:
        list.add( ProdcutoVenta(nombre: "CONSOME DE BIRRIA", costo: 35,categoria: 0, sku: '0260019000035A', ));
        list.add( ProdcutoVenta(nombre: "QUESABIRRIA", costo: 70,categoria: 0, sku: '0260019000070A'));
        list.add( ProdcutoVenta(nombre: "PAQUETE QUESABIRRI Y CONSOME", costo: 90,categoria: 0, sku: '0260019000090A'));
        list.add( ProdcutoVenta(nombre: "TACO AL PASTOS", costo: 25,categoria: 0, sku: '0260019000025A'));
        list.add( ProdcutoVenta(nombre: "PAQUETE 2 TACOS AL PASTOR", costo: 60,categoria: 0, sku: '0260019000060A'));
        list.add( ProdcutoVenta(nombre: "GRINDA DE PASTOR", costo: 70,categoria: 0, sku: '0260019000070B'));
        list.add( ProdcutoVenta(nombre: "QUESARRES", costo: 70,categoria: 0, sku: '0260019000070C'));
        list.add( ProdcutoVenta(nombre: "TACO DE BIRRIA DE RES", costo: 45,categoria: 0, sku: '0260019000045A'));
        list.add( ProdcutoVenta(nombre: "TACO DE RES", costo: 45,categoria: 0, sku: '0260019000045B'));
        list.add( ProdcutoVenta(nombre: "TACO DE COCHINITA PIBIL", costo: 45,categoria: 0, sku: '0260019000045C'));
        list.add( ProdcutoVenta(nombre: "QUESADILLA", costo: 35,categoria: 0, sku: '0260019000035B'));
        break;

      case 1:
        list.add( ProdcutoVenta(nombre: "DOGO SENCILLO",  costo: 85,categoria: 1, sku: ''));
        list.add( ProdcutoVenta(nombre: "DOGO CON CHILLI TEXANO",  costo: 105,categoria: 1, sku: ''));
        list.add( ProdcutoVenta(nombre: "NACHOS CON QUESO",  costo: 75,categoria: 1, sku: ''));
        list.add( ProdcutoVenta(nombre: "NACHOS CON CHILLI TEXANO",  costo: 105,categoria: 1, sku: ''));
        list.add( ProdcutoVenta(nombre: "PAPAS A LA FRANCESA",  costo: 65,categoria: 1, sku: ''));
        list.add( ProdcutoVenta(nombre: "PAPAS A LA FRANCESA CON QUESO",  costo: 75,categoria: 1, sku: ''));
        list.add( ProdcutoVenta(nombre: "PAPAS A LA FRANCESA CON CHILLI TEXANO", costo:  105,categoria: 1, sku: ''));
        list.add( ProdcutoVenta(nombre: "ESQUITES SENCILLOS",  costo: 45,categoria: 1, sku: ''));
        list.add( ProdcutoVenta(nombre: "ESQUITES CON PAPAS",  costo: 75,categoria: 1, sku: ''));
        break;

      case 2:
        list.add( ProdcutoVenta(nombre: "CORONO", costo:125,categoria:2, sku: ''));
        list.add( ProdcutoVenta(nombre: "VICTORIA", costo:125,categoria:2, sku: ''));
        break;

      case 3:
        list.add( ProdcutoVenta(nombre: "STELA", costo:95,categoria:3, sku: ''));
        list.add( ProdcutoVenta(nombre: "HOMBRE PAJARO", costo:115,categoria:3, sku: ''));
        list.add( ProdcutoVenta(nombre: "SUPER LUPE", costo:125,categoria:3, sku: ''));
        break;

      case 4:
        list.add( ProdcutoVenta(nombre: "AGUA", costo:55,categoria:4, sku: ''));
        list.add( ProdcutoVenta(nombre: "COCA COLA", costo:55,categoria:4, sku: ''));
        list.add( ProdcutoVenta(nombre: "COCA ZERO", costo:55,categoria:4, sku: ''));
        break;

      case 5:
        list.add( ProdcutoVenta(nombre: "RON BACARDI SENCILLO", costo:125,categoria:5, sku: ''));
        list.add( ProdcutoVenta(nombre: "RON BACARDI DOBLE", costo:225,categoria:5, sku: ''));
        list.add( ProdcutoVenta(nombre: "RON BACARDI BOTELLA", costo:1800,categoria:5, sku: ''));
        list.add( ProdcutoVenta(nombre: "RON HAVANA 7 SENCILLO", costo:145,categoria:5, sku: ''));
        list.add( ProdcutoVenta(nombre: "RON HAVANA 7 DOBLE", costo:265,categoria:5, sku: ''));
        list.add( ProdcutoVenta(nombre: "RON HAVANA 7 BOTELLA", costo:2000,categoria:5, sku: ''));
        list.add( ProdcutoVenta(nombre: "VODKA SMIRNOF SENCILLO", costo:125,categoria:5, sku: ''));
        list.add( ProdcutoVenta(nombre: "VODKA SMIRNOF DOBLE", costo:225,categoria:5, sku: ''));
        list.add( ProdcutoVenta(nombre: "VODKA SMIRNOF BOTELLA", costo:1800,categoria:5, sku: ''));
        break;

      default:
        list = [];
    }
    return list;
  }*/


}
enum IndieService{
  keyIndie,
  getTRequestID,
  venta,
  qr,
  mercado_pago,
  ilg,
  balance,
  sell,
  sellPV,
  getTerminalPayment,
  validatePaymentTerminal,
  cancelTerminalPayment,
  getListorderPay,
  rollBPedido,
  setstatusBarra,
  addProdcuctsOrderPay,
  addCortesiaClient,
  getSKUCortesia,
  sellCortesia,

  getSKU,
  getTXN,
  getTXNCub
}

extension IndieServiceExtension on IndieService{
  //static const URL_SERVER = "http://indierocks.ddns.net/indierocks";
  static const URL_SERVER = "http://turbocarga.ddns.net/indierocks";
  //static const URL_SERVER = "http://192.168.1.74/indierocks";
  //static const URL_SERVER = "http://indierockss.ddns.net:9090/";
  static const ComplementSoapAction = "http://tempuri.org";
  String getURL(){
    switch (this){
      case IndieService.keyIndie:
        return  r"iut4$5d0218";
      case IndieService.getTRequestID:
        return  "$URL_SERVER/transact.asmx";
      case IndieService.venta:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.qr:
        return "$URL_SERVER/zdroid/droid.asmx";
      case IndieService.mercado_pago:
        return "https://api.mercadopago.com/checkout/preferences?access_token=";
      case IndieService.ilg:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.balance:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.sell:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.getSKU:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.getTXN:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.getTXNCub:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.sellPV:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.getTerminalPayment:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.validatePaymentTerminal:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.cancelTerminalPayment:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.getListorderPay:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.rollBPedido:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.setstatusBarra:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.addProdcuctsOrderPay:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.addCortesiaClient:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.getSKUCortesia:
        return "$URL_SERVER/wsIRC/wsCL.asmx";
      case IndieService.sellCortesia:
        return "$URL_SERVER/wsIRC/wsCL.asmx";


      default:
        return URL_SERVER;
    }
  }

  String getSoapAction(){
    switch (this){
      case IndieService.getTRequestID:
        return  "$ComplementSoapAction/GetTRequestID";
      case IndieService.venta:
        return "$ComplementSoapAction/payment";
      case IndieService.qr:
        return "$ComplementSoapAction/qr";
      case IndieService.ilg:
        return "$ComplementSoapAction/ilg";
      case IndieService.balance:
        return "$ComplementSoapAction/detailB";
      case IndieService.sell:
        return "$ComplementSoapAction/sell";
      case IndieService.getSKU:
        return "$ComplementSoapAction/getSKU";
      case IndieService.getTXN:
        return "$ComplementSoapAction/getTXN";
      case IndieService.getTXNCub:
        return "$ComplementSoapAction/getTXNCub";
      case IndieService.sellPV:
        return "$ComplementSoapAction/sellPV";
      case IndieService.getTerminalPayment:
        return "$ComplementSoapAction/getTerminalPayment";
      case IndieService.validatePaymentTerminal:
        return "$ComplementSoapAction/validatePaymentTerminal";
      case IndieService.cancelTerminalPayment:
        return "$ComplementSoapAction/cancelTerminalPayment";
      case IndieService.getListorderPay:
        return "$ComplementSoapAction/getListorderPay";
      case IndieService.rollBPedido:
        return "$ComplementSoapAction/rollBPedido";
      case IndieService.setstatusBarra:
        return "$ComplementSoapAction/setStatusBarra";
      case IndieService.addProdcuctsOrderPay:
        return "$ComplementSoapAction/addProdcuctsOrderPay";
      case IndieService.addCortesiaClient:
        return "$ComplementSoapAction/addCortesiaClient";
      case IndieService.getSKUCortesia:
        return "$ComplementSoapAction/getSKUCortesia";
      case IndieService.sellCortesia:
        return "$ComplementSoapAction/sellCortesia";

      default:
        return URL_SERVER;
    }
  }
}

enum ColorsIndie{
  colorGC1 ,
  colorGC2 ,
  colorGC3 ,
  colorSec1 ,
  colorSec2 ,
  colorSec3 ,
  colorSec4 ,
  colorSec5 ,
  colorSec6,
  colorgris,

  colorAmarillo,
  colorVerde
}

extension ColorsIndieExtension on ColorsIndie{
  Color getColor(){
    switch (this){
      case ColorsIndie.colorGC1:
        return const Color(0xff000000);
      case ColorsIndie.colorGC2:
        return const Color(0xffFFFFFF);
      case ColorsIndie.colorGC3:
        return const Color(0xff79DEA8);

      case ColorsIndie.colorSec1:
        return const Color(0xff6DF2A6);
      case ColorsIndie.colorSec2:
        return const Color(0xff6FCFEB);
      case ColorsIndie.colorSec3:
        return const Color(0xff79A3DC);
      case ColorsIndie.colorSec4:
        return const Color(0xffB980D0);
      case ColorsIndie.colorSec5:
        return const Color(0xffFF4438);
      case ColorsIndie.colorSec6:
        return const Color(0xffE577CB);
      case ColorsIndie.colorgris:
        return const Color(0xff93969E);
      case ColorsIndie.colorAmarillo:
        return const Color(0xfffcce14);
      case ColorsIndie.colorVerde:
        return const Color(0xff8cff00);
      default:
        return const Color(0xff000000);
    }
  }

}


enum Categoria{
  prod1 ,
  prod2 ,
  prod3 ,
  prod4 ,
  prod5 ,
  prod6 ,
}

extension CategoriaExtension on Categoria{
  String getName(){
    switch (this){
      case Categoria.prod1:
        return  "Alimentos";
      case Categoria.prod2:
        return  "Snacks";
      case Categoria.prod3:
        return  "Cerveza Doble";
      case Categoria.prod4:
        return  "Cerveza Artesanal";
      case Categoria.prod5:
        return  "Hidratación";
      case Categoria.prod6:
        return  "Alcohol";

      default:
        return "";
    }
  }
}