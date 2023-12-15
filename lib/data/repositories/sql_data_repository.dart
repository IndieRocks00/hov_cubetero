

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/data/datasources/helper/Failure.dart';
import 'package:indierocks_cubetero/data/datasources/remote/repositories/sql_data_repository.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/domain/repositories/isql_data_repository.dart';
import 'package:sqflite/sqflite.dart';

class SqlDataRepository implements ISqlDataRepository{
  //final Database _database;
  final ISqlDataSource _sqlRepository;

  SqlDataRepository({
     //required Database database,
      required ISqlDataSource sqlRepository,
  }) : //assert(database != null),
        assert(sqlRepository != null),
        //_database = database,
        _sqlRepository = sqlRepository;

  @override
  Future<bool> deleteUser() {
    return _sqlRepository.deleteUser();
  }

  @override
  Future<Either<Failure,UserModel>> getUser() async {
    //print('Inicio de sql data repository');
    try{
      final loggedInUser = await _sqlRepository.getUser();

      //print('SqlDataRepository UseR: ${loggedInUser?.toJson()}');
      //print('SqlDataRepository condicion null loggin user: ${loggedInUser == null}');
      if(loggedInUser == null){

        return Left(Failure(FailureStatus.user_not_found,FailureStatus.getMessage(FailureStatus.user_not_found)));
      }
      else{
        return Right(loggedInUser);
      }
    }catch(e ){
      if(e is Failure){
        return Left(Failure(e.statusCode,e.toString()));
      }
      else{
        //print('sql data repository Exception');
        return Left(Failure(FailureStatus.exception,e.toString()));
      }
    }

  }

  @override
  Future<bool> insertUser(UserModel userModel) {
    return _sqlRepository.insertUser(userModel);
  }
  
}