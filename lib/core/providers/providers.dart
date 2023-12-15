



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/env/Enviroments.dart';
import 'package:indierocks_cubetero/core/providers/get_cortesia/get_cortesia_state.dart' as getCortesiasState;
import 'package:indierocks_cubetero/core/providers/get_options_cortesia/get_options_cortesia_state.dart' as getOptionsCortesiaState;
import 'package:indierocks_cubetero/core/providers/get_productos/get_productos_state.dart' as getProductosState;
import 'package:indierocks_cubetero/data/datasources/remote/http_data_source.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/data/repositories/encriptation_md5_repository.dart';
import 'package:indierocks_cubetero/data/repositories/network_repository.dart';
import 'package:indierocks_cubetero/data/repositories/qr_scan_repository.dart';
import 'package:indierocks_cubetero/data/repositories/user_repository.dart';
import 'package:indierocks_cubetero/data/repositories/version_app_repository.dart';
import 'package:indierocks_cubetero/domain/use_cases/user_uses_case.dart';
import 'package:http/http.dart' as http;


part 'get_cortesia/get_cortesia_notifier.dart';
part 'get_productos/get_productos_notifier.dart';
part 'get_options_cortesia/get_options_cortesia_notifier.dart';


final userLogued = StateProvider<UserModel?>(
  (ref) {
    return null;
  },
);


final _userRepository = Provider<UserRepository>((ref){
  return UserRepository(
      networkManager: NetworkRepository(),
      remoteDataSource: HttpDataSource(
          client: http.Client(),
          url: Enviroments.URL_BASE,
          keyAccess: Enviroments.keyIndie
      ),
      encriptionMd5Repository: EncriptationMd5Repository(),
      versionAppRepository: VersionAppRepository(),
      keyIdVer: Enviroments.keyIdVer,
      keyVersion: Enviroments.keyVersion,
      qrScanRepository: QrScanRepository());
});

final getCortesiaNotifier = StateNotifierProvider<GetCortesiaClientNotifier,getCortesiasState.GetCortesiaState>(
    (ref) {
      return GetCortesiaClientNotifier(getCortesiasCliente: ref.watch(_getCortesiasCliente));
    },
);

final getProductosNotifier = StateNotifierProvider<GetProductosNotifier, getProductosState.GetProdcutosState>(
  (ref) {
    return GetProductosNotifier(getProductos: ref.watch(_getProductos));
  },
);

final getOptionsCortesiaNotifier = StateNotifierProvider<GetOptionsCortesiaNotifier, getOptionsCortesiaState.GetOptionsCortesiaState>(
      (ref) {
    return GetOptionsCortesiaNotifier(getOptionsCortesia: ref.watch(_getOptionsCortesia));
  },
);



final _getCortesiasCliente = Provider<GetCortesiasCliente>((ref) {
  return GetCortesiasCliente(repository: ref.watch(_userRepository));
});

final _getProductos = Provider<GetProductos>((ref) {
  return GetProductos(repository: ref.watch(_userRepository));
},);

final _getOptionsCortesia = Provider<GetOptionsCortesia>((ref) {
  return GetOptionsCortesia(repository: ref.watch(_userRepository));
},);