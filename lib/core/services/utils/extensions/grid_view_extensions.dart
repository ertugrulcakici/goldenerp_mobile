import 'package:syncfusion_flutter_datagrid/datagrid.dart';

extension DataGridRowExtensions on DataGridRow {
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    for (var cell in getCells()) {
      map[cell.columnName] = cell.value;
    }
    return map;
  }
}
