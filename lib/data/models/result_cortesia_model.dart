


import 'dart:convert';

import 'package:indierocks_cubetero/data/models/cortesia_cliente_model.dart';
import 'package:indierocks_cubetero/domain/entities/cortesia_cliente.dart';
import 'package:indierocks_cubetero/domain/entities/result_cortesia.dart';

class ResultCortesiaModel implements ResultCortesia{

  final int rcode;
  final int balance;
  final List<CortesiaClienteModel> cortesias;

  ResultCortesiaModel({
    required this.rcode,required this.balance, required this.cortesias
  });


  factory ResultCortesiaModel.fromMap(Map<String,dynamic> json){
    /*print('rcode : ${json['rcode']}');
    print('balance : ${json['balance']}');*/
    List<dynamic> msgList = jsonDecode(json['msg']);
    //print('msg : ${msgList.toString()}');
    return ResultCortesiaModel(
        rcode: json['rcode'] as int,
        balance: int.parse(json['balance'].toString()),
        cortesias: msgList.map(
              (item) => CortesiaClienteModel.fromJson(item),
        ).toList()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rcode': rcode,
      'balance': balance,
      'msg': cortesias.map((cortesia) => cortesia.toJson()).toList(),
    };
  }
}