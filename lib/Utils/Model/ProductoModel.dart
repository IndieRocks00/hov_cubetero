import 'package:indierocks_cubetero/Utils/Model/CategoriaModel.dart';

class ProdcutoVenta{
  String nombre;
  double costo;
  CategoriaModel categoria;
  String sku;

  ProdcutoVenta({
    required this.nombre,
    required this.costo,
    required this.categoria,
    required this.sku,
  });


}