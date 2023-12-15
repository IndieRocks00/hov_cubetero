

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:indierocks_cubetero/data/models/res_api_model.dart';

part 'api_state.freezed.dart';

@freezed
abstract class ApiState with _$ApiState{

  const factory ApiState.available({
     required ResApiModel apiState
  }) = ApiAvailable;

  const factory ApiState.initial() = Initial;
  const factory ApiState.loading() = Loading;
  const factory ApiState.error({required final int statuscode, required final String message}) = Error;

}