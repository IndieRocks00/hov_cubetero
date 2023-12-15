
import 'package:dartz/dartz.dart';
import 'package:indierocks_cubetero/data/models/cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/result_cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/domain/entities/user.dart';
import 'package:indierocks_cubetero/data/datasources/helper/Failure.dart';


abstract class IUserRepository{

  Future<Either<Failure,UserModel>> doLogin(String user, String pass);

  Future<Either<Failure,ResApiModel>> payment(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference);

  Future<Either<Failure,ResApiModel>> paymentReturn(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference);

  Future<Either<Failure,ResApiModel>> paymentTerminal(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference);

  Future<Either<Failure,ResApiModel>> detailBalance(String code_client_encripted,String code_user_encripted);

  Future<Either<Failure,ResultCortesiaModel>> getCortesiaClient(String code_client_encripted,String code_user_encripted);

  Future<Either<Failure,List<ProductoModel>>> getProductos(String code_user_encripted);

  Future<Either<Failure,ResApiModel>> venta(String code_client_encripted,String code_user_encripted,String products, double total, int banco);

  Future<Either<Failure,List<CortesiaModel>>> getOptionsCortesia(String code_user_encripted);

  Future<Either<Failure,ResApiModel>> addCortesia(String code_client_encripted,String code_user_encripted,String json_cortesias);

  Future<Either<Failure,ResApiModel>> removeCortesia(String code_client_encripted,String code_user_encripted);

}