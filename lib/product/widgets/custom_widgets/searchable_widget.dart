// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/network/response_model.dart';
import 'package:goldenerp/core/services/theme/custom_colors.dart';
import 'package:goldenerp/core/services/utils/extensions/box_extensions.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/core/services/utils/validators/field_model_validators.dart';
import 'package:goldenerp/core/utils/extensions/ui_extensions.dart';
import 'package:goldenerp/product/models/api/structure/data_source_model.dart';
import 'package:goldenerp/product/models/api/structure/ds_relations_model.dart';
import 'package:goldenerp/product/models/api/structure/field_model.dart';
import 'package:goldenerp/product/models/api/structure/row_action_model.dart';
import 'package:goldenerp/product/widgets/custom_pages/generic_page_creator.dart';
import 'package:goldenerp/product/widgets/custom_pages/search_page_view.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchableWidget extends StatefulWidget {
  // final Map<String, List<Map<String, dynamic>>> submit_data;
  final Map submit_data;
  final Map<String, Map<String, dynamic>> submit_data_temps;
  final FieldModel fieldModel;
  final DataSourceModel productDataSource;
  final GlobalKey<FormState> currentFormKey;
  final Function() mainSetState;
  final bool isLocal;
  final Box box;
  final GenericPageCreator genericPageCreator;

  const SearchableWidget({
    super.key,
    required this.submit_data,
    required this.submit_data_temps,
    required this.fieldModel,
    required this.productDataSource,
    required this.currentFormKey,
    required this.mainSetState,
    required this.isLocal,
    required this.box,
    required this.genericPageCreator,
  });

  @override
  State<SearchableWidget> createState() => _SearchableWidgetState();
}

class _SearchableWidgetState extends State<SearchableWidget> {
  late final TextEditingController _searchController;
  int lastId = -1;

  @override
  void initState() {
    widget.submit_data[widget.fieldModel.table_name].forEach((element) {
      if (element["ID"] != null) {
        if ((element["ID"] > 0 ? element["ID"] * 1 : element["ID"]) > lastId) {
          lastId = element["ID"];
        }
        if (lastId < 0) {
          lastId = lastId * -1;
        }
      }
    });
    _searchController = TextEditingController();
    widget.submit_data_temps[widget.fieldModel.table_name!] = {};
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _searchController,
          autovalidateMode: AutovalidateMode.always,
          validator: FieldModelValidator(widget.fieldModel).validator,
          onEditingComplete: () async {
            bool success = false;
            if (widget.fieldModel.api_url != null &&
                widget.fieldModel.api_url!.isNotEmpty) {
              final ResponseModelMap<String, dynamic> responseModel =
                  await NetworkService.post(widget.fieldModel.api_url!,
                      body: _searchController.text);
              if (responseModel.success) {
                success = _getProduct(data: responseModel.data);
              } else {
                PopupHelper.showErrorPopup(responseModel.errorMessage);
              }
            } else {
              success = _getProduct(barcode: _searchController.text);
            }
            if (success) {
              setState(() {
                FocusScope.of(context).nextFocus();
                FocusScope.of(context).nextFocus();
                FocusScope.of(context).nextFocus();
              });
            }
          },
          decoration: InputDecoration(
            hintText: "Barkod",
            prefixIcon: IconButton(
                onPressed: _scanBarcode,
                icon: const Icon(Icons.barcode_reader)),
            suffixIcon: widget.fieldModel.api_url == null ||
                    widget.fieldModel.api_url!.isEmpty
                ? IconButton(
                    onPressed: _searchNavigate, icon: const Icon(Icons.search))
                : null,
          ),
        ),
        ...widget.fieldModel.sub_objects!.map((subFieldModel) {
          String value = widget.submit_data_temps[
                      widget.fieldModel.table_name!]![subFieldModel.col_name!]
                  ?.toString() ??
              "-";
          return Container(
              margin: EdgeInsets.only(top: 10.smh),
              child: Text("${subFieldModel.title!}: $value"));
        }).toList(),
        SizedBox(
          width: 330.smw,
          height: 50.smh,
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                      onPressed: _addToSubmitData,
                      icon: const Icon(Icons.add),
                      label: const Text("Ekle / Düzenle"))),
              Visibility(
                visible: (widget
                    .submit_data_temps[widget.fieldModel.table_name!]!
                    .isNotEmpty),
                child: Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: _removeFromSubmitTemp,
                    child: Container(
                      height: 50.smh,
                      margin: EdgeInsets.only(left: 10.smw),
                      child: const Icon(Icons.cancel),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<void> _searchNavigate() async {
    Map<String, dynamic>? selectedProduct = await NavigationService.instance
        .navigateToPage<Map<String, dynamic>?>(SearchPageView(
            title: "Ürün ara",
            data: widget.productDataSource.DS,
            columns: widget.fieldModel.sub_objects!));
    if (selectedProduct != null) {
      _getProduct(data: selectedProduct);
    }
  }

  _scanBarcode() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
      CustomColors.primaryColorHex,
      "İptal",
      true,
      ScanMode.BARCODE,
    );
    if (barcode != "-1") {
      _searchController.text = barcode;
      _getProduct(barcode: barcode);
      FocusScope.of(context).nextFocus();
      FocusScope.of(context).nextFocus();
      FocusScope.of(context).nextFocus();
    }
  }

  /// [barcode], textfieldde submit yapılınca geliyor
  /// [data], arama butonuna basınca geliyor
  bool _getProduct({String? barcode, Map<String, dynamic>? data}) {
    if (barcode == null && data == null) {
      throw Exception("Barcode veya data null olamaz");
    }
    try {
      late final Map<String, dynamic> productData;
      if (barcode != null) {
        productData = widget.productDataSource.DS.firstWhere((element) {
          log(element.toString());
          return element[widget.fieldModel.col_name] == barcode.trim();
        });
        _searchController.text = barcode;
      } else {
        productData = data!;
        _searchController.text = data[widget.fieldModel.col_name!];
      }
      productData[widget.fieldModel.col_name!] = _searchController.text;
      widget.submit_data_temps[widget.fieldModel.table_name!]!
          .addAll(productData);
      setState(() {});
      return true;
    } catch (e) {
      PopupHelper.showErrorPopup("Ürün bulunamadı");
      _searchController.clear();
      return false;
    }
  }

  void _addToSubmitData() {
    if (widget.submit_data_temps[widget.fieldModel.table_name]?.isEmpty ??
        true) {
      PopupHelper.showErrorPopup("Herhangi bir ürün seçili değil");
      return;
    }
    if (widget.currentFormKey.currentState!.validate() &&
        widget.submit_data_temps.isNotEmpty) {
      widget.currentFormKey.currentState!.save();

      // condition varsa eklemiyorum
      // eğer submit datamda conditiona göre veri varsa ekletmiyorum
      if (widget.genericPageCreator.conditions != null) {
        for (var condition in widget.genericPageCreator.conditions!) {
          for (var line in widget.submit_data[condition.table_name]) {
            for (var colName in condition.col_names) {
              var data1 = line[colName];
              var data2 =
                  widget.submit_data_temps[condition.table_name]![colName];
              if (data1 != null && data2 != null && data1 == data2) {
                widget.submit_data_temps[condition.table_name]!.clear();
                _searchController.clear();
                widget.genericPageCreator.controllers[condition.table_name]!
                    .forEach((key, value) {
                  value.clear();
                });
                setState(() {});
                PopupHelper.showErrorPopup("Bu öğe daha önce eklenmiş");
                return;
              }
            }
          }
        }
      }

      FocusScope.of(context).unfocus();
      _searchController.clear();
      if (widget.submit_data_temps[widget.fieldModel.table_name!]!["ID"] ==
          null) {
        lastId++;

        widget.submit_data_temps[widget.fieldModel.table_name!]!["ID"] =
            lastId * -1;
      }

      // satır seçip düzenlenirken, o satırın id sine göre satırı bulup siliyor.
      if ((widget.submit_data[widget.fieldModel.table_name!] as List).any(
          (element) =>
              element["ID"] ==
              widget.submit_data_temps[widget.fieldModel.table_name!]!["ID"])) {
        (widget.submit_data[widget.fieldModel.table_name!] as List)
            .removeWhere((element) {
          return element["ID"] ==
              widget.submit_data_temps[widget.fieldModel.table_name!]!["ID"];
        });
      }

      // relation
      if (widget.genericPageCreator.ds_relations != null) {
        for (DSRelationsModel relation
            in widget.genericPageCreator.ds_relations!) {
          if (relation.table_name == widget.fieldModel.table_name) {
            // tüm sub relationlar için data sourceden , temp dataya aktarma yapıyor
            for (var subRelation in relation.sub_relations) {
              widget.submit_data_temps[relation.table_name]![
                      subRelation.uniq_data_field] =
                  widget.submit_data_temps[relation.table_name]![
                      subRelation.uniq_ds_field];
            }
            // asıl relationlar için data sourceden , temp dataya aktarma yapıyor
            widget.submit_data_temps[widget.fieldModel.table_name!]![
                    relation.uniq_data_field] =
                widget.submit_data_temps[widget.fieldModel.table_name]![
                    relation.uniq_ds_field];
          }
        }
      }

      bool addNewRow = true;

      // row action varsa (bu gruplama için)
      if (widget.genericPageCreator.row_action != null &&
          widget.genericPageCreator.row_action!.group == false) {
        // submit data da, submit data tempdeki ile aynı satır varsa (rowActiondaki keylere göre)
        if (widget.submit_data[widget.fieldModel.table_name!].any((data) {
          bool isSame = true;
          for (var key in widget.genericPageCreator.row_action!.keys) {
            if (data[key] !=
                widget.submit_data_temps[widget.fieldModel.table_name!]![key]) {
              isSame = false;
            }
          }
          return isSame;
        })) {
          // önceki satır bulundu, onun için addNewRow u false yaptık
          addNewRow = false;

          // daha sonra sona ekleyebilmek için indexini buldum
          final int dataOnSubmitDataIndex = widget
              .submit_data[widget.fieldModel.table_name!]
              .indexWhere((data) {
            bool isSame = true;
            for (var key in widget.genericPageCreator.row_action!.keys) {
              if (data[key] !=
                  widget
                      .submit_data_temps[widget.fieldModel.table_name!]![key]) {
                isSame = false;
              }
            }

            return isSame;
          });

          // bulduğum indexe göre, submit data daki satırı buldum
          final dataOnSubmitData = widget
              .submit_data[widget.fieldModel.table_name!]!
              .elementAt(dataOnSubmitDataIndex);

          // row actiondaki kolonlara göre, submit data daki satırı güncelledim
          for (var columnAction
              in widget.genericPageCreator.row_action!.columns) {
            dynamic newData = dataOnSubmitData[columnAction.key];
            if (columnAction.action == RowActionType.Sum) {
              newData = newData +
                  widget.submit_data_temps[widget.fieldModel.table_name!]![
                      columnAction.key];
            } else if (columnAction.action == RowActionType.Count) {
              newData = newData + 1;
            } else if (columnAction.action == RowActionType.Value) {
              newData = widget.submit_data_temps[
                  widget.fieldModel.table_name!]![columnAction.key];
            }
            dataOnSubmitData[columnAction.key] = newData;
          }

          // submit data daki satırı sona aldım
          widget.submit_data[widget.fieldModel.table_name!]!
              .add(dataOnSubmitData);
          widget.submit_data[widget.fieldModel.table_name!]!
              .removeAt(dataOnSubmitDataIndex);
        }
      }

      if (addNewRow) {
        // submit dataya ekleyip, temp datayı sıfırlıyor
        widget.submit_data[widget.fieldModel.table_name!]!
            .add(widget.submit_data_temps[widget.fieldModel.table_name!]!);
      }

      // form verilerini temizliyor
      widget.submit_data_temps[widget.fieldModel.table_name!] = {};
      widget.genericPageCreator.controllers[widget.fieldModel.table_name!]!
          .forEach((key, value) {
        value.clear();
      });

      if (widget.isLocal) {
        widget.box.fromJson(widget.submit_data);
        log("box :${widget.box.toMap()}");
      }
      widget.mainSetState();
      PopupHelper.showInfoSnackBar("Eklendi");
    }
  }

  _removeFromSubmitTemp() {
    widget.submit_data_temps[widget.fieldModel.table_name!] = {};
    widget.genericPageCreator.controllers[widget.fieldModel.table_name!]!
        .forEach((key, value) {
      value.clear();
    });
    _searchController.clear();
    widget.mainSetState();
  }
}
