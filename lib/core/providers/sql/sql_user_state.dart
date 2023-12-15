
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';

part 'sql_user_state.freezed.dart';

@freezed
abstract class SqlUserState with _$SqlUserState{

  const factory SqlUserState.available({
    required UserModel userModel,
  }) = UserAvailable;

  const factory SqlUserState.initial() = Initial;
  const factory SqlUserState.loading() = Loading;
  const factory SqlUserState.error() = Error;


}