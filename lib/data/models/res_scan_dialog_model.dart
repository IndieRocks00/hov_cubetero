


import 'package:indierocks_cubetero/domain/entities/res_scan_dialog.dart';
import 'package:indierocks_cubetero/ui/enum/enum_banks.dart';

class ResScanDialogModel implements ResScanDialog{

  final int rcode;
  final BankType banco;
  final String message;

  ResScanDialogModel({
    required this.rcode,
    required this.banco,
    required this.message
  });


  factory ResScanDialogModel.fromMap(Map<String,dynamic> json){
    return ResScanDialogModel(
        rcode: json['rcode'],
        banco: json['banco'],
        message: json['msg']??''
    );
  }

  Map<String,dynamic> toJson() => {
    'rcode':rcode,
    'banco':banco,
    'message':message,
  };

}