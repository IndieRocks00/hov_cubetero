

import 'package:dartz/dartz.dart';
import 'package:indierocks_cubetero/data/datasources/helper/Failure.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/domain/repositories/isql_data_repository.dart';

class InsertUser{
  ISqlDataRepository _repository;
  InsertUser({
    required ISqlDataRepository repository,
  }): assert(repository != null),
        _repository = repository;

  Future<bool> call(UserModel userModel) async => await  _repository.insertUser(userModel);
}

class GetUser{
  ISqlDataRepository _repository;
  GetUser({
    required ISqlDataRepository repository,
  }): assert(repository != null),
        _repository = repository;

  Future<Either<Failure,UserModel>> call() async => await  _repository.getUser();
}

class LogOut{
  LogOut({
    required ISqlDataRepository  repository
  }) : assert(repository != null), _repository = repository;

  final ISqlDataRepository _repository;
  Future<bool> call() async =>  await _repository.deleteUser();
}

