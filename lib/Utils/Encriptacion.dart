
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_des/dart_des.dart';

class Encriptacion{

  static String keyIdVer = 'Ym49P?t2fEw/@4Ni)[#V\$M';
  static String keyVersion = 'AVbqwVz:U%,k33;}nrTdfH?}:PX&';

  String encryptDataE(String data, String _key) {
    final message  = data;
    var bytes = List<int>.from(utf8.encode(message));
    var key = md5.convert(utf8.encode(_key)).bytes; //The key is any letters
    DES3 mDes3CBC = DES3(
      key: key,
      mode: DESMode.ECB,
      paddingType: DESPaddingType.PKCS7,
    );
    final encrypted = mDes3CBC.encrypt(bytes);
    String value = base64Encode(encrypted);

    print(value);
    return value;
  }

  String decryptDataD(String _plainText, String _key) {
    String plainText = _plainText;
    var bytes = base64.decode(plainText);
    var key = md5.convert(utf8.encode(_key)).bytes; //The key is any letters
    DES3 mDes3CBC = DES3(
      key: key,
      mode: DESMode.ECB,
      paddingType: DESPaddingType.PKCS7,
    );
    final decrypt= mDes3CBC.decrypt(bytes);
    String value = utf8.decode(decrypt);
    return value;
  }
}