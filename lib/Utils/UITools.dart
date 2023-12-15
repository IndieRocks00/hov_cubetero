
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/AddCortesia.dart';
import 'package:indierocks_cubetero/ConsultarBalance.dart';
import 'package:indierocks_cubetero/CortesiaCliente.dart';
import 'package:indierocks_cubetero/Orders.dart';
import 'package:indierocks_cubetero/Transactions.dart';
import 'package:indierocks_cubetero/AddCortesiaV2.dart';

import '../Principal.dart';
import '../PuntoVenta.dart';
import 'DataBaseHelper.dart';
import 'Tools.dart';

class UITools{


  static Widget getMenulateral(BuildContext context){
    return Drawer(

      width: MediaQuery.of(context).size.width/1.8,
      child: ListView(
        padding: EdgeInsets.only(left: 10, top: 40),
        children: [
          /*ListTile(
            title: Text("Principal"),
            leading: Icon(Icons.home),
            onTap: (){

              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PrincipalActivity(),), (route) => false);
            },
          ),*/
          /*ListTile(
            title: Text("Punto de Venta"),
            leading: Icon(Icons.home),
            onTap: (){

              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PuntoVentaActivity(),), (route) => false);
            },
          ),*/
          /*ListTile(
            title: Text("Lista de Ordenes"),
            leading: Icon(Icons.home),
            onTap: (){

              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => OrderActivity(),), (route) => false);
            },
          ),*/
          ListTile(
            title: Text("Consultar Balance"),
            leading: Icon(Icons.credit_card),
            onTap: (){
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ConsultarBalance(),), (route) => false);
            },
          ),

          /*ListTile(
            title: Text("Transacciones"),
            leading: Icon(Icons.credit_card),
            onTap: (){
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TransactionsActivity(),), (route) => false);
            },
          ),*/
          ListTile(
            title: Text("Cortesias"),
            leading: Icon(Icons.credit_card),
            onTap: (){
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => PCortesia(),), (route) => false);
            },
          ),
          ListTile(
            title: Text("Cargar Cortesias"),
            leading: Icon(Icons.credit_card),
            onTap: () async {

              String name =  await DataBaseHelper.getValue(DBHelperItem.user.getValue());
              name = 'hov_cortesias';
              if(name == 'hov_cortesias'){
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => AddCortesiaV2(),), (route) => false);

              }
              else{
                Tools().showMessageBox(context, "No tienes acceso a este modulo");
              }
            },
          ),
          ListTile(
            title: Text("Cerrar Sesión"),
            leading: Icon(Icons.logout),
            onTap: (){
              Tools.logout(context);
            },
          ),
        ],
      ),
    );
  }


  static AppBar getAppBar(BuildContext context, String _name){
    return AppBar(title: Text("CUBETERO",
      style: TextStyle(color: Colors.white,)),
      backgroundColor: ColorsIndie.colorGC1.getColor() ,
      bottom: PreferredSize(
        preferredSize: Size.zero,
        child: Container(
          margin: EdgeInsets.only(left: 65),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.centerLeft,
          child: Text(_name,
            style: TextStyle(color: ColorsIndie.colorGC2.getColor(),fontSize: 18 ),
            textAlign: TextAlign.left,),),
      ),
    );
  }
}