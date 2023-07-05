import 'package:indierocks_cubetero/Utils/Model/ProductoModel.dart';

class CarritoModel{
  int cantidad;
  ProdcutoVenta prodcutoVenta;

  CarritoModel({
    required this.cantidad,
    required this.prodcutoVenta
  });

  Map<String, dynamic> toJson() => {
    '"sku"': '"${prodcutoVenta.sku}"',
    '"nProd"': '"${cantidad}"'
  };
}