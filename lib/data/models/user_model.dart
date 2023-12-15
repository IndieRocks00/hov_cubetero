
import 'package:indierocks_cubetero/domain/entities/user.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class UserModel implements User{

  UserModel({
    required this.user,
    required this.password,
    required this.balance,
    required this.nameClient,
    required this.data_encripted
  });

  factory UserModel.fromMap(Map<String, dynamic> json) {
    //print('Json UserModel : $json');
    return UserModel(
        user: json['USER'].toString(),
        password: json['PASSWORD'].toString(),
        balance: json['BALANCE'].toString(),
        nameClient: json['NAMECLIENT'].toString(),
        data_encripted: json['DATA_ENCRIPTED'].toString()
    );
  }
  Map<String, dynamic> toJson() => {
    "user": user,
    "password": password,
    "balance": balance,
    "nameClient": nameClient,
    "data_encripted": data_encripted,
  };

  @override
  final String user;
  @override
  final String password;
  @override
  final String balance;
  @override
  final String nameClient;
  @override
  final String data_encripted;


}