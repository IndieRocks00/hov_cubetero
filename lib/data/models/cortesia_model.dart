
import 'package:flutter/material.dart';
import 'package:indierocks_cubetero/domain/entities/cortesia.dart';

class CortesiaModel implements Cortesia{

  final int service;
  final String descripcion;
  final int categoriaId;
  final String categoria;

  CortesiaModel({
    required this.service,
    required this.descripcion,
    required this.categoriaId,
    required this.categoria
  });

  factory CortesiaModel.fromJson(Map<String,dynamic> json){
    return CortesiaModel(
        service: json['SERVICE'] as int,
        descripcion: json['DESCRIPCION'],
        categoriaId: json['c'][0]['ID'] as int,
        categoria: json['c'][0]['CATEGORIA']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'service':service,
      'descripcion':descripcion,
      'categoriaId':categoriaId,
      'categoria':categoria,
    };
  }

}