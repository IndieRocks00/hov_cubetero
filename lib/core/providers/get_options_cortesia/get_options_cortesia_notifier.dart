


part of '../providers.dart';

class GetOptionsCortesiaNotifier extends StateNotifier<getOptionsCortesiaState.GetOptionsCortesiaState>{

  GetOptionsCortesiaNotifier( {
    required GetOptionsCortesia getOptionsCortesia
 }): assert(getOptionsCortesia != null),
    _getOptionsCortesia = getOptionsCortesia,
    super(getOptionsCortesiaState.GetOptionsCortesiaState.initial());

  final GetOptionsCortesia _getOptionsCortesia;


  void reset() => state = getOptionsCortesiaState.Initial();

  Future<void> getOptionsCortesia(String code_user_encripted) async{
    state = getOptionsCortesiaState.Loaging();
    var res = await _getOptionsCortesia(code_user_encripted);
    res.fold(
            (error) => state = getOptionsCortesiaState.Error(rcode: error.statusCode, message: error.message),
            (optionsCortesia) => state = getOptionsCortesiaState.GetProductosAvailable(listCortesia: optionsCortesia)
    );
  }

}