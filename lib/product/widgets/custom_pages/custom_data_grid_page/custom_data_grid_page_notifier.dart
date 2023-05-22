import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/network/response_model.dart';
import 'package:goldenerp/product/mixins/error_notifier.dart';
import 'package:goldenerp/product/mixins/loading_notifier.dart';
import 'package:goldenerp/product/models/api/structure/field_model.dart';
import 'package:goldenerp/product/models/api/structure/list_data_model_of_list_of_stock_fiche_list.dart';
import 'package:goldenerp/product/models/api/structure/menu_item_model.dart';
import 'package:goldenerp/product/models/api/structure/request_scheme_model.dart';
import 'package:goldenerp/product/models/structure/own_data_grid_source.dart';

class CustomDataGridPageNotifier extends ChangeNotifier
    with LoadingNotifier, ErrorNotifier {
  OwnDataGridSource? dataSource;
  List<FieldModel> fields = [];
  List<MenuItemModel> menuItems = [];

  String apiUrl;
  RequestSchemeModel apiParams;
  CustomDataGridPageNotifier({required this.apiUrl, required this.apiParams});

  void search(String text) {
    // rebind uygulanacak
    // dataSource.clearFilters();
    // for (var element in fields.where((element) => element.widget_type == WidgetTypeEnums.column_text)) {
    //     text.split(" ").forEach((textPart) {
    //       if (textPart.isEmpty) {
    //         return;
    //       }
    //       dataSource.addFilter(
    //           element.col_name!,
    //           FilterCondition(
    //               type: FilterType.contains,
    //               filterBehavior: FilterBehavior.stringDataType,
    //               isCaseSensitive: false,
    //               filterOperator: FilterOperator.and,
    //               value: textPart));
    //     });
    // }
  }

  Future<void> getGridData() async {
    try {
      isLoading = true;
      fields.clear();
      menuItems.clear();
      dataSource = null;
      final ResponseModel responseModel =
          await NetworkService.post(apiUrl, body: apiParams.toJson());

      if (responseModel.success) {
        ListDataModelOfListOfStockFicheList typeDataModel =
            ListDataModelOfListOfStockFicheList.fromJson(responseModel.data!);
        log(typeDataModel.data.reversed.toList().toString());
        dataSource ??= OwnDataGridSource(
          rawData: typeDataModel.data.reversed.toList(),
          fieldModels: typeDataModel.fields!,
        );
        fields.addAll(typeDataModel.fields!);
        menuItems.addAll(typeDataModel.contextMenu ?? []);
      } else {
        errorMessage = responseModel.errorMessage;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }
}
