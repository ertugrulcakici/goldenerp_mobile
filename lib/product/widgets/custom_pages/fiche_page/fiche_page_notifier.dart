import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/cache/cache_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/network/response_model.dart';
import 'package:goldenerp/product/mixins/error_notifier.dart';
import 'package:goldenerp/product/mixins/loading_notifier.dart';
import 'package:goldenerp/product/models/api/structure/menu_item_model.dart';
import 'package:goldenerp/product/models/api/structure/request_scheme_model.dart';
import 'package:goldenerp/product/widgets/custom_pages/generic_page_creator.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FichePageNotifier extends ChangeNotifier
    with LoadingNotifier, ErrorNotifier {
  final MenuItemModel menuItemModel;
  final String apiUrl;
  final RequestSchemeModel apiParams;

  // TODO: product widget e yeniden build edildi logu koy ne zaman neden build edildiğine bak ve azalt
  FichePageNotifier(
      {required this.menuItemModel,
      required this.apiUrl,
      required this.apiParams});

  Box? box;

  late final GenericPageCreator genericPageCreator;

  Future<void> getFicheData() async {
    try {
      isLoading = true;
      box ??= await CacheService.instance.getFormBox(menuItemModel.name!);
      final ResponseModel responseModel =
          await NetworkService.post(apiUrl, body: apiParams.toJson());

      if (responseModel.success) {
        genericPageCreator = GenericPageCreator(
            json: responseModel.data, box: box!, mainSetState: notifyListeners);
        log("generic page oluşturuldu", name: "FichePageNotifier true");
      } else {
        errorMessage = responseModel.errorMessage;
        log("errorMessage: ${responseModel.errorMessage}",
            name: "FichePageNotifier false");
        throw Exception(responseModel.errorMessage);
      }
    } catch (e) {
      errorMessage = e.toString();
      log("errorMessage: ${e.toString()}", name: "FichePageNotifier catch");
    } finally {
      isLoading = false;
    }
  }

  Future<void> submit() async {}
}
