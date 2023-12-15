


import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:indierocks_cubetero/domain/repositories/inetwork_manager_repository.dart';

class NetworkRepository extends INetworkManagerRepository{
  NetworkRepository();

  @override
  Future<bool> isConnected() async {
    //bool connected = false;
    print('Inicio de Validar wifi');
    Connectivity connectivity = Connectivity();
    late ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
      print('Wifi RESULT ${result}');
      if (result == ConnectivityResult.none){
        return false;
      }
      else{
        return true;
      }
    } on PlatformException catch (e) {
      print('Wifi EXCEPTION ${e.message}');
      return false;
    }
  }

}