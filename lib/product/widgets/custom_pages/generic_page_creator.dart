// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/network/response_model.dart';
import 'package:goldenerp/core/services/utils/extensions/box_extensions.dart';
import 'package:goldenerp/core/services/utils/extensions/grid_view_extensions.dart';
import 'package:goldenerp/core/services/utils/extensions/list_extension.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/core/services/utils/validators/field_model_validators.dart';
import 'package:goldenerp/core/utils/extensions/ui_extensions.dart';
import 'package:goldenerp/product/enums/widget_type.dart';
import 'package:goldenerp/product/models/api/structure/condition_model.dart';
import 'package:goldenerp/product/models/api/structure/data_source_model.dart';
import 'package:goldenerp/product/models/api/structure/ds_relations_model.dart';
import 'package:goldenerp/product/models/api/structure/field_model.dart';
import 'package:goldenerp/product/models/api/structure/menu_item_model.dart';
import 'package:goldenerp/product/models/api/structure/row_action_model.dart';
import 'package:goldenerp/product/models/api/structure/tab_model.dart';
import 'package:goldenerp/product/models/api/structure/table_relation_model.dart';
import 'package:goldenerp/product/models/structure/own_data_grid_source.dart';
import 'package:goldenerp/product/widgets/custom_widgets/searchable_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class GenericPageCreator {
  final Map json;
  final Box box;
  // Map<String, List<Map<String, dynamic>>>? server_submit_data;
  Map? server_submit_data;
  final Function() mainSetState;
  late final bool isLocal;
  // gelen data
  late final List<DataSourceModel> datasources;
  late final List<MenuItemModel>? context_menu;
  late final List<TabModel> tabs;
  List<DSRelationsModel>? ds_relations;
  List<TableRelationModel>? table_relations; // submitToServer de kullanılacak
  List<ConditionModel>? conditions;
  RowActionModel? row_action;

  dynamic save_relations;
  // üretilen data,
  final Map<String, List> deleted_lines = {};
  final Set<String> all_table_names = {};
  final List<String> tab_titles = [];
  Map<String, GlobalKey<FormState>> formKeys = {};

  // submit data
  // Map<String, List<Map<String, dynamic>>> submit_data = {};
  Map submit_data = {};
  Map<String, Map<String, dynamic>> submit_data_temps = {};
  Map<String, Map<String, TextEditingController>> controllers = {};

  GenericPageCreator({
    required this.json,
    required this.box,
    required this.mainSetState,
  }) {
    // gelen data
    datasources = (json["datasources"] as List)
        .map<DataSourceModel>((e) => DataSourceModel.fromJson(e))
        .toList()
        .cast<DataSourceModel>();
    context_menu = json["context_menu"] != null
        ? (json["context_menu"] as List)
            .map<MenuItemModel>((e) => MenuItemModel.fromJson(e))
            .toList()
            .cast<MenuItemModel>()
        : null;
    tabs = (json["tabs"] as List)
        .map<TabModel>((e) {
          TabModel tabModel = TabModel.fromJson(e);
          all_table_names.addAll(tabModel.widgets
              .where((element) => element.table_name != null)
              .map((e) => e.table_name!));
          tab_titles.add(tabModel.tab_title);
          return tabModel;
        })
        .toList()
        .cast<TabModel>();
    server_submit_data = json["data"];
    ds_relations = json["ds_relations"] != null
        ? (json["ds_relations"] as List)
            .map<DSRelationsModel>((e) => DSRelationsModel.fromJson(e))
            .toList()
            .cast<DSRelationsModel>()
        : null;

    table_relations = json["table_relations"] != null
        ? (json["table_relations"] as List)
            .map<TableRelationModel>((e) => TableRelationModel.fromJson(e))
            .toList()
            .cast<TableRelationModel>()
        : null;

    row_action = json["row_action"] != null
        ? RowActionModel.fromJson(json["row_action"])
        : null;

    conditions = json["conditions"] != null
        ? (json["conditions"] as List)
            .map<ConditionModel>((e) => ConditionModel.fromJson(e))
            .toList()
            .cast<ConditionModel>()
        : null;

    save_relations = json["save_relations"];

    // Dataların kurulumları bitti

    // submit data da ve controllers da tablar için boş liste ve maplar oluşturuluyor
    for (var element in all_table_names) {
      submit_data[element] = [];
      submit_data_temps[element] = {};
      deleted_lines[element] = [];
      controllers[element] = {};
    }

    // farklı validatorler için form keyleri kuruyor
    for (var element in tabs) {
      formKeys[element.tab_title] = GlobalKey<FormState>();
    }

    // temp datalara default değerler yazıyor
    for (var element in tabs) {
      for (var element in element.widgets) {
        if (element.table_name != null &&
            element.col_name != null &&
            element.default_value_model != null) {
          submit_data_temps[element.table_name!]![element.col_name!] =
              element.default_value_model?.value;
        }
      }
    }

    // boxa veya data ya göre submit data dolduruluyor
    if (server_submit_data == null) {
      isLocal = true;
      box.toMap().forEach((key, value) {
        if (all_table_names.contains(key)) {
          submit_data[key] = value;
        }
      });
      PopupHelper.showInfoSnackBar("Form eski verilerden yeniden yüklendi.");
    } else {
      isLocal = false;
      server_submit_data!.forEach(
        (key, value) {
          submit_data[key] = value;
          if (value.isNotEmpty) {
            submit_data_temps[key] = value.last;
          }
        },
      );
    }

    // relationlar için submit data dolduruluyor
    if (ds_relations != null) {
      for (var relation in ds_relations!) {
        if (!datasources.any((element) => element.key == relation.ds_key)) {
          continue;
        }
        DataSourceModel dataSource =
            datasources.firstWhere((element) => element.key == relation.ds_key);
        for (var index = 0;
            index < submit_data[relation.table_name].length;
            index++) {
          var itemData = submit_data[relation.table_name][index];
          if (!dataSource.DS.any((element) =>
              element[relation.uniq_ds_field] ==
              itemData[relation.uniq_data_field])) {
            continue;
          }

          Map<String, dynamic> itemDataInDS = dataSource.DS.firstWhere(
              (element) =>
                  element[relation.uniq_ds_field] ==
                  itemData[relation.uniq_data_field]);

          itemDataInDS.forEach((key, value) {
            if (!itemData.containsKey(key) || itemData[key] == null) {
              itemData[key] = value;
            }
          });

          for (var subRelation in relation.sub_relations) {
            itemData[subRelation.uniq_data_field] =
                itemDataInDS[subRelation.uniq_ds_field];
          }
        }
      }
    }
  }

  Widget fieldModelToWidget(final FieldModel fieldModel) {
    // default valueler yazdırılacak
    if (isLocal) {
      // online fişlerde zaten verisi geliyor
      if (fieldModel.default_value_model != null) {
        if (fieldModel.default_value_model!.value != null) {
          submit_data_temps[fieldModel.table_name!]![fieldModel.col_name!] =
              fieldModel.default_value_model!.value;
          log("field model col name: ${fieldModel.col_name!}");
          log("field model table name: ${fieldModel.table_name!}");
          log("default value: ${fieldModel.default_value_model!.value}",
              name: "GenericPageCreator");
        }
        // box.set(fieldModel.table_name!, fieldModel.col_name!, fieldModel.default_value_model);
      }
    }

    late final Widget widget;
    if (fieldModel.editable) {
      widget = _fieldModelToWidget(fieldModel);
    } else {
      widget = Container(
          color: Colors.grey[200],
          child: AbsorbPointer(child: _fieldModelToWidget(fieldModel)));
    }

    return Visibility(visible: fieldModel.visible ?? false, child: widget);
  }

  Widget _fieldModelToWidget(final FieldModel fieldModel) {
    switch (fieldModel.widget_type) {
      case WidgetTypeEnums.searchablewidget:
        return _searchableWidget(fieldModel);
      case WidgetTypeEnums.text:
        return _text(fieldModel);
      case WidgetTypeEnums.textedit:
        return _textEdit(fieldModel);
      case WidgetTypeEnums.datagrid:
        return _dataGrid(fieldModel);
      case WidgetTypeEnums.spin_0:
        return _spinInt(fieldModel);
      case WidgetTypeEnums.spin_1:
        return _spinDouble(fieldModel, precise: 1);
      case WidgetTypeEnums.spin_2:
        return _spinDouble(fieldModel, precise: 2);
      case WidgetTypeEnums.spin_3:
        return _spinDouble(fieldModel, precise: 3);
      case WidgetTypeEnums.spin_4:
        return _spinDouble(fieldModel, precise: 4);
      case WidgetTypeEnums.spin_5:
        return _spinDouble(fieldModel, precise: 5);
      case WidgetTypeEnums.spin_6:
        return _spinDouble(fieldModel, precise: 6);
      case WidgetTypeEnums.dropdown:
        return _dropDown(fieldModel);
      default:
        return Text(
            "title: ${fieldModel.title} type: ${fieldModel.widget_type}");
    }
  }

  // widgets
  Widget _searchableWidget(FieldModel fieldModel) {
    DataSourceModel dataSource = datasources.firstWhere(
        (element) => element.key == fieldModel.field_datasource!.key);
    return SearchableWidget(
        genericPageCreator: this,
        productDataSource: dataSource,
        fieldModel: fieldModel,
        submit_data: submit_data,
        submit_data_temps: submit_data_temps,
        currentFormKey: formKeys[fieldModel.tabTitle]!,
        mainSetState: mainSetState,
        isLocal: isLocal,
        box: box);
  }

  Widget _text(FieldModel fieldModel) {
    String value = "";
    if (fieldModel.field_datasource != null) {
      value = datasources
          .firstWhere(
              (element) => element.key == fieldModel.field_datasource!.key)
          .DS
          .firstWhere((element) => element[fieldModel
                  .field_datasource!.ValueMemberColumn ==
              fieldModel.default_value_model
                  ?.value])[fieldModel.field_datasource!.DisplayMemberColumn]
          .toString();
    } else {
      value = fieldModel.default_value_model?.value.toString() ?? "";
    }
    if (fieldModel.title != null) {
      return Text("${fieldModel.title}: $value");
    } else {
      return Text(value);
    }
  }

  Widget _textEdit(FieldModel fieldModel) {
    final TextEditingController controller = _initAndGetController(fieldModel);

    return TextFormField(
      textInputAction: TextInputAction.next,
      controller: _initAndGetController(fieldModel),
      autovalidateMode: AutovalidateMode.always,
      validator: FieldModelValidator(fieldModel).validator,
      decoration: InputDecoration(
          labelText: fieldModel.title ?? "Başlık boş geldi",
          suffixIcon: _getSyncButton(fieldModel, controller)),
      onSaved: (newValue) {
        if (fieldModel.visible == false) {
          return;

          /// default valuelerin eklenmesi için, burada hiçbir değer eklemedik. [submitToServer] da ekledik
        }
        submit_data_temps[fieldModel.table_name!]![fieldModel.col_name!] =
            newValue;
      },
      onChanged: (value) {
        if (formKeys[fieldModel.tabTitle]!.currentState!.validate()) {
          formKeys[fieldModel.tabTitle]!.currentState!.save();
          if (isLocal) {
            box.fromJson(submit_data);
          }
        }
      },
    );
  }

  Widget _spinInt(FieldModel fieldModel) {
    final TextEditingController controller = _initAndGetController(fieldModel);

    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.always,
      validator: FieldModelValidator(fieldModel).validator,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          labelText: fieldModel.title ?? "Başlık boş geldi",
          suffixIcon: _getSyncButton(fieldModel, controller)),
      onSaved: (value) {
        if (fieldModel.visible == false) {
          return;

          /// default valuelerin eklenmesi için, burada hiçbir değer eklemedik. [submitToServer] da ekledik
        }
        if (value == null) {
          submit_data_temps[fieldModel.table_name!]!
              .remove(fieldModel.col_name!);
        }
        if (value!.isEmpty) {
          submit_data_temps[fieldModel.table_name!]!
              .remove(fieldModel.col_name!);
        } else {
          submit_data_temps[fieldModel.table_name!]![fieldModel.col_name!] =
              int.parse(value);
        }
      },
      // onChanged: (value) {
      //   if (formKeys[fieldModel.tabTitle]!.currentState!.validate()) {
      //     formKeys[fieldModel.tabTitle]!.currentState!.save();
      //   }
      // }
    );
  }

  Widget _spinDouble(FieldModel fieldModel, {required int precise}) {
    final TextEditingController controller = _initAndGetController(fieldModel);

    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.always,
      validator: FieldModelValidator(fieldModel).validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
          labelText: fieldModel.title ?? "Başlık boş geldi",
          suffixIcon: _getSyncButton(fieldModel, controller)),
      onSaved: (value) {
        if (fieldModel.visible == false) {
          return;

          /// default valuelerin eklenmesi için, burada hiçbir değer eklemedik. [submitToServer] da ekledik
        }
        if (value == null) {
          submit_data_temps[fieldModel.table_name!]!
              .remove(fieldModel.col_name!);
        }
        if (value!.isEmpty) {
          submit_data_temps[fieldModel.table_name!]!
              .remove(fieldModel.col_name!);
        } else {
          submit_data_temps[fieldModel.table_name!]![fieldModel.col_name!] =
              double.parse(value);
        }
      },
      // onChanged: (value) {
      //   if (formKeys[fieldModel.tabTitle]!.currentState!.validate()) {
      //     formKeys[fieldModel.tabTitle]!.currentState!.save();
      //   }
      // }
    );
  }

  Widget _dataGrid(FieldModel fieldModel) {
    OwnDataGridSource ds = OwnDataGridSource(
        rawData:
            (submit_data[fieldModel.table_name!] as List).reversed.toList(),
        fieldModels: fieldModel.sub_objects!);

    final List<GridColumn> columns = fieldModel.sub_objects!.map((e) {
      return GridColumn(
          visible: e.visible ?? true,
          columnName: e.col_name!,
          label: Center(child: Text(e.title!)));
    }).toList();
    return Column(
        children: <Widget>[
      SfDataGrid(
        onCellLongPress: (details) {
          final rowData = ds.rows[details.rowColumnIndex.rowIndex - 1].toJson();
          showDialog(
              context: NavigationService.instance.context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Satır Sil"),
                  content:
                      const Text("Satırı silmek istediğinize emin misiniz?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Hayır")),
                    TextButton(
                        onPressed: () {
                          final deletedLineIndex =
                              (submit_data[fieldModel.table_name!] as List)
                                  .indexWhere((element) =>
                                      mapEquals((element as Map), rowData));
                          final deletedLineData =
                              (submit_data[fieldModel.table_name!]
                                  as List)[deletedLineIndex];
                          if (!isLocal) {
                            deleted_lines[fieldModel.table_name!]!
                                .add(deletedLineData);
                          }
                          submit_data[fieldModel.table_name!]!
                              .removeAt(deletedLineIndex);
                          if (isLocal) {
                            box.fromJson(submit_data);
                          }
                          Navigator.pop(context, true);
                        },
                        child: const Text("Evet")),
                  ],
                );
              }).then((value) {
            if (value == true) {
              mainSetState();
            }
          });
        },
        allowSorting: true,
        allowFiltering: true,
        isScrollbarAlwaysShown: true,
        shrinkWrapRows: true,
        source: ds,
        selectionMode: SelectionMode.single,
        columnWidthMode: ColumnWidthMode.auto,
        onSelectionChanged: (addedRows, removedRows) {
          addedRows.first.toJson().forEach((key, value) {
            submit_data_temps[fieldModel.table_name!]![key] = value;
            if (controllers[fieldModel.table_name!]![key] != null) {
              controllers[fieldModel.table_name!]![key]!.text =
                  value.toString();
            }
          });
          mainSetState();
        },
        columns: columns,
      )
    ].addConditionally(
            first: true,
            dataFunc: () => Center(
                child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ExpansionTile(
                      title: const Text("Özet tablo"),
                      children: [
                        SfDataGrid(
                          source: ds.groupedSource(row_action!),
                          columns: columns,
                          allowSorting: true,
                          allowFiltering: true,
                          isScrollbarAlwaysShown: true,
                          shrinkWrapRows: true,
                          columnWidthMode: ColumnWidthMode.auto,
                        )
                      ],
                    ))),
            condition: row_action != null ? row_action!.group : false));
  }

  Widget _dropDown(FieldModel widgetModel) {
    if (!datasources
        .any((element) => element.key == widgetModel.field_datasource!.key)) {
      return Text(
          "Hatalı data source. Key: ${widgetModel.field_datasource!.key}");
    }

    DataSourceModel dataSource = datasources.firstWhere(
        (element) => element.key == widgetModel.field_datasource!.key);

    return DropDownTextField(
      key: Key(widgetModel.col_name!),
      searchDecoration: InputDecoration(labelText: widgetModel.title ?? "-"),
      textFieldDecoration: InputDecoration(
          labelText: widgetModel.title ?? "-",
          border: const OutlineInputBorder()),
      controller: submit_data_temps[widgetModel.table_name!]![widgetModel.col_name!] !=
                  null &&
              dataSource.DS.any((element) =>
                  element[widgetModel.field_datasource!.ValueMemberColumn] ==
                  submit_data_temps[widgetModel.table_name]![
                      widgetModel.col_name])
          ? SingleValueDropDownController(
              data: DropDownValueModel(
                  name: dataSource.DS.firstWhere((element) =>
                      element[widgetModel.field_datasource!.ValueMemberColumn] ==
                      submit_data_temps[widgetModel.table_name]![widgetModel.col_name])[widgetModel.field_datasource!.DisplayMemberColumn],
                  value: submit_data_temps[widgetModel.table_name]![widgetModel.col_name]))
          : null,
      onChanged: (value) {
        submit_data_temps[widgetModel.table_name!]![widgetModel.col_name!] =
            (value as DropDownValueModel).value;
        if (isLocal) {
          box.fromJson(submit_data);
        }
        // log(value.runtimeType.toString());
      },
      validator: FieldModelValidator(widgetModel).validator,
      enableSearch: true,
      dropDownList: dataSource.DS.map((e) {
        return DropDownValueModel(
          value: e[widgetModel.field_datasource!.ValueMemberColumn],
          name: e[widgetModel.field_datasource!.DisplayMemberColumn].toString(),
        );
      }).toList(),
    );
  }

  // yardımcı metodlar

  IconButton? _getSyncButton(
      FieldModel fieldModel, TextEditingController controller) {
    return fieldModel.default_value_model != null &&
            fieldModel.default_value_model!.api_url != null
        ? IconButton(
            onPressed: () {
              NetworkService.post(fieldModel.default_value_model!.api_url!,
                      body: fieldModel.default_value_model!.api_params)
                  .then((value) {
                if (value.success) {
                  controller.text = value.data.toString();
                }
              });
            },
            icon: const Icon(Icons.sync))
        : null;
  }

  TextEditingController _initAndGetController(FieldModel fieldModel) {
    if (controllers[fieldModel.table_name!]![fieldModel.col_name!] != null) {
      return controllers[fieldModel.table_name!]![fieldModel.col_name!]!;
    }
    controllers[fieldModel.table_name!]![fieldModel.col_name!] =
        TextEditingController();

    final TextEditingController controller =
        controllers[fieldModel.table_name!]![fieldModel.col_name!]!;

    // eğer daha önceden veri yüklenmişse
    if (submit_data_temps[fieldModel.table_name!]![fieldModel.col_name!] !=
        null) {
      controller.text =
          submit_data_temps[fieldModel.table_name!]![fieldModel.col_name!] ??
              "";
    }
    // daha önce veri yoksa ve default value geldiyse
    else if (fieldModel.default_value_model != null) {
      // zaten widgetler kurulurken, default value modelin value kısmı null değilse, value zaten temp dataya yazdırıldığı için, bir üstteki if e gireceği için hiç buradaki if e girmeyecek
      // // eğer default value modelde value varsa, valueyi yazdır
      // if (fieldModel.default_value_model!.value != null) {
      //   controller.text = fieldModel.default_value_model!.value.toString();
      // }
      // eğer default value modelde api url varsa, api url ile veri çek, veriyi yazdır
      if (fieldModel.default_value_model!.api_url != null) {
        NetworkService.post(fieldModel.default_value_model!.api_url!,
                body: fieldModel.default_value_model!.api_params)
            .then(
          (value) {
            if (value.success) {
              controller.text = value.data.toString();
            }
          },
        );
      }
    }
    return controller;
  }

  Widget createPage() {
    // önceden bu expandede sarılıydı, oda columna sarılıydı. en alttada submit butonu vardı
    return CreatePageWidget(
        genericPageCreator: this,
        formKeys: formKeys,
        tabs: tabs,
        fieldModelToWidget: fieldModelToWidget);
  }

  void tempToSubmitData() {
    submit_data_temps.forEach((key, value) {
      if (submit_data[key] == null) {
        submit_data[key] = [];
      }
      if (submit_data[key].isEmpty) {
        if (value.isNotEmpty) {
          submit_data[key].add(value);
        }
      }
      if (submit_data[key].length == 1) {
        // eğer 1 eleman varsa, o elemanı güncelle. Bu durum, fiş başlığındaki alan için yapıldı.
        Map currentData = submit_data[key].last;
        value.forEach((key, value) {
          currentData[key] = value;
        });
      }
    });
  }

  Future<void> submitToServer(String apiUrl) async {
    tempToSubmitData();

    // default valueler set ediliyor
    // Map<String, List<Map<String, dynamic>>> newSubmitData =
    Map newSubmitData = submit_data.map((key, value) => MapEntry(key, value));
    for (var tabModel in tabs) {
      for (var field in tabModel.widgets) {
        newSubmitData[field.table_name!]!.forEach((element) {
          if (field.col_name != null) {
            if (element[field.col_name!] == null) {
              element[field.col_name!] = field.default_value_model?.value;
            }
          }
        });
      }
    }

    // table relationları set ediliyor
    if (table_relations != null) {
      for (TableRelationModel table_relation in table_relations!) {
        for (var line in submit_data[table_relation.to_table_name]) {
          for (var sub_relation in table_relation.sub_relations) {
            line[sub_relation.to_col_name] =
                submit_data[table_relation.from_table_name][0]
                    [sub_relation.from_col_name];
          }
        }
      }
    }

    Map<String, dynamic> lastData = {
      "data": newSubmitData,
      "save_relations": save_relations,
      "deleted_lines": deleted_lines
    };

    try {
      ResponseModel responseModel =
          await NetworkService.post(apiUrl, body: lastData);
      if (responseModel.success) {
        NavigationService.instance.back(times: 3);
        if (isLocal) {
          box.clear();
        }
        PopupHelper.showInfoSnackBar("Kayıt başarılı");
      } else {
        PopupHelper.showErrorPopup(responseModel.errorMessage);
      }
    } catch (e) {
      PopupHelper.showErrorPopup(e.toString());
    }
  }
}

class CreatePageWidget extends StatefulWidget {
  final Map<String, GlobalKey<FormState>> formKeys;
  final List<TabModel> tabs;
  final Widget Function(FieldModel) fieldModelToWidget;
  final GenericPageCreator genericPageCreator;
  const CreatePageWidget(
      {super.key,
      required this.formKeys,
      required this.tabs,
      required this.fieldModelToWidget,
      required this.genericPageCreator});

  @override
  State<CreatePageWidget> createState() => _CreatePageWidgetState();
}

class _CreatePageWidgetState extends State<CreatePageWidget>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: widget.tabs.length, vsync: this);
    tabController.addListener(() {
      final previousPageData =
          widget.formKeys.entries.elementAt(tabController.previousIndex);
      final previousPageFormKey = previousPageData.value;
      final previousPageFormTitle = previousPageData.key;
      if (widget.tabs
              .firstWhere((tab) => tab.tab_title == previousPageFormTitle)
              .check_validator ==
          true) {
        if (previousPageFormKey.currentState != null
            ? previousPageFormKey.currentState!.validate()
            : false) {
          previousPageFormKey.currentState!.save();
          widget.genericPageCreator.tempToSubmitData();
        } else {
          PopupHelper.showErrorPopup(
              "$previousPageFormTitle sayfasında hatalar var");
        }
      }

      final currentPageFormKey =
          widget.formKeys.entries.elementAt(tabController.index).value;
      if (currentPageFormKey.currentState?.validate() == true) {
        currentPageFormKey.currentState?.save();
        widget.genericPageCreator.box
            .fromJson(widget.genericPageCreator.submit_data);
      }
      widget.genericPageCreator.box
          .fromJson(widget.genericPageCreator.submit_data);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        TabBar(
          controller: tabController,
          labelColor: Colors.black,
          tabs: widget.tabs.map((e) => Tab(text: e.tab_title)).toList(),
        ),
        Expanded(
          child: DefaultTabController(
            length: widget.tabs.length,
            child: TabBarView(
              controller: tabController,
              children: widget.tabs
                  .map(
                    (tabModel) => Form(
                      key: widget.formKeys[tabModel.tab_title],
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.smw, vertical: 15.smh),
                        child: ListView.separated(
                            addAutomaticKeepAlives: true,
                            itemBuilder: (context, index) {
                              return widget.fieldModelToWidget(tabModel.widgets
                                  .where((element) => element.visible ?? false)
                                  .toList()[index]);
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 20);
                            },
                            itemCount: tabModel.widgets
                                .where((element) => element.visible ?? false)
                                .toList()
                                .length),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
