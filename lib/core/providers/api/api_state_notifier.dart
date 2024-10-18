


part of 'api_provider.dart';
class ApiStateNotifier extends StateNotifier<ApiState>{
  ApiStateNotifier({
      required Payment payment,
      required PaymentReturn payment_return,
      required PaymentTerminal payment_terminal,
      required DetailBalance detailBalance,
      required Venta venta,
      required AddCortesia addCortesia,
    required RemoveCortesia removeCortesia,
    required GetTokenPulsera getTokenPulsera,
    required ValidarBoleto validarBoleto,
  }) : assert(payment != null),
        assert(payment_return != null),
        assert(payment_terminal != null),
        assert(detailBalance != null),
        assert(venta != null),
        assert(addCortesia != null),
        assert(removeCortesia != null),
        assert(getTokenPulsera != null),
        assert(validarBoleto != null),
        _payment = payment,
        _paymentReturn = payment_return,
        _paymentTerminal = payment_terminal,
        _detailBalance = detailBalance,
        _venta = venta,
        _addCortesia = addCortesia,
        _removeCortesia = removeCortesia,
        _getTokenPulsera = getTokenPulsera,
        _validarBoleto = validarBoleto,
        super(ApiState.initial());

  final Payment _payment;
  final PaymentReturn _paymentReturn;
  final PaymentTerminal _paymentTerminal;
  final DetailBalance _detailBalance;
  final Venta _venta;
  final AddCortesia _addCortesia;
  final RemoveCortesia _removeCortesia;
  final GetTokenPulsera _getTokenPulsera;
  final ValidarBoleto _validarBoleto;

  void reset() => state = Initial();

  Future<void> payment(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference) async{
    state = Loading();
    final result = await _payment( code_client_encripted, code_user_encripted,amount, banco, reference);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }

  Future<void> paymentReturn(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference) async{
    state = Loading();
    final result = await _paymentReturn( code_client_encripted, code_user_encripted,amount, banco, reference);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }

  Future<void> paymentTerminal(String code_client_encripted,String code_user_encripted,int amount, int banco,String reference) async{
    state = Loading();
    final result = await _paymentTerminal( code_client_encripted, code_user_encripted,amount, banco, reference);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }
  Future<void> detailBalance(String code_client_encripted,String code_user_encripted) async{
    state = Loading();
    final result = await _detailBalance( code_client_encripted, code_user_encripted);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }

  Future<void> venta(String code_client_encripted,String code_user_encripted,String products,double total,int banco,) async{
    state = Loading();
    final result = await _venta(code_client_encripted,code_user_encripted,products,total, banco,);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }


  Future<void> addCortesia(String code_client_encripted,String code_user_encripted,String cortesias, String eventID) async{
    state = Loading();
    print('Entro a add cortesia notifier ${code_client_encripted},${code_user_encripted},${cortesias}');
    if(_addCortesia == null){

      print('add cortesia es nulo');
    }
    else{

      print('add cortesia NO es nulo');
    }
    final result = await _addCortesia(code_client_encripted,code_user_encripted,cortesias, eventID);
    print('Entro a add cortesia notifier result : ${result.toString()}');
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }


  Future<void> removeCortesias(String code_client_encripted,String code_user_encripted,) async{
    state = Loading();
    final result = await _removeCortesia(code_client_encripted,code_user_encripted);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }
  Future<void> getTokenPulsera(String code_user_encripted,) async{
    state = Loading();
    final result = await _getTokenPulsera(code_user_encripted);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }

  Future<void> validarBoleto(String code_client_encripted,String code_user_encripted,) async{
    state = Loading();
    final result = await _validarBoleto(code_client_encripted,code_user_encripted);
    result.fold(
            (error) => state = Error(statuscode: error.statusCode,message: error.message),
            (resApiModel) => state = ApiAvailable(apiState: resApiModel)
    );
  }
}