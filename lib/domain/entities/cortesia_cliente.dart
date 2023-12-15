

abstract class CortesiaCliente{

  final int userId;
  final int id;
  final int fkUser;
  final int fkEvento;
  final int cantidad;
  final int active;
  final int serviceId;
  final String service;

  CortesiaCliente({
    required this.userId,
    required this.id,
    required this.fkUser,
    required this.fkEvento,
    required this.cantidad,
    required this.active,
    required this.serviceId,
    required this.service,
  });


}