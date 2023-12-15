
enum DBHelperItem{
  dataBaseName,
  nameTable,
  versionBD,
  user_id,
  user,
  user_pass,
  user_balance,
  user_name_client,
  data_encripted
}

extension DBHelperItemExtension on DBHelperItem{
  getValue(){
    switch(this){
      case DBHelperItem.dataBaseName:
        return 'hov_db_cubetero.db';
      case DBHelperItem.nameTable:
        return 'UserLogin';
      case DBHelperItem.versionBD:
        return 2;
      case DBHelperItem.user_id:
        return 'ID';
      case DBHelperItem.user:
        return 'USER';
      case DBHelperItem.user_pass:
        return 'PASSWORD';
      case DBHelperItem.user_balance:
        return 'BALANCE';
      case DBHelperItem.user_name_client:
        return 'NAMECLIENT';
      case DBHelperItem.data_encripted:
        return 'DATA_ENCRIPTED';

      default:
        return "";
    }
  }
}