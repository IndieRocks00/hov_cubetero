

part of 'sql_provider.dart';
class SqlUserNotifier extends StateNotifier<SqlUserState>{
  SqlUserNotifier({
    required GetUser getUser,
    required LogOut logOut,
  }) : assert (getUser != null),
        assert (logOut != null),
        _getUser = getUser,
        _logOut = logOut,
        super (SqlUserState.initial());
  final GetUser _getUser;
  final LogOut _logOut;

  void reset() => state = Initial();

  Future<void>  getUser() async{
    //print('Inicio de slq user state notifier');
    state = Loading();
    final result = await _getUser();
    result.fold(
            (error) => state =  Error(),
            (user) => state = UserAvailable(userModel: user)
    );
  }

  Future<bool>  logout() async{
    try {
      //print('Inicio de slq user state notifier');
      state = Loading();
      final result = await _logOut();
      if (!result) {
        state = Error(); // Hubo un error en el logout
        return false;
      } else {
        state = UserAvailable(userModel: UserModel(user: '', password: '', balance: '', nameClient: '', data_encripted: ''));
        return true;
      }
    } catch (error) {
      state = Error(); // Capturando cualquier excepción
      return false;
    }
  }

}