
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState{

  const factory LoginState.available({
      required UserModel userModel,
    }) = LoginAvailable;

  const factory LoginState.initial() = Initial;
  const factory LoginState.loading() = Loading;
  const factory LoginState.error({required final String message,required final int statuscode}) = Error;


}