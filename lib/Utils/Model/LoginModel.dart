class LoginModel{
  String id = "1";
  String user;
  String pass;
  String balance;
  String name_client;

  LoginModel(this.user, this.pass, this.balance, this.name_client);

  Map<String, dynamic> toMap()=>{
    'id' : id,
    'user': user,
    'pass': pass,
    'balance': balance,
    'name_client': name_client,
  };
}