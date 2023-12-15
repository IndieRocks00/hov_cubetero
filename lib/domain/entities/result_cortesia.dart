


import 'package:indierocks_cubetero/domain/entities/cortesia_cliente.dart';

abstract class ResultCortesia{

  final int rcode;
  final int balance;
  final List<CortesiaCliente> cortesias;

  ResultCortesia({
    required this.rcode,required this.balance, required this.cortesias
  });

}