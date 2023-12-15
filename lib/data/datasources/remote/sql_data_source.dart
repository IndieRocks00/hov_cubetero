

import 'package:indierocks_cubetero/data/datasources/helper/db_helper_item.dart';
import 'package:indierocks_cubetero/data/datasources/remote/repositories/sql_data_repository.dart';
import 'package:indierocks_cubetero/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class SqlDataSource implements ISqlDataSource{

  SqlDataSource({
    required Future<Database> database
  }) : assert(database != null) ,
        _database = database;

  final Future<Database> _database;

  static instance()  {
    String query = 'CREATE TABLE ${DBHelperItem.nameTable.getValue()} '
                    '(${DBHelperItem.user_id.getValue()} INTEGER PRIMARY KEY, '
                    '${DBHelperItem.user.getValue()} TEXT, '
                    '${DBHelperItem.user_pass.getValue()} TEXT, '
                    '${DBHelperItem.user_balance.getValue()} TEXT, '
                    '${DBHelperItem.user_name_client.getValue()} TEXT, '
                    '${DBHelperItem.data_encripted.getValue()} TEXT )';
    //print(query);
    return  openDatabase(DBHelperItem.dataBaseName.getValue(),
        version: DBHelperItem.versionBD.getValue(),
        onCreate: (Database database, int version ) async{
           await database.execute(query);
        },
        onUpgrade: ((db, oldVersion, newVersion) {
          if (oldVersion<newVersion){
            db.execute('DROP TABLE IF EXISTS ${DBHelperItem.nameTable.getValue()}');
            db.execute(query);
          }
        })
    );
  }

  @override
  Future<bool> deleteUser() async {
    //var db = await instance();
    var db = await _database;
    final id = await db.delete(DBHelperItem.nameTable.getValue());
    //print('SQLITE: DeleteTable: $id');
    //db.close();
    return id > 0;
  }

  @override
  Future<UserModel?> getUser() async {
    try{
      //print('llamado a getUser SQL data_source');
      //var _database = await instance();
      var db = await _database;
      final List<Map<String, dynamic>> result = await db.query(
        DBHelperItem.nameTable.getValue(),
        // Aquí puedes agregar condiciones, cláusulas WHERE, etc., si es necesario
      );
      //print('Resultado obtenido ${result.toString()}');
      //print('Valor de condicion isnotempy  ${result.isNotEmpty}');
      //db.close();
      if (result.isNotEmpty) {
        print('Conversion de db a usermodel : ${UserModel.fromMap(result.first).toJson()}');
        // Suponiendo que UserModel tiene un constructor fromMap que convierte el resultado del query a UserModel
        return UserModel.fromMap(result.first);
      } else {
        print('Conversion de db a usermodel : No se obtuvo valor');
        return null;
      }
    }catch(e){
      return null;
      //print('Error en dataSource sql ${e.toString()}');
    }

  }

  @override
  Future<bool> insertUser(UserModel userModel) async {
    //print('SQLITE: InitInsert: ');
    var db = await _database;
    var in_id = {'id':1};
    var data = userModel.toJson();
    data.addEntries(in_id.entries);
    final id = await db.insert(DBHelperItem.nameTable.getValue(), data, conflictAlgorithm: ConflictAlgorithm.replace);
    //getUser();
    print('SQLITE: SAVELOGIN: $id');
    //db.close();
    return id>0;
  }


}