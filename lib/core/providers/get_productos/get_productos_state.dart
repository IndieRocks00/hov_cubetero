

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:indierocks_cubetero/data/models/producto_model.dart';
import 'package:indierocks_cubetero/domain/entities/producto.dart';


part 'get_productos_state.freezed.dart';

@freezed
abstract class GetProdcutosState with _$GetProdcutosState{

  const factory GetProdcutosState.available({
     required List<ProductoModel> listProducts
  }) = GetProductosAvailable;

  const factory GetProdcutosState.initial() = Initial;

  const factory GetProdcutosState.loading() = Loading;

  const factory GetProdcutosState.error({required final int statusCode, required final String message})= Error;

}
