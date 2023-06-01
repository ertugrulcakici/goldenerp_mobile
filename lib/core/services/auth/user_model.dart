import 'package:goldenerp/core/services/cache/cache_service.dart';
import 'package:goldenerp/product/constants/cache_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

// giriş yapmış kullanıcı id si last_logged_in olacak. Giriş yapılamazsa bu key temizlenecek.
@HiveType(typeId: CacheConstants.userModelTypeId)
class UserModel extends HiveObject {
  @HiveField(0)
  late final int id;
  @HiveField(1)
  late final String logonName;
  @HiveField(2)
  late final String password;
  @HiveField(3)
  late final String nameSurname;
  @HiveField(4)
  String? email;
  @HiveField(5)
  String? phone;
  @HiveField(6)
  String? authCode;
  @HiveField(7)
  late final String branch;

  UserModel({
    required this.id,
    required this.logonName,
    required this.password,
    required this.nameSurname,
    this.email,
    this.phone,
    this.authCode,
    required this.branch,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['ID'];
    logonName = json['LogonName'];
    password = json['Password'];
    nameSurname = json['NameSurname'];
    email = json['Email'];
    phone = json['Phone'];
    authCode = json['AuthCode'];
    branch = json['Branch'];
  }

  factory UserModel.fromLastLogin() {
    try {
      return CacheService.instance.userBox.get(CacheService
          .instance.appSettingsBox
          .get(CacheConstants.last_logged_in))!;
    } catch (e) {
      throw Exception("Daha önce giriş yapmış kullanıcı bulunamadı.");
    }
  }

  @override
  Future<void> save() async {
    await CacheService.instance.userBox.put(
      id,
      this,
    );
  }

  Future<void> saveAsLastLogged() async {
    await CacheService.instance.appSettingsBox.put(
      CacheConstants.last_logged_in,
      id,
    );
  }

  static Future<void> clearLastLogged() async {
    await CacheService.instance.appSettingsBox
        .delete(CacheConstants.last_logged_in);
  }

  @override
  Future<void> delete() {
    return CacheService.instance.userBox.delete(id);
  }
}
