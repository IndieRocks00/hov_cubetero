import 'dart:async';
import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'Model/LoginModel.dart';

class DataBaseHelper{

  DataBaseHelper._();

  static DataBaseHelper instance = DataBaseHelper._();


  static Future<Database> db() async{
    return openDatabase(DBHelperItem.dataBaseName.getValue(),
      version: DBHelperItem.versionBD.getValue(),
      onCreate: (Database database, int version ) async{
        return database.execute('CREATE TABLE ${DBHelperItem.nameTable.getValue()} (${DBHelperItem.id.getValue()} INTEGER PRIMARY KEY, ${DBHelperItem.user.getValue()} TEXT, ${DBHelperItem.pass.getValue()} TEXT, ${DBHelperItem.balance.getValue()} TEXT, ${DBHelperItem.nameClient.getValue()} TEXT )');
      }
    );
  }

  static Future<int> deleteLogin() async{
    final db = await DataBaseHelper.db();
    final id = await db.delete(DBHelperItem.nameTable.getValue());
    print('SQLITE: DeleteTaBle: $id');
    return id;
  }

  static Future<int> saveLogin(LoginModel loginModel) async{
    final db = await DataBaseHelper.db();
    final id = await db.insert(DBHelperItem.nameTable.getValue(), loginModel.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    print('SQLITE: SAVELOGIN: $id');
    return id;
  }

  static Future<int> updateBalance(String balance) async{
    final db = await DataBaseHelper.db();
    final id = await db.update(
        DBHelperItem.nameTable.getValue(),
        {
          DBHelperItem.balance.getValue(): balance
        },
        where: '${DBHelperItem.id.getValue()}'
    );
    print('SQLITE: UPDATE: $id');
    return id;
  }
  static  getValue(String column) async{
    final db = await DataBaseHelper.db();
    final res = await db.query(
      DBHelperItem.nameTable.getValue(),
        columns: [column],
        where:'${DBHelperItem.id.getValue()} = 1',
    );
    if(res.isEmpty){
      return "";
    }
    print('SQLITE: GETDATA: ${res[0][column]}');
    return  res[0][column];
  }

}

enum DBHelperItem{
  dataBaseName,
  nameTable,
  versionBD,
  id,
  user,
  pass,
  balance,
  nameClient
}

extension DBHelperItemExtension on DBHelperItem{
  getValue(){
    switch(this){
      case DBHelperItem.dataBaseName:
        return 'indierocks_database.db';
      case DBHelperItem.nameTable:
        return 'UserLogin';
      case DBHelperItem.versionBD:
        return 1;
      case DBHelperItem.id:
        return 'ID';
      case DBHelperItem.user:
        return 'USER';
      case DBHelperItem.pass:
        return 'PASS';
      case DBHelperItem.balance:
        return 'BALANCE';
      case DBHelperItem.nameClient:
        return 'NAME_CLIENT';

      default:
        return "";
    }
  }
}