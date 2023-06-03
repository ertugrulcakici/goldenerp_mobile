import 'package:goldenerp/core/services/auth/auth_service.dart';
import 'package:goldenerp/core/services/auth/user_model.dart';
import 'package:goldenerp/product/constants/app_constants.dart';
import 'package:goldenerp/product/constants/cache_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  // box isimleri şöyle isimlendirilecek:
  // {app_version}_{firm_name}_{user_id}_{box_name}
  static final CacheService _instance = CacheService._();
  static CacheService get instance => _instance;
  CacheService._();

  late final Box<dynamic> appSettingsBox;
  late final Box<String> boxesBox;
  late final Box<UserModel> userBox;

  String get _boxPrefix =>
      "${AppConstants.appVersion}_${AuthService.instance.user!.id}_";

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UserModelAdapter());

    CacheService._instance.appSettingsBox =
        await Hive.openBox(CacheConstants.app_settings);
    CacheService._instance.boxesBox = await Hive.openBox(CacheConstants.boxes);
    CacheService._instance.userBox = await Hive.openBox(CacheConstants.users);

    CacheService._instance.boxesBox.put(0, CacheConstants.app_settings);
    CacheService._instance.boxesBox.put(1, CacheConstants.boxes);
    CacheService._instance.boxesBox.put(2, CacheConstants.users);
  }

  Future<Box<T>> getFormBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(_boxPrefix + boxName)) {
      await Hive.openBox(_boxPrefix + boxName);
    }
    return Hive.box<T>(_boxPrefix + boxName);
  }
}
