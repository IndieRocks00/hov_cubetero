

import 'package:indierocks_cubetero/domain/entities/cortesia_cliente.dart';

class CortesiaClienteModel implements CortesiaCliente{

  final int userId;
  final int id;
  final int fkUser;
  final int fkEvento;
  final int cantidad;
  final int active;
  final int serviceId;
  final String service;
  CortesiaClienteModel({
    required this.userId,
    required this.id,
    required this.fkUser,
    required this.fkEvento,
    required this.cantidad,
    required this.active,
    required this.serviceId,
    required this.service,
  });

  factory CortesiaClienteModel.fromJson(Map<String, dynamic> json) {
    return CortesiaClienteModel(
      userId: json['USER_ID'] as int,
      id: json['ID'] as int,
      fkUser: json['FK_user'] as int,
      fkEvento: json['FK_evento'] as int,
      cantidad: json['Cantidad'] as int,
      active: json['Active'] as int,
      serviceId: json['SERVICE_ID'] as int,
      service: json['SERVICE'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'USER_ID': userId,
      'ID': id,
      'FK_user': fkUser,
      'FK_evento': fkEvento,
      'Cantidad': cantidad,
      'Active': active,
      'SERVICE_ID': serviceId,
      'SERVICE': service,
    };
  }

  @override
  String toString() {
    return 'ServiceData{userId: $userId, id: $id, fkUser: $fkUser, fkEvento: $fkEvento, cantidad: $cantidad, active: $active, serviceId: $serviceId, service: $service}';
  }
}