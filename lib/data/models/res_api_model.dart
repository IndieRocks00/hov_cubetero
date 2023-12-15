

import 'package:indierocks_cubetero/domain/entities/result_api.dart';

class ResApiModel implements RestApi{

  final int rcode;
  final String message;

  ResApiModel({
    required this.rcode,
    required this.message
  });


  factory ResApiModel.fromMap(Map<String,dynamic> json){
    return ResApiModel(
        rcode: json['rcode'],
        message: json['msg']??''
    );
  }

  Map<String,dynamic> toJson() => {
    'rcode':rcode,
    'message':message,
  };

}