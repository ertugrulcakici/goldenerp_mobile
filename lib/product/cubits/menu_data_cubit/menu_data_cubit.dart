import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:goldenerp/product/models/api/structure/menu_item_model.dart';

class MenuDataCubit extends Cubit<List<MenuItemModel>> {
  MenuDataCubit() : super([]);

  void setMenuData(List data) {
    log("data: $data");
    emit(data.map((e) => MenuItemModel.fromJson(e)).toList());
  }
}
