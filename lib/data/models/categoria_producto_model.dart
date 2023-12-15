
import 'package:indierocks_cubetero/domain/entities/categoria_producto.dart';

class CategoriaProductoModel implements CategoriaProdcuto{

  final int ID;
  final String name;
  final String descripcion;

  CategoriaProductoModel({
    required this.ID, required this.name, required this.descripcion
  });

  factory CategoriaProductoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaProductoModel(
        ID: json['ID'] as int,
        name: json['name'],
        descripcion: json['skS'][0]['descripcion']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'name': name,
      'ALIMENTOS': descripcion,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CategoriaProductoModel &&
              runtimeType == other.runtimeType &&
              ID == other.ID &&
              name == other.name;


  @override
  int get hashCode => ID.hashCode ^ name.hashCode;

}