

import 'package:indierocks_cubetero/domain/repositories/iversion_app_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionAppRepository implements IVersionAppRepository{

  @override
  Future<String> getVersionApp() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String ver = packageInfo.version;
    print(ver);
    return ver;
  }

}