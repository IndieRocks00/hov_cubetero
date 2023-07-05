import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:indierocks_cubetero/Utils/ServiceWS.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xml/xml.dart';

import 'Principal.dart';
import 'Utils/DataBaseHelper.dart';
import 'Utils/Encriptacion.dart';
import 'Utils/Model/LoginModel.dart';
import 'Utils/ProgressDialog.dart';
import 'Utils/Tools.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final etUserController = TextEditingController();
  final etPassController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }
  @override
  void dispose() {
    // TODO: implement dispose
    etPassController.dispose();
    etUserController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    getUser();

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset("assets/images/foro_ir_white.png",
                    width: MediaQuery.of(context).size.width-100,
                    height: 200,
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(left: 40,right: 40),
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
                    controller: etUserController,
                    maxLines: 1,
                    decoration: InputDecoration(
                        hintText: "Usuario",
                        filled: true,
                        fillColor: ColorsIndie.colorGC3.getColor(),
                        prefixIcon: const Icon(Icons.person),
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
                Container(
                  margin: const EdgeInsets.only(left: 40,right: 40, top: 25),
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
                    controller: etPassController,
                    maxLines: 1,
                    obscureText: true,
                    decoration: InputDecoration(
                        hintText: "Contraseña",
                        filled: true,
                        fillColor: ColorsIndie.colorGC3.getColor(),
                        prefixIcon: const Icon(Icons.lock),
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
                Container(
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
                    eventLogin();
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
                    child: const Text("Iniciar Sesión"),
                  ),

                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  getUser() async {
    String data_user = await DataBaseHelper.getValue(DBHelperItem.user.getValue());
    if(!data_user.toString().isEmpty || data_user != ""){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PrincipalActivity()));
    }
  }
  eventLogin()  {


    var _user = etUserController.text;
    var _pass = etPassController.text;
    if(_user.isEmpty){
      Tools().showMessageBox(context,"Campo de usuario vacio. Verifique");
      return;
    }
    if(_pass.isEmpty){
      Tools().showMessageBox(context,"Campo de contraseña vacio. Verifique");
      return;
    }

    /*showDialog(context: context, builder: (c){
      return ProgressDialog(message: "Cargando...");
    });*/

    ServiceWS.fetchLogin(_user, _pass, context).then((value) async {
      print('Res Login: $value');
      switch(value['rcode']){
        case -1:
          Tools().showMessageBox(context,value['msg']);
          break;

        case 0:
          var msgDesc = Encriptacion().decryptDataD(value['msg']!, Encriptacion.keyVersion);
          var msgArr = msgDesc.split('|');
          String nameUser = msgArr[0];
          String balance = msgArr[1];
          print('MSG: $msgDesc');
          print('Nombre: $nameUser');
          print('Balance: $balance');
          //Tools().saveUser(_user, _pass, nameUser, balance);

          DataBaseHelper.saveLogin(LoginModel( _user, _pass, balance, nameUser)).then((value) {

            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>PrincipalActivity()));
          },);
          break;
        case 1:
          Tools().showMessageBox(context,'Credenciales no validas');
          break;
        default:

          Tools().showMessageBox(context,'Credenciales no validas[1]');
          break;
      }
    });
  }



}


