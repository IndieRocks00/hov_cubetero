

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/env/Enviroments.dart';
import 'package:indierocks_cubetero/data/datasources/remote/http_data_source.dart';
import 'package:indierocks_cubetero/data/datasources/remote/sql_data_source.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/data/repositories/encriptation_md5_repository.dart';
import 'package:indierocks_cubetero/data/repositories/network_repository.dart';
import 'package:indierocks_cubetero/data/repositories/qr_scan_repository.dart';
import 'package:indierocks_cubetero/data/repositories/sql_data_repository.dart';
import 'package:indierocks_cubetero/data/repositories/user_repository.dart';
import 'package:indierocks_cubetero/data/repositories/version_app_repository.dart';
import 'package:indierocks_cubetero/domain/repositories/isql_data_repository.dart';
import 'package:indierocks_cubetero/domain/repositories/iuser_repository.dart';
import 'package:http/http.dart' as http;
import 'package:indierocks_cubetero/domain/use_cases/user_uses_case.dart';

import 'login_state.dart';

export 'login_state.dart' show Initial, Loading, LoginAvailable, Error;

part 'login_state_notifier.dart';


final  loginNotifier = StateNotifierProvider<LoginNotifier,LoginState>((ref){
  final getDoLogin = ref.watch(_doLogin);
  final res = LoginNotifier(doLogin: getDoLogin);
  return res;
});

///Repository
final _loginRepository = Provider<IUserRepository>((ref){
  return UserRepository(
      networkManager: NetworkRepository(),
      remoteDataSource: HttpDataSource(
          client: http.Client(),
          url: Enviroments.URL_BASE,
          keyAccess: Enviroments.keyIndie,
      ),
      encriptionMd5Repository: EncriptationMd5Repository(),
      versionAppRepository: VersionAppRepository(),
      keyIdVer: Enviroments.keyIdVer,
      keyVersion: Enviroments.keyVersion,
      qrScanRepository: QrScanRepository(),
  );
});

///Use case
final _doLogin = Provider<DoLogin>((ref){
  final repository = ref.watch(_loginRepository);
  return DoLogin(repository: repository);
});



