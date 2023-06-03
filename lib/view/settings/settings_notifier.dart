// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/cache/cache_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/product/constants/cache_constants.dart';
import 'package:goldenerp/product/mixins/loading_notifier.dart';

abstract class ISettingsNotifier {
  String? _app_api;
  String? get app_api => _app_api;
  ISettingsNotifier();
  Future<bool> getApi();
  Future<bool> setApi(String value);
}

class SettingsNotifier extends ChangeNotifier
    with LoadingNotifier
    implements ISettingsNotifier {
  SettingsNotifier();

  @override
  Future<bool> getApi() async {
    try {
      isLoading = true;
      _app_api = await CacheService.instance.appSettingsBox
          .get(CacheConstants.app_api);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  @override
  String? _app_api;

  @override
  String? get app_api => _app_api;

  @override
  Future<bool> setApi(String value) async {
    try {
      isLoading = true;
      await CacheService.instance.appSettingsBox
          .put(CacheConstants.app_api, value);
      _app_api = value;
      NetworkService.init(value);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
