


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/env/Enviroments.dart';
import 'package:indierocks_cubetero/core/providers/api/api_state.dart';
import 'package:indierocks_cubetero/data/datasources/remote/http_data_source.dart';
import 'package:indierocks_cubetero/data/datasources/remote/sql_data_source.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/repositories/encriptation_md5_repository.dart';
import 'package:indierocks_cubetero/data/repositories/network_repository.dart';
import 'package:indierocks_cubetero/data/repositories/qr_scan_repository.dart';
import 'package:indierocks_cubetero/data/repositories/sql_data_repository.dart';
import 'package:indierocks_cubetero/data/repositories/user_repository.dart';
import 'package:indierocks_cubetero/data/repositories/version_app_repository.dart';
import 'package:indierocks_cubetero/domain/use_cases/user_uses_case.dart';
import 'package:http/http.dart' as http;

export 'api_state.dart' show Initial, Loading, ApiAvailable, Error;

part 'api_state_notifier.dart';


final apiNotiier = StateNotifierProvider<ApiStateNotifier,ApiState>((ref){
  return ApiStateNotifier(
      payment: ref.watch(_payment),
      payment_return: ref.watch(_paymentRetunr),
      payment_terminal: ref.watch(_paymentTerminal),
      detailBalance: ref.watch(_detaiBalance),
      venta: ref.watch(_venta),
      addCortesia: ref.watch(_addCortesia),
      removeCortesia: ref.watch(_removeCortesia),
  );
});



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


final _payment = Provider<Payment>((ref) {
  return Payment(repository: ref.watch(_userRepository));
});
final _paymentRetunr = Provider<PaymentReturn>((ref) {
  return PaymentReturn(repository: ref.watch(_userRepository));
});
final _paymentTerminal = Provider<PaymentTerminal>((ref) {
  return PaymentTerminal(repository: ref.watch(_userRepository));
});
final _detaiBalance = Provider<DetailBalance>((ref) {
  return DetailBalance(repository: ref.watch(_userRepository));
});
final _venta = Provider<Venta>((ref) {
  return Venta(repository: ref.watch(_userRepository));
});
final _addCortesia = Provider<AddCortesia>((ref) {
  print('Se agrego el repositorio en provider');
  return AddCortesia(repository: ref.watch(_userRepository));
});
final _removeCortesia = Provider<RemoveCortesia>((ref) {
  return RemoveCortesia(repository: ref.watch(_userRepository));
});




