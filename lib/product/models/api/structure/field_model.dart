// ignore_for_file: non_constant_identifier_names

import 'package:goldenerp/product/enums/widget_type.dart';
import 'package:goldenerp/product/models/api/structure/default_value_model.dart';
import 'package:goldenerp/product/models/api/structure/field_datasource_model.dart';
import 'package:goldenerp/product/models/api/structure/validation_model.dart';

class FieldModel {
  String? parent_type;
  String? tab_name;
  String? table_name;
  String? col_name;
  String? title;
  WidgetTypeEnums? widget_type;
  FieldDataSourceModel? field_datasource;
  late bool editable;
  DefaultValueModel? default_value_model;
  ValidationModel? validator;
  List<FieldModel>? sub_objects;
  String? tabTitle;
  String? api_url;

  late final bool? visible;

  FieldModel.fromJson(Map<String, dynamic> json, {this.tabTitle}) {
    parent_type = json['parent_type'];
    // log("parent_type: $parent_type");
    tab_name = json['tab_name'];
    // log("tab_name: $tab_name");
    table_name = json['table_name'];
    // log("table_name: $table_name");
    col_name = json['col_name'];
    // log("col_name: $col_name");
    title = json['title'];
    // log("title: $title");
    widget_type = json['widget_type'] != null
        ? WidgetTypeEnums.values
            .firstWhere((e) => e.toString() == json['widget_type'])
        : null;
    // log("widget_type: $widget_type");
    field_datasource = json['field_datasource'] != null
        ? FieldDataSourceModel.fromJson(json['field_datasource'])
        : null;

    // log("field_datasource: $field_datasource");
    editable = json['editable'];
    // log("editable: $editable");
    default_value_model = json['default_value'] != null
        ? DefaultValueModel.fromJson(json['default_value'])
        : null;
    // log("default_value: $default_value");
    validator = json['validator'] != null
        ? ValidationModel.fromJson(json['validator'])
        : null;
    // log("validator: $validator");
    if (json['sub_objects'] != null) {
      sub_objects = <FieldModel>[];
      json['sub_objects'].forEach((v) {
        sub_objects!.add(FieldModel.fromJson(v, tabTitle: tabTitle));
      });
    }
    // log("sub_objects: $sub_objects");
    visible = json['visible'];
    // log("visible: $visible");
    api_url = json['api_url'];
  }

  @override
  String toString() {
    return 'FieldModel{parent_type: $parent_type, tab_name: $tab_name, table_name: $table_name, col_name: $col_name, title: $title, widget_type: $widget_type, field_datasource: $field_datasource, editable: $editable, default_value: $default_value_model, validator: $validator, sub_objects: $sub_objects, tabTitle: $tabTitle, visible: $visible, api_url: $api_url}';
  }
}
