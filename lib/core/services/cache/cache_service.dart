import 'dart:developer';

import 'package:goldenerp/core/services/auth/auth_service.dart';
import 'package:goldenerp/core/services/auth/user_model.dart';
import 'package:goldenerp/product/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'cache_service_type_id_list.dart';

class CacheService {
  // box isimleri şöyle isimlendirilecek:
  // {app_version}_{firm_name}_{user_id}_{box_name}
  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;
  CacheService._();

  late final Box<dynamic> appSettingsBox;
  late final Box<String> boxesBox;
  late final Box<UserModel> userBox;
  late final Box<Map<String, dynamic>> firms;

  // String get _boxPrefix => "${AppConstants.appVersion}_"
  //     "${CacheService.instance.getString(CacheConstants.firm_name)}_"
  //     "${CacheService.instance.getInt(CacheConstants.user_id)}_";

  String get _boxPrefix =>
      "${AppConstants.appVersion}_${AppConstants.tempFirmId}_${AuthService.instance.user!.id}_";

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());

    CacheService._instance.appSettingsBox = await Hive.openBox("app_settings");
    CacheService._instance.boxesBox = await Hive.openBox("boxes");
    CacheService._instance.userBox = await Hive.openBox("users");
    CacheService._instance.firms = await Hive.openBox("firms");

    CacheService._instance.boxesBox.put(0, "app_settings");
    CacheService._instance.boxesBox.put(1, "boxes");
    CacheService._instance.boxesBox.put(2, "users");
    CacheService._instance.boxesBox.put(3, "firms");
  }

  Future<Box<T>> getFormBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(_boxPrefix + boxName)) {
      log("Box açılıyor: ${_boxPrefix + boxName}");
      await Hive.openBox(_boxPrefix + boxName);
    }
    return Hive.box<T>(_boxPrefix + boxName);
  }
}
