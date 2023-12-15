

import 'package:indierocks_cubetero/ui/enum/enum_permisos.dart';
import 'package:permission_handler/permission_handler.dart';

class PermisosHelper{
  Future<bool> helperPermisos(PermisosType type){
    switch(type){
      case PermisosType.CAMERA:
        return _permiososCamera();
      case PermisosType.NFC:
        return _permiososNFC();
      default:
        return _permiososCamera();
    }
  }

  Future<bool> _permiososCamera() async {
    var status = await Permission.camera.status;

    if (!status.isGranted) {
      // Si no se tienen permisos, solicitarlos
      status = await Permission.camera.request();

      if (status.isDenied) {
        // Si se niegan los permisos, mostrar un mensaje al usuario
        return false;
      }
      else{
        return true;
      }
    } else {
      return true;
    }
  }

  Future<bool> _permiososNFC() async {
    // Lógica para escanear un QR
    // Simulando un escaneo de QR
    await Future.delayed(Duration(seconds: 2));
    return false;
  }
}