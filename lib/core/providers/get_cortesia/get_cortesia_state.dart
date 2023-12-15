

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:indierocks_cubetero/data/models/result_cortesia_model.dart';

part 'get_cortesia_state.freezed.dart';

@freezed
abstract class GetCortesiaState with _$GetCortesiaState{

  const factory GetCortesiaState.available({
    required ResultCortesiaModel resultCortesiaModel
  }) = GetCortesiaAvaible;

  const factory GetCortesiaState.initial() = Initial;

  const factory GetCortesiaState.loading() = Loading;

  const factory GetCortesiaState.error({required final int statusCode, required final String message}) = Error;
}
