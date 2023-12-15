
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'package:indierocks_cubetero/domain/repositories/iqr_scan_repository.dart';

class QrScanRepository implements IQrScanRepository{
  @override
  Future<String?> scannQR() async {
    if (Permission.camera.status != PermissionStatus.granted){
      if (await Permission.camera.request().isDenied) {

      }
    }
    return scanner.scan();
  }

}