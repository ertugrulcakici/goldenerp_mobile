import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/utils/extensions/grid_view_extensions.dart';
import 'package:goldenerp/core/services/utils/extensions/list_extension.dart';
import 'package:goldenerp/core/services/utils/extensions/map_extensions.dart';
import 'package:goldenerp/product/models/api/structure/field_model.dart';
import 'package:goldenerp/product/models/api/structure/row_action_model.dart';
import 'package:goldenerp/product/models/structure/list_equality_object.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class OwnDataGridSource extends DataGridSource {
  List<FieldModel> fieldModels;
  final List rawData;

  OwnDataGridSource groupedSource(RowActionModel groupByModel) {
    List<ListEqualityObject> groupedKeys = [];
    List<dynamic> groupedValues = [];

    var copyData = rawData.copy;
    for (var originalData in copyData) {
      final rawDataRow = (originalData as Map).copy;
      List groupKeyValues = [];
      for (var element in groupByModel.keys) {
        groupKeyValues.add(rawDataRow[element]);
      }
      ListEqualityObject groupKeyValuesObject =
          ListEqualityObject(groupKeyValues);
      if (!groupedKeys.any((groupedKey) {
        return groupedKey == groupKeyValuesObject;
      })) {
        groupedKeys.add(groupKeyValuesObject);
        groupedValues.add(rawDataRow);
        continue;
      }
      int index = groupedKeys
          .indexWhere((groupedKey) => groupedKey == groupKeyValuesObject);

      final groupedValue = groupedValues[index] as Map;
      for (var columnAction in groupByModel.columns) {
        switch (columnAction.action) {
          case RowActionType.Sum:
            groupedValue[columnAction.key] =
                (groupedValue[columnAction.key] ?? 0) +
                    (rawDataRow[columnAction.key] ?? 0);

            break;
          case RowActionType.Max:

            // stringler için
            if (groupedValue[columnAction.key] is String) {
              if (groupedValue[columnAction.key]
                      .compareTo(rawDataRow[columnAction.key].toString()) <
                  0) {
                groupedValue[columnAction.key] = rawDataRow[columnAction.key];
              }
            }
            // num değerler için
            else {
              if ((groupedValue[columnAction.key] ?? 0) <
                  (rawDataRow[columnAction.key] ?? 0)) {
                groupedValue[columnAction.key] = rawDataRow[columnAction.key];
              }
            }

            break;

          case RowActionType.Min:

            // stringler için

            if (groupedValue[columnAction.key] is String) {
              if (groupedValue[columnAction.key]
                      .compareTo(rawDataRow[columnAction.key].toString()) >
                  0) {
                groupedValue[columnAction.key] = rawDataRow[columnAction.key];
              }
            }
            // num değerler için
            else {
              if ((groupedValue[columnAction.key] ?? 0) >
                  (rawDataRow[columnAction.key] ?? 0)) {
                groupedValue[columnAction.key] = rawDataRow[columnAction.key];
              }
            }

            break;
          default:
        }
      }
    }

    OwnDataGridSource source =
        OwnDataGridSource(rawData: groupedValues, fieldModels: fieldModels);
    return source;
  }

  // List<DataSourceModel>? dataSources;

  //
  // final Map<String, dynamic> dropDownValues = {};

  OwnDataGridSource({
    required this.rawData,
    required this.fieldModels,
    // this.dataSources
  }) {
    // _items = rawData.map<DataGridRow>((element) {
    //   List<DataGridCell> cells = [];
    //   for (var columnData in fieldModels) {
    //     cells.add(DataGridCell(
    //         columnName: columnData.col_name!,
    //         value: element is Map
    //             ? element[columnData.col_name]
    //             : element.toJson()[columnData.col_name]));
    //   }
    //   return DataGridRow(cells: cells);
    // }).toList();
    _items = rawData.map<DataGridRow>((e) {
      List<DataGridCell> cells = [];
      Map itemData = e is Map ? e : e.toJson();
      itemData.forEach((key, value) {
        cells.add(DataGridCell(columnName: key, value: value));
      });
      return DataGridRow(cells: cells);
    }).toList();
  }

  late final List<DataGridRow> _items;
  @override
  List<DataGridRow> get rows => _items;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    List<Widget> cells = [];
    final rowData = row.toJson();
    for (var fieldModel in fieldModels) {
      cells.add(Center(
          child: Text(rowData[fieldModel.col_name!]
              .toString()
              .replaceAll("null", "-"))));
    }
    return DataGridRowAdapter(cells: cells);
    // return DataGridRowAdapter(
    //     cells: row.getCells().map<Widget>((DataGridCell cell) {
    //   FieldModel fieldModel = fieldModels
    //       .firstWhere((element) => element.col_name == cell.columnName);
    //   if (fieldModel.widget_type == WidgetTypeEnums.image) {
    //     return Image.network(cell.value.toString());
    //   } else {
    //     // field model resim dışında bişeyse (text)
    //     // if (dataSources != null) {
    //     //   if (fieldModel.field_datasource != null) {
    //     //     DataSourceModel dSource = dataSources!.firstWhere(
    //     //         (element) => element.key == fieldModel.field_datasource!.key);
    //     //     Map ownData = dSource.DS.firstWhere((element) =>
    //     //         (element)[fieldModel.field_datasource!.ValueMemberColumn] ==
    //     //         cell.value);
    //     //     String value =
    //     //         ownData[fieldModel.field_datasource!.DisplayMemberColumn]
    //     //             .toString()
    //     //             .replaceAll("null", "-");
    //     //     return Text(value, maxLines: 1);
    //     //   }
    //     // }

    //     return Center(
    //         child: Text(cell.value.toString().replaceAll("null", "-"),
    //             maxLines: 4));
    //   }
    // }).toList());
  }

  rebindDataGridSource(var items) {
    _items.clear();
    _items.addAll(items.map<DataGridRow>((element) {
      List<DataGridCell> cells = [];
      for (var columnData in fieldModels) {
        cells.add(DataGridCell(
            columnName: columnData.col_name!,
            value: element is Map
                ? element[columnData.col_name]
                : element.toJson()[columnData.col_name]));
      }
      return DataGridRow(cells: cells);
    }).toList());
    notifyListeners();
  }

  DataGridRow addNewRow(Map<String, dynamic> item) {
    List<DataGridCell> cells = [];
    for (var columnData in fieldModels) {
      cells.add(DataGridCell(
          columnName: columnData.col_name!, value: item[columnData.col_name]));
    }
    final dgr = DataGridRow(cells: cells);
    log("addNewRow: ${dgr.toJson()}");
    _items.add(dgr);
    notifyListeners();
    return dgr;
  }

  removeRow(DataGridRow row) {
    _items.remove(row);
    notifyListeners();
  }
}
