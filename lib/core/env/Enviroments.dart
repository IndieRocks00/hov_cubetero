

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enviroments{
  static String URL_BASE = dotenv.get('URL_BASE');
  static String URL_TRANSACT = '$URL_BASE/transact.asmx';
  static String URL_WSIR = '$URL_BASE/wsIRC/wsCL.asmx';
  static String keyIndie = dotenv.get('keyIndie');
  static String keyIdVer = dotenv.get('keyIdVer');
  static String keyVersion = dotenv.get('keyVersion');

  static String access_token_mp = dotenv.get('access_token_mp');
}