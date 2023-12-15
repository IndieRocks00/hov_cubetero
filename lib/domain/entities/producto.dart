

import 'package:indierocks_cubetero/domain/entities/categoria_producto.dart';

abstract class Producto{

  final String productName;
  final String sku;
  final double sku_monto;
  final String informacionGral;
  final int service;
  final CategoriaProdcuto categoria;

  Producto({
    required this.productName,
    required this.sku,
    required this.sku_monto,
    required this.informacionGral,
    required this.service,
    required this.categoria
  });

}
