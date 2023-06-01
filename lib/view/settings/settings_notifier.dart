import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/cache/cache_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/product/constants/cache_constants.dart';
import 'package:goldenerp/product/mixins/loading_notifier.dart';
import 'package:goldenerp/product/models/structure/firm_model.dart';

abstract class ISettingsNotifier {
  List<FirmModel> firms = [];
  int? selectedFirmId;
  ISettingsNotifier();

  void getFirms();
  Future<bool> addFirm(Map<String, dynamic> data);
  Future<bool> selectFirmById(int firmId);
  Future<bool> deleteFirmById(int firmId);
}

class SettingsNotifier extends ChangeNotifier
    with LoadingNotifier
    implements ISettingsNotifier {
  SettingsNotifier();

  @override
  List<FirmModel> firms = [];

  @override
  int? selectedFirmId;

  @override
  Future<bool> addFirm(Map<String, dynamic> data) async {
    if (CacheService.instance.firms.isEmpty) {
      data["id"] = 1;
    } else {
      data["id"] = CacheService.instance.firms.keys.last + 1;
    }
    FirmModel firm = FirmModel.fromJson(data);
    await CacheService.instance.firms.put(firm.id, firm);
    firms.add(firm);
    await selectFirmById(firm.id);
    return true;
  }

  @override
  Future<bool> deleteFirmById(int firmId) async {
    isLoading = true;
    try {
      await CacheService.instance.firms.delete(firmId);
      if (selectedFirmId == firmId) {
        selectedFirmId = null;
        CacheService.instance.appSettingsBox.delete(CacheConstants.firm_id);
        if (firms.isNotEmpty) {
          selectFirmById(firms.first.id);
        }
      }
      getFirms();
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  @override
  void getFirms() {
    isLoading = true;
    firms.clear();
    for (var element in CacheService.instance.firms.values) {
      firms.add(element);
    }
    selectedFirmId =
        CacheService.instance.appSettingsBox.get(CacheConstants.firm_id);
    isLoading = false;
  }

  @override
  Future<bool> selectFirmById(int firmId) async {
    if (selectedFirmId == firmId) {
      return true;
    }
    isLoading = true;
    try {
      await CacheService.instance.appSettingsBox.put(CacheConstants.firm_id,
          firms.firstWhere((element) => element.id == firmId).id);
      selectedFirmId = firmId;
      NetworkService.init(CacheService.instance.firms.get(firmId)!.api);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
