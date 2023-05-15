import 'package:goldenerp/product/models/api/data/stock_fiche_list_model.dart';
import 'package:goldenerp/product/models/api/structure/field_model.dart';
import 'package:goldenerp/product/models/api/structure/menu_item_model.dart';

class ListDataModelOfListOfStockFicheList {
  List<FieldModel>? fields;
  List<MenuItemModel>? contextMenu;
  late final List<StockFicheList> data;

  ListDataModelOfListOfStockFicheList.fromJson(Map<String, dynamic> json) {
    fields = json['fields'] != null
        ? (json['fields'] as List).map((e) => FieldModel.fromJson(e)).toList()
        : null;
    contextMenu = json['context_menu'] != null
        ? (json['context_menu'] as List)
            .map((e) => MenuItemModel.fromJson(e))
            .toList()
        : null;
    data = (json['data'] as List) // <== This line
        .map((e) => StockFicheList.fromJson(e))
        .toList();
  }
}
