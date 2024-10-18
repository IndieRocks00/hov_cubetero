part of 'api_provider.dart';
class AccesToEventNotifier extends StateNotifier<ApiState>{
  AccesToEventNotifier( {
    required AccesToEvent accesToEvent,
  }) :
        assert(accesToEvent != null),
        _accesToEvent = accesToEvent,
        super(ApiState.initial());

  final AccesToEvent _accesToEvent;

  void reset() => state = Initial();



  Future<void> accesToEvent(String code_user_encripted, int userID, int codeVans) async{
    state = Loading();
    final result = await _accesToEvent(code_user_encripted,userID, codeVans);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }

}