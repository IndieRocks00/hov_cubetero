
part of 'login_provider.dart';
class LoginNotifier extends StateNotifier<LoginState>{
  LoginNotifier({
    required DoLogin doLogin,
  }) : assert (doLogin != null),
      _doLogin = doLogin,
      super (LoginState.initial());
  final DoLogin _doLogin;

  void reset() => state = Initial();

  Future<void>  doLogin(String user, String pass) async{
    state = Loading();
    final result = await _doLogin(user, pass);
    result.fold(
            (error) => state =  Error(message: error.message,statuscode: error.statusCode),
            (user) => state = LoginAvailable(userModel: user)
    );
  }
}