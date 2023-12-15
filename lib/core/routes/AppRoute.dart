


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/ConsultarBalance.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/ui/pages/add_cortesias_screen.dart';
import 'package:indierocks_cubetero/ui/pages/consultar_balance_screen.dart';
import 'package:indierocks_cubetero/ui/pages/home_screen.dart';
import 'package:indierocks_cubetero/ui/pages/login_screen.dart';
import 'package:indierocks_cubetero/ui/pages/payment_result_screen.dart';
import 'package:indierocks_cubetero/ui/pages/productos_screen.dart';
import 'package:indierocks_cubetero/ui/pages/splash_screen.dart';
import 'package:indierocks_cubetero/ui/pages/venta_result_screen.dart';

enum AppPageRoutes{
  SPLSH,
  LOGIN,
  HOME,
  PAYMENT_RESULT,
  CONSULTAR_BALANCE,
  PRODUCTS,
  VENTA_RESULT,
  ADD_CORTESIAS,
}
extension AppPageRoutesExtension on AppPageRoutes{
  getPage(){
    switch(this){
      case AppPageRoutes.SPLSH:
        return '/';
      case AppPageRoutes.LOGIN:
        return '/login';
      case AppPageRoutes.HOME:
        return '/home';
      case AppPageRoutes.PAYMENT_RESULT:
        return '/paymet_result';
      case AppPageRoutes.CONSULTAR_BALANCE:
        return '/consultar_balance';
      case AppPageRoutes.PRODUCTS:
        return '/products';
      case AppPageRoutes.VENTA_RESULT:
        return '/venta_result';
      case AppPageRoutes.ADD_CORTESIAS:
        return '/add_cortesias';
      default:
        return "";
    }
  }
}

class AppRouter{


  Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/paymet_result':
        var args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => PaymentResultScreen(
            resTransaction: args['resTransaction'],
            banco: args['banco'],
            monto: args['monto'],
          )
        );
      case '/consultar_balance':
        return MaterialPageRoute(builder: (_) => const ConsultaBalanceScreen());
      case '/products':
        var args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => ProductosScreen(
          cortesias: args['cortesias'],
        ));
      case '/venta_result':
        var args = settings.arguments as Map<String, dynamic>;
        print(args);
        return MaterialPageRoute(builder: (_) => VentaResultScreen(
            resTransaction: args['resTransaction'],
            banco: args['banco'],
            monto: args['monto'],
            listCompra: args['listCompra'],
          )
        );
      case '/add_cortesias':
        return MaterialPageRoute(builder: (_) => AddCortesiasScreen());
    // Agrega más rutas aquí según tu aplicación
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Ruta desconocida: ${settings.name}'),
            ),
          ),
        );
    }
  }
}