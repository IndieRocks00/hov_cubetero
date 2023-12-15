

import 'dart:convert';

import 'package:indierocks_cubetero/data/models/categoria_producto_model.dart';
import 'package:indierocks_cubetero/domain/entities/categoria_producto.dart';
import 'package:indierocks_cubetero/domain/entities/producto.dart';

class ProductoModel implements Producto{
  final String productName;
  final String sku;
  final double sku_monto;
  final String informacionGral;
  final int service;
  final CategoriaProductoModel categoria;

  ProductoModel({
    required this.productName,
    required this.sku,
    required this.sku_monto,
    required this.informacionGral,
    required this.service,
    required this.categoria
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      productName: json['productName'],
      sku: json['sku'],
      sku_monto: double.parse(json['sku_monto'].toString()),
      informacionGral: json['informacionGral'],
      service: json['service'] as int,
      categoria: CategoriaProductoModel.fromJson(json['c'][0]),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'sku': sku,
      'sku_monto': sku_monto,
      'informacionGral': informacionGral,
      'service': service,
      'categoria': categoria,
    };
  }

}