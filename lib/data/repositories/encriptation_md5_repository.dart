

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_des/dart_des.dart';
import 'package:indierocks_cubetero/domain/repositories/iencription_md5_repository.dart';

class EncriptationMd5Repository implements IEncriptionMd5Repository{



  @override
  String desencryptData(String data, String _key) {
    var bytes = base64.decode(data);
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

  @override
  String encryptData(String data, String _key) {
    final message  = data;
    var bytes = new List<int>.from(utf8.encode(message));
    var key = md5.convert(utf8.encode(_key)).bytes; //The key is any letters
    DES3 mDes3CBC = DES3(
      key: key,
      mode: DESMode.ECB,
      paddingType: DESPaddingType.PKCS7,
    );
    final encrypted = mDes3CBC.encrypt(bytes);
    String value = base64Encode(encrypted);

    //print(value);
    return value;
  }

}