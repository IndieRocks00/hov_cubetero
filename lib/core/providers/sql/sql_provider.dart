
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indierocks_cubetero/core/providers/sql/sql_user_state.dart';
import 'package:indierocks_cubetero/data/datasources/remote/sql_data_source.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:indierocks_cubetero/data/repositories/sql_data_repository.dart';
import 'package:indierocks_cubetero/domain/use_cases/sql_data_uses_case.dart';

part 'sql_user_state_notifier.dart';


final  sqlUserNotifier = StateNotifierProvider<SqlUserNotifier,SqlUserState>((ref){
  final getSqlUser = ref.watch(_getUser);
  final logOut_sql = ref.watch(_logOut);
  final res = SqlUserNotifier(
      getUser: getSqlUser,
      logOut: logOut_sql
  );
  return res;
});

final sqlRepository = Provider<SqlDataRepository>((ref)  {

  print('Inicio de repositorio');
  return SqlDataRepository(
    sqlRepository:  SqlDataSource(
        database:  SqlDataSource.instance(),
    ),
  );
});


///Use case
final _insertUser = Provider<InsertUser>((ref){
  final repository = ref.watch(sqlRepository);
  return InsertUser(repository: repository);
});

final _getUser = Provider<GetUser>((ref){
  final repository = ref.watch(sqlRepository);
  return GetUser(repository: repository);
});

final _logOut = Provider<LogOut>((ref){
  print('llamado a getUser Provider');
  final repository = ref.watch(sqlRepository);
  print('SQL Provider : ${repository}');
  return LogOut(repository: repository);
});
