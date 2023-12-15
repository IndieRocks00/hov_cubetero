

abstract class User{
  User({
        this.user,
        this.password,
        this.balance,
        this.nameClient,
        this.data_encripted
      });

  final String? user;
  final String? password;
  final String? balance;
  final String? nameClient;
  final String? data_encripted;
}