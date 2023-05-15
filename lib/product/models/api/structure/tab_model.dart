// ignore_for_file: non_constant_identifier_names

import 'package:goldenerp/product/models/api/structure/field_model.dart';

class TabModel {
  // gelen data
  late final String tab_title;
  bool? check_validator;

  // alt datalar
  // late final List<FieldModel> fields;
  late final List<FieldModel> widgets;

  // üretilen data
  final Set<String> table_names = {};

  TabModel.fromJson(Map json) {
    // gelen data
    tab_title = json["tab_title"];
    check_validator = json["check_validator"];
    widgets = (json["widgets"] as List).map((e) {
      FieldModel model = FieldModel.fromJson(e, tabTitle: tab_title);
      if (model.table_name != null) {
        table_names.add(model.table_name!);
      }
      return model;
    }).toList();
  }
}
