

abstract class IEncriptionMd5Repository{

  String encryptData(String data, String _key);

  String desencryptData(String data, String _key);
}