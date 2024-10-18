
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/colors/AppColors.dart';
import 'package:indierocks_cubetero/core/providers/providers.dart';
import 'package:indierocks_cubetero/core/providers/sql/sql_provider.dart';
import 'package:indierocks_cubetero/core/routes/AppRoute.dart';

import '../../Utils/Tools.dart';

class MenuDrawerApp extends ConsumerStatefulWidget {

  const MenuDrawerApp({Key? key}) : super(key: key);

  @override
  MenuDrawerAppState createState() => MenuDrawerAppState();
}

class MenuDrawerAppState extends ConsumerState<MenuDrawerApp> {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background_general_second,
      width: MediaQuery.of(context).size.width/1.8,
      child: Column(
        children: [
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                title: const Text("Principal"),
                leading: const Icon(Icons.home),
                onTap: (){

                  Navigator.pushReplacementNamed(context, AppPageRoutes.HOME.getPage());
                },
              ),
              ListTile(
                title: const Text("Consultar Balance"),
                leading: const Icon(Icons.credit_card),
                onTap: (){
                  Navigator.pushReplacementNamed(context, AppPageRoutes.CONSULTAR_BALANCE.getPage());
                  //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ConsultarBalance(),), (route) => false);
                },
              ),
              ListTile(
                title: const Text("Agregar Cortesias"),
                leading: const Icon(Icons.add_circle),
                onTap: (){

                  var userOperativo = ref.read(userLogued.notifier).state;
                  //name = 'hov_cortesias';
                  if(userOperativo?.user == 'hov_cortesias'){

                    Navigator.pushReplacementNamed(context, AppPageRoutes.ADD_CORTESIAS.getPage());
                  }
                  else{
                    Tools().showMessageBox(context, "No tienes acceso a este modulo");
                  }
                  //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ConsultarBalance(),), (route) => false);
                },
              ),

              ListTile(
                title: const Text("Pulseras"),
                leading: const Icon(Icons.nfc),
                onTap: (){

                  var userOperativo = ref.read(userLogued.notifier).state;
                  //name = 'hov_cortesias';
                  if(userOperativo?.user == 'hov_cortesias'){

                    Navigator.pushReplacementNamed(context, AppPageRoutes.TOKEN_PULSERAS.getPage());
                  }
                  else{
                    Tools().showMessageBox(context, "No tienes acceso a este modulo");
                  }
                  //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ConsultarBalance(),), (route) => false);
                },
              ),
              ListTile(
                title: const Text("Boletos"),
                leading: const Icon(Icons.turned_in_outlined),
                onTap: (){


                  Navigator.pushReplacementNamed(context, AppPageRoutes.VALIDAR_BOLETO.getPage());
                  //Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => ConsultarBalance(),), (route) => false);
                },
              ),
            ],
          ),
          const Spacer(),
          ListTile(
            title: const Text("Cerrar Sesión"),
            leading: const Icon(Icons.logout),
            onTap: (){

              ref.read(userLogued.notifier).state = null;
              ref.read(sqlUserNotifier.notifier).logout();

              Navigator.pushReplacementNamed(context, AppPageRoutes.LOGIN.getPage());
            },
          ),
        ],
      ),
    );
  }
}
