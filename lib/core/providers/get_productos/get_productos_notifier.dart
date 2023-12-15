


part of '../providers.dart';


class GetProductosNotifier extends StateNotifier<getProductosState.GetProdcutosState>{

  GetProductosNotifier({
    required GetProductos getProductos
}):
  assert(getProductos!= null),
  _getProductos = getProductos,
      super(getProductosState.GetProdcutosState.initial());

  GetProductos _getProductos;

  void reset() => state = getProductosState.Initial();

  Future<void> getProductos(String code_user_encripted)async {
    state = getProductosState.Loading();

    final result = await _getProductos(code_user_encripted);

    result.fold(
            (error) => state = getProductosState.Error(statusCode: error.statusCode, message: error.message),
            (productos) => state = getProductosState.GetProductosAvailable(listProducts: productos)
    );

  }

}