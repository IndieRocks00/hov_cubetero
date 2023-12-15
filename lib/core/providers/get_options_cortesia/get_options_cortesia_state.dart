

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:indierocks_cubetero/data/models/cortesia_model.dart';

part 'get_options_cortesia_state.freezed.dart';

@freezed
class GetOptionsCortesiaState with _$GetOptionsCortesiaState{
  const factory GetOptionsCortesiaState.available({
      required List<CortesiaModel> listCortesia
  }) = GetProductosAvailable;

  const factory GetOptionsCortesiaState.initial() = Initial;

  const factory GetOptionsCortesiaState.loading() = Loaging;

  const factory GetOptionsCortesiaState.error({required int rcode, required String message}) = Error;

}