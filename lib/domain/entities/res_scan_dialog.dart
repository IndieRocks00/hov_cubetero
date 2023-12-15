

import 'package:indierocks_cubetero/ui/enum/enum_banks.dart';

abstract class ResScanDialog{
  final int rcode;
  final BankType banco;
  final String message;

  ResScanDialog({
    required this.rcode,required this.banco, required this.message
  });
}