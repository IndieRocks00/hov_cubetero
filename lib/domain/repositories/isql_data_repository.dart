

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/data/datasources/helper/Failure.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';

abstract class ISqlDataRepository{
  Future<bool> insertUser(UserModel userModel);
  Future<Either<Failure,UserModel>> getUser();
  Future<bool> deleteUser();
}