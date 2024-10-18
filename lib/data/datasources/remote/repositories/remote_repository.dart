
import 'package:indierocks_cubetero/data/models/cortesia_model.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';
import 'package:indierocks_cubetero/data/models/result_cortesia_model.dart';

abstract class IRemoteDataSource{

  Future<ResApiModel> doLogin(String version_encripted,String user_encripted);

  Future<ResApiModel> payment(String code_version_encripted,String code_client_encripted,String code_user_encripted,int amount, int banco,String reference);

  Future<ResApiModel> detailBalance(String code_version_encripted,String code_client_encripted,String code_user_encripted);

  Future<ResultCortesiaModel> getCortesiaClient(String code_version_encripted,String code_client_encripted,String code_user_encripted);

  Future<List<ProductoModel>> getProductos(String code_version_encripted,String code_user_encripted);

  Future<ResApiModel> sellV2(String code_version_encripted,String code_client_encripted,String code_user_encripted,String code_product_encripted, int total, int banco);

  Future<List<CortesiaModel>> getOptionsCortesia(String code_version_encripted,String code_user_encripted);

  Future<ResApiModel> addCortesia(String code_version_encripted,String code_client_encripted,String code_user_encripted,String code_cortesia_encripted, int eventId);

  Future<ResApiModel> removeCortesia(String code_version_encripted,String code_client_encripted,String code_user_encripted);

  Future<ResApiModel> getTokenPulsera(String code_version_encripted,String code_user_encripted);

  Future<ResApiModel> validarBoleto(String code_version_encripted,String code_client_encripted,String code_user_encripted);

  Future<ResApiModel> accesToEvent(String code_version_encripted,String code_user_encripted, int userID, int codeVans);

}