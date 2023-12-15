

import 'package:dartz/dartz.dart';
import 'package:flutter/physics.dart';
import 'package:indierocks_cubetero/data/models/cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/result_cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/data/datasources/helper/Failure.dart';
import 'package:indierocks_cubetero/domain/entities/result_api.dart';
import 'package:indierocks_cubetero/domain/repositories/iuser_repository.dart';

class DoLogin{
  DoLogin({
        required IUserRepository repository
    }) : assert(repository != null ),_reposotory = repository;

  final IUserRepository _reposotory;
  Future<Either<Failure,UserModel>> call(String user, String pass) async => await _reposotory.doLogin(user, pass);
}

class Payment{
  Payment({
     required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,ResApiModel>> call(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference) async =>
      await _repository.payment(code_client_encripted,code_user_encripted,amount, banco,reference);
}

class PaymentReturn{
  PaymentReturn({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,ResApiModel>> call(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference) async =>
      await _repository.paymentReturn(code_client_encripted,code_user_encripted,amount, banco,reference);
}

class PaymentTerminal{
  PaymentTerminal({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,ResApiModel>> call(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference) async =>
      await _repository.paymentTerminal(code_client_encripted,code_user_encripted,amount, banco,reference);
}

class DetailBalance{
  DetailBalance({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,ResApiModel>> call(String code_client_encripted,String code_user_encripted) async =>
      await _repository.detailBalance(code_client_encripted,code_user_encripted);
}

class GetCortesiasCliente{
  GetCortesiasCliente({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,ResultCortesiaModel>> call(String code_client_encripted,String code_user_encripted) async =>
      await _repository.getCortesiaClient(code_client_encripted,code_user_encripted);
}

class GetProductos{
  GetProductos({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,List<ProductoModel>>> call(String code_user_encripted) async =>
      await _repository.getProductos(code_user_encripted);
}

class Venta{
  Venta({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,ResApiModel>> call(String code_client_encripted,String code_user_encripted,String products,double total,int banco,) async =>
      await _repository.venta(code_client_encripted,code_user_encripted,products,total,banco,);
}

class GetOptionsCortesia{
  GetOptionsCortesia({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,List<CortesiaModel>>> call(String code_user_encripted) async =>
      await _repository.getOptionsCortesia(code_user_encripted);
}

class AddCortesia{
  AddCortesia({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,ResApiModel>> call(String code_client_encripted,String code_user_encripted,String cortesias) async{
    print('Entro al caso de uso');
    return await _repository.addCortesia(code_client_encripted,code_user_encripted,cortesias);
  }
}

class RemoveCortesia{
  RemoveCortesia({
    required IUserRepository  repository
  }) : assert(repository != null), _repository = repository;

  final IUserRepository _repository;
  Future<Either<Failure,ResApiModel>> call(String code_client_encripted,String code_user_encripted) async =>
      await _repository.removeCortesia(code_client_encripted,code_user_encripted);
}