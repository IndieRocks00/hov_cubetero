

import 'package:dartz/dartz.dart';
import 'package:indierocks_cubetero/data/datasources/helper/Failure.dart';
import 'package:indierocks_cubetero/data/datasources/remote/repositories/remote_repository.dart';
import 'package:indierocks_cubetero/data/models/categoria_producto_model.dart';
import 'package:indierocks_cubetero/data/models/cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/result_cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/domain/repositories/iencription_md5_repository.dart';
import 'package:indierocks_cubetero/domain/repositories/inetwork_manager_repository.dart';
import 'package:indierocks_cubetero/domain/repositories/iqr_scan_repository.dart';
import 'package:indierocks_cubetero/domain/repositories/iuser_repository.dart';
import 'package:indierocks_cubetero/domain/repositories/iversion_app_repository.dart';

class UserRepository implements IUserRepository{
  UserRepository({
    required INetworkManagerRepository networkManager,
    required IRemoteDataSource remoteDataSource,
    required IEncriptionMd5Repository encriptionMd5Repository,
    required IVersionAppRepository versionAppRepository,
    required String keyIdVer,
    required String keyVersion,
    required IQrScanRepository qrScanRepository,
  }): assert(networkManager != null),
        assert(remoteDataSource != null),
        assert(encriptionMd5Repository != null),
        assert(encriptionMd5Repository != null),
        assert(keyIdVer != null),
        assert(keyVersion != null),
        assert(qrScanRepository != null),
        _networkManager = networkManager,
        _remoteDataSource = remoteDataSource,
        _encriptionMd5Repository = encriptionMd5Repository,
        _versionAppRepository = versionAppRepository,
        _qrScanRepository = qrScanRepository,
        _keyIdVer = keyIdVer,
        _keyVersion = keyVersion;


  final INetworkManagerRepository _networkManager;
  final IRemoteDataSource _remoteDataSource;
  final IEncriptionMd5Repository _encriptionMd5Repository;
  final IVersionAppRepository _versionAppRepository;
  final String _keyIdVer;
  final String _keyVersion;
  final IQrScanRepository _qrScanRepository;

  @override
  Future<Either<Failure, UserModel>> doLogin(String user, String pass) async {

    if(user.isEmpty || user == ''){
      return Left(Failure(FailureStatus.empty_text,FailureStatus.getMessage(FailureStatus.empty_text)));
    }
    if(pass.isEmpty || pass == ''){
      return Left(Failure(FailureStatus.empty_text,FailureStatus.getMessage(FailureStatus.empty_text)));
    }
    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    String encript_user = _encriptionMd5Repository.encryptData('$user|$pass', _keyVersion);

    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.doLogin(encript_version, encript_user);
        switch(resApi.rcode){
          case 0:
            //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
            //print(msgDesc);
            //var msgArr = msgDesc.split('|');
            //String nameUser = msgArr[0];
            //String balance = msgArr[1];;
            //String nameUser = user;
            //String balance = '15200';

            return Right(UserModel(user: user, password: pass, balance: '0', nameClient: '', data_encripted: encript_user));
          case 1:

            return Left(Failure(FailureStatus.credential_invalid,FailureStatus.getMessage(FailureStatus.credential_invalid)));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));


        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, ResApiModel>> payment(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference) async{


    if(code_client_encripted.isEmpty || code_client_encripted == ''){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }
    /*int monto = 0;
    try{
      monto = int.parse(amount);
    }catch(e){
      return Left(Failure(FailureStatus.monto_incorrecto,FailureStatus.getMessage(FailureStatus.monto_incorrecto)));
    }*/
    if(amount<= 0){
      return Left(Failure(FailureStatus.monto_invalido,FailureStatus.getMessage(FailureStatus.monto_invalido)));
    }
    if(reference.isEmpty){
      return Left(Failure(FailureStatus.monto_invalido,FailureStatus.getMessage(FailureStatus.monto_invalido)));
    }
    var arrayUser = code_client_encripted.split('|');
    if(arrayUser.length != 2){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    String client = arrayUser[1];
    print(client);

    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.payment(encript_version,client,code_user_encripted,amount,banco,reference);
        switch(resApi.rcode){
          case 0:
          //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            return Right(ResApiModel(rcode: 0,message: 'Transacción realizada correctamente'));
          case 1:

            return Left(Failure(1,resApi.message));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, ResApiModel>> paymentReturn(String code_client_encripted, String code_user_encripted, int amount, int banco, String reference) async {

    if(code_client_encripted.isEmpty || code_client_encripted == ''){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }
    /*int monto = 0;
    try{
      monto = int.parse(amount);
    }catch(e){
      return Left(Failure(FailureStatus.monto_incorrecto,FailureStatus.getMessage(FailureStatus.monto_incorrecto)));
    }*/
    if(amount<= 0){
      return Left(Failure(FailureStatus.monto_invalido,FailureStatus.getMessage(FailureStatus.monto_invalido)));
    }
    if(reference.isEmpty) {
      return Left(Failure(FailureStatus.referencia_invalida,FailureStatus.getMessage(FailureStatus.referencia_invalida)));
    }
    var arrayUser = code_client_encripted.split('|');
    if(arrayUser.length != 2){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    String client = arrayUser[1];
    print(client);

    amount = amount * -1;
    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.payment(encript_version,client,code_user_encripted,amount,banco,reference);
        switch(resApi.rcode){
          case 0:
          //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            return Right(ResApiModel(rcode: 0,message: 'Transacción realizada correctamente'));
          case 1:

            return Left(Failure(1,resApi.message));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, ResApiModel>> paymentTerminal(String code_client_encripted, String code_user_encripted, int amount, int banco, String reference) async {

    if(code_client_encripted.isEmpty || code_client_encripted == ''){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }
    /*int monto = 0;
    try{
      monto = int.parse(amount);
    }catch(e){
      return Left(Failure(FailureStatus.monto_incorrecto,FailureStatus.getMessage(FailureStatus.monto_incorrecto)));
    }*/
    if(amount <= 0){
      return Left(Failure(FailureStatus.monto_invalido,FailureStatus.getMessage(FailureStatus.monto_invalido)));
    }
    if(reference.isEmpty) {
      return Left(Failure(FailureStatus.monto_invalido,FailureStatus.getMessage(FailureStatus.monto_invalido)));
    }
    var arrayUser = code_client_encripted.split('|');
    if(arrayUser.length != 2){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    String client = arrayUser[1];
    print(client);

    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.payment(encript_version,client,code_user_encripted,amount,banco,reference);
        switch(resApi.rcode){
          case 0:
          //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            return Right(ResApiModel(rcode: 0,message: 'Transacción realizada correctamente'));
          case 1:

            return Left(Failure(1,resApi.message));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, ResApiModel>> detailBalance(String code_client_encripted, String code_user_encripted) async{

    if(code_client_encripted.isEmpty || code_client_encripted == ''){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }

    var arrayUser = code_client_encripted.split('|');
    if(arrayUser.length != 2){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    String client = arrayUser[1];
    print(client);

    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    if(await _networkManager.isConnected()){
      try{

        final resApi = await _remoteDataSource.detailBalance(encript_version,client,code_user_encripted);
        print('Resultado DEvuelto user_repository : ${resApi.toJson()}');
        switch(resApi.rcode){
          case 0:
          //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            return Right(resApi);
          case 1:
            return Left(Failure(1,resApi.message));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, ResultCortesiaModel>> getCortesiaClient(String code_client_encripted, String code_user_encripted) async{

    if(code_client_encripted.isEmpty || code_client_encripted == ''){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }

    var arrayUser = code_client_encripted.split('|');
    if(arrayUser.length != 2){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    String client = arrayUser[1];
    print(client);

    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.getCortesiaClient(encript_version,client,code_user_encripted);
        print('Resultado DEvuelto user_repository : ${resApi.toJson()}');
        switch(resApi.rcode){
          case 0:
          //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];
            print('resCortesia ${resApi.toJson()}');
            return Right(resApi);
          case 1:
            return Left(Failure(1,'No se pudo obtener información de cortesias disponibles.'));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, List<ProductoModel>>> getProductos(String code_user_encripted) async{

    //await Future.delayed(Duration(seconds: 2));
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }

    /*return Right([
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 1, name: 'nombre',descripcion: 'desc')),
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 2, name: 'nombre2',descripcion: 'desc')),
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 2, name: 'nombre2',descripcion: 'desc')),
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 2, name: 'nombre2',descripcion: 'desc')),
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 2, name: 'nombre2',descripcion: 'desc')),
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 2, name: 'nombre2',descripcion: 'desc')),
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 2, name: 'nombre2',descripcion: 'desc')),
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 2, name: 'nombre2',descripcion: 'desc')),
      ProductoModel(productName: 'productName', sku: 'sku', sku_monto: 18, informacionGral: 'informacionGral', service: 1, categoria: CategoriaProductoModel(ID: 3, name: 'nombre3',descripcion: 'desc')),
    ]);*/
    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    if(await _networkManager.isConnected()){
      try{
        final resProductos = await _remoteDataSource.getProductos(encript_version,code_user_encripted);
        //print('Resultado DEvuelto user_repository : ${resApi.toJson()}');

        return Right(resProductos);
        if(resProductos.isNotEmpty){

        }
        else{
          return Left(Failure(1,'No hay productos disponibles.'));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, ResApiModel>> venta(String code_client_encripted, String code_user_encripted, String products, double total, int banco) async{

    //return Right(ResApiModel(rcode: 1,message: 'Venta realizada correctamente'));
    print(total);
    await Future.delayed(Duration(seconds: 5));
    if(code_client_encripted.isEmpty || code_client_encripted == ''){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }
    int monto = 0;
    try{
      monto = total.toInt();
    }catch(e){
      print('monto exception');
      return Left(Failure(FailureStatus.monto_incorrecto,FailureStatus.getMessage(FailureStatus.monto_incorrecto)));
    }
    if(monto< 0){
      return Left(Failure(FailureStatus.monto_invalido,FailureStatus.getMessage(FailureStatus.monto_invalido)));
    }
    var arrayUser = code_client_encripted.split('|');
    if(arrayUser.length != 2){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    String client = arrayUser[1];
    print(client);

    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    String productos_encripted = _encriptionMd5Repository.encryptData(products, _keyVersion);
    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.sellV2(encript_version,client,code_user_encripted,productos_encripted,monto,banco);
        switch(resApi.rcode){
          case 0:
          //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            return Right(ResApiModel(rcode: 0,message: 'Venta realizada correctamente'));
          case 1:
            return Right(ResApiModel(rcode: 1,message: resApi.message));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, List<CortesiaModel>>> getOptionsCortesia(String code_user_encripted) async{

    //return Right(ResApiModel(rcode: 1,message: 'Venta realizada correctamente'));

    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.getOptionsCortesia(encript_version,code_user_encripted);

        return Right(resApi);


      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, ResApiModel>> addCortesia(String code_client_encripted, String code_user_encripted, String json_cortesias) async{
    print('Entro a add cortesia');
    if(code_client_encripted.isEmpty || code_client_encripted == ''){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }

    /*if(json_cortesias.isEmpty || json_cortesias == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }*/

    var arrayUser = code_client_encripted.split('|');
    if(arrayUser.length != 2){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    String client = arrayUser[1];
    print(client);

    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    print('json_cortesia: ${json_cortesias}');
    String cortesia_encripted = _encriptionMd5Repository.encryptData(json_cortesias, _keyVersion);
    print('json_cortesia encriptado: ${cortesia_encripted}');
    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.addCortesia(encript_version,client,code_user_encripted,cortesia_encripted);
        return Right(resApi);
        switch(resApi.rcode){
          case 0:
          //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            return Right(ResApiModel(rcode: 0,message: 'Venta realizada correctamente'));
          case 1:
            return Right(ResApiModel(rcode: 1,message: resApi.message));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }

  @override
  Future<Either<Failure, ResApiModel>> removeCortesia(String code_client_encripted, String code_user_encripted) async{
    print('Entro a remover cortesia');

    if(code_client_encripted.isEmpty || code_client_encripted == ''){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    if(code_user_encripted.isEmpty || code_user_encripted == ''){
      return Left(Failure(FailureStatus.error_data_user_logeado,FailureStatus.getMessage(FailureStatus.error_data_user_logeado)));
    }

    var arrayUser = code_client_encripted.split('|');
    if(arrayUser.length != 2){
      return Left(Failure(FailureStatus.error_data_escaneado,FailureStatus.getMessage(FailureStatus.error_data_escaneado)));
    }
    String client = arrayUser[1];
    print(client);

    String version_app = await _versionAppRepository.getVersionApp();
    String encript_version = _encriptionMd5Repository.encryptData(version_app, _keyIdVer);
    print(version_app);
    print(encript_version);
    if(await _networkManager.isConnected()){
      try{
        final resApi = await _remoteDataSource.removeCortesia(encript_version,client,code_user_encripted);
        return Right(resApi);
        switch(resApi.rcode){
          case 0:
          //var msgDesc = _encriptionMd5Repository.desencryptData(resApi.message, _keyVersion);
          //var msgArr = msgDesc.split('|');
          //String nameUser = msgArr[0];
          //String balance = msgArr[1];

            return Right(ResApiModel(rcode: 0,message: 'Venta realizada correctamente'));
          case 1:
            return Right(ResApiModel(rcode: 1,message: resApi.message));
          default:

            return Left(Failure(FailureStatus.request_process_error,FailureStatus.getMessage(FailureStatus.request_process_error)));
        }

      }catch(e ){
        if(e is Failure){
          return Left(Failure(e.statusCode,e.toString()));
        }
        else{
          //print('user repository Exception');
          return Left(Failure(FailureStatus.exception,e.toString()));
        }
      }
    }
    else{
      return Left(Failure(FailureStatus.not_connection_internet,FailureStatus.getMessage(FailureStatus.not_connection_internet)));
    }
  }


}