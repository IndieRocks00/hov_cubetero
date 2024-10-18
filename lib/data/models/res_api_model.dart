

import 'package:indierocks_cubetero/domain/entities/result_api.dart';

class ResApiModel implements RestApi{

  final int rcode;
  final String message;
  final String? balance;
  final String? boletos;

  ResApiModel({
    required this.rcode,
    required this.message,
    this.balance,
    this.boletos
  });


  factory ResApiModel.fromMap(Map<String,dynamic> json){
    return ResApiModel(
        rcode: json['rcode'],
        message: json['msg']??'',
        balance: json['balance']??'',
        boletos: json['boletos']??''
    );
  }

  Map<String,dynamic> toJson() => {
    'rcode':rcode,
    'message':message,
    'balance':balance,
    'boletos':boletos,
  };

}