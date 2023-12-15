

import 'package:indierocks_cubetero/data/repositories/network_repository.dart';

abstract class INetworkManagerRepository{

  Future<bool> isConnected();
}