



part of '../providers.dart';

class GetCortesiaClientNotifier extends StateNotifier<getCortesiasState.GetCortesiaState>{
  GetCortesiaClientNotifier({
    required final GetCortesiasCliente getCortesiasCliente
  }): assert(getCortesiasCliente != null),
  _getCortesiasCliente = getCortesiasCliente,
  super(getCortesiasState.GetCortesiaState.initial());

  final GetCortesiasCliente _getCortesiasCliente;

  void reset() => state = getCortesiasState.Initial();

  Future<void> getCortesiasClient(String code_client_encripted,String code_user_encripted) async{
    state = getCortesiasState.Loading();

    final result = await _getCortesiasCliente(code_client_encripted, code_user_encripted);
    result.fold(
            (error) => state = getCortesiasState.Error(statusCode: error.statusCode,message: error.message),
            (resCortesia) => state = getCortesiasState.GetCortesiaAvaible(resultCortesiaModel: resCortesia)
    );

  }

}