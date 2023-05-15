import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/network/response_model.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/core/utils/extensions/ui_extensions.dart';
import 'package:goldenerp/product/enums/request_action_enum.dart';
import 'package:goldenerp/product/models/api/structure/menu_item_model.dart';
import 'package:goldenerp/product/models/api/structure/request_scheme_model.dart';
import 'package:goldenerp/product/widgets/custom_pages/fiche_page/fiche_page_view.dart';
import 'package:goldenerp/product/widgets/custom_pages/main/main_landing_page.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'custom_data_grid_page_notifier.dart';

class CustomDataGridPage extends ConsumerStatefulWidget {
  final String apiUrl;
  final MenuItemModel menuItemModel;
  final RequestSchemeModel apiParams;
  const CustomDataGridPage(
      {super.key,
      required this.menuItemModel,
      required this.apiUrl,
      required this.apiParams});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomDataGridPageState();
}

class _CustomDataGridPageState extends ConsumerState<CustomDataGridPage> {
  late final ChangeNotifierProvider<CustomDataGridPageNotifier> provider;
  final TextEditingController searchController = TextEditingController();
  late final DataGridController _dataGridController;

  final searchStateProvider = StateProvider.autoDispose((ref) => "");

  @override
  void initState() {
    _dataGridController = DataGridController();
    provider = ChangeNotifierProvider((ref) => CustomDataGridPageNotifier(
        apiUrl: widget.apiUrl, apiParams: widget.apiParams));
    Future.delayed(Duration.zero, () {
      ref.read(provider).getGridData();
    });

    super.initState();
  }

  @override
  void dispose() {
    _dataGridController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        floatingActionButton: _fab(),
        pageTitle: widget.menuItemModel.title,
        activeBack: true,
        body: _body());
  }

  Widget? _fab() {
    if (ref.watch(provider).menuItems.isNotEmpty) {
      return FloatingActionButton(
        onPressed: _showMenuPopup,
        child: const Icon(Icons.arrow_drop_up),
      );
    }
    return null;
  }

  Widget _body() {
    if (ref.watch(provider).isLoading) {
      return _loadingPage();
    }
    if (ref.watch(provider).isError) {
      return _errorPage();
    }
    return _content();
  }

  Widget _content() {
    return SizedBox(
      height: 750.smh,
      child: SfDataGrid(
        controller: _dataGridController,
        allowSorting: true,
        shrinkWrapRows: false,
        allowFiltering: true,
        allowMultiColumnSorting: true,
        allowEditing: true,
        selectionMode: SelectionMode.single,
        allowColumnsResizing: true,
        allowPullToRefresh: true,
        allowTriStateSorting: true,
        columnWidthMode: ColumnWidthMode.auto,
        source: ref.watch(provider).dataSource!,
        columns: ref
            .watch(provider)
            .fields
            .map((element) => GridColumn(
                  visible: element.visible ?? true,
                  columnName: element.col_name!,
                  label: Center(child: Text(element.title!)),
                ))
            .toList(),
      ),
    );
  }

  Widget _errorPage() {
    return Center(
      child: Text(ref.watch(provider).errorMessage),
    );
  }

  Widget _loadingPage() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> _showMenuPopup() async {
    log(_dataGridController.selectedRows.length.toString());
    await showDialog(
        context: context,
        builder: (context) {
          List<MenuItemModel> menuItems = ref.watch(provider).menuItems;
          return Dialog(
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _menuItemWidget(menuItems[index]);
              },
              itemCount: menuItems.length,
            ),
          );
        });
  }

  Widget _menuItemWidget(MenuItemModel menuItemModel, {int tabSize = 0}) {
    if (menuItemModel.subMenus != null && menuItemModel.subMenus!.isNotEmpty) {
      final returnData = ExpansionTile(
        title: Text(("\t" * tabSize * 4) + menuItemModel.title),
        children: menuItemModel.subMenus!
            .map((e) => _menuItemWidget(e, tabSize: tabSize + 1))
            .toList(),
      );
      tabSize++;
      return returnData;
    } else {
      return ListTile(
        title: Text(("\t" * tabSize * 4) + menuItemModel.title),
        onTap: () async {
          log("menu data: $menuItemModel");
          if (menuItemModel.apiParams == null) {
            return;
          }

          final parameters = menuItemModel.apiParams!.parameters ??
              _dataGridController.selectedRows
                  .map<int>((DataGridRow e) => e
                      .getCells()
                      .firstWhere((element) => element.columnName == "ID")
                      .value)
                  .toList();
          if (menuItemModel.apiParams!.requestAction ==
                  RequestActionEnum.NewFiche ||
              menuItemModel.apiParams!.requestAction ==
                  RequestActionEnum.DefaultFiche) {
            NavigationService.instance
                .navigateToPage(FichePageView(
                    menuItemModel: menuItemModel,
                    apiUrl: menuItemModel.apiUrl!,
                    apiParams: RequestSchemeModel(
                        requestAction: menuItemModel.apiParams!.requestAction,
                        parameters: parameters)))
                .then((value) {
              _dataGridController.selectedRows.clear();
              ref.read(provider).getGridData();
            });
          } else if (menuItemModel.apiParams!.requestAction ==
              RequestActionEnum.Action) {
            ResponseModel responseModel = await NetworkService.post(
                menuItemModel.apiUrl!,
                body: RequestSchemeModel(
                        requestAction: menuItemModel.apiParams!.requestAction,
                        parameters: parameters)
                    .toJson());
            if (responseModel.success) {
              PopupHelper.showInfoSnackBar("İşlem başarılı");
              _dataGridController.selectedRows.clear();
              ref.read(provider).getGridData();
              // ignore: use_build_context_synchronously
              Navigator.pop(context); // popup ı kapat
            } else {
              PopupHelper.showErrorPopup(responseModel.errorMessage);
            }
          } else if (menuItemModel.apiParams!.requestAction ==
              RequestActionEnum.ConfirmationAction) {
            bool action = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(menuItemModel.title),
                    content: const Text(
                        "İşlemi onaylamak istediğinize emin misiniz ?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("Onayla"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("İptal"),
                      ),
                    ],
                  );
                });
            if (action) {
              ResponseModel responseModel = await NetworkService.post(
                  menuItemModel.apiUrl!,
                  body: RequestSchemeModel(
                          requestAction: menuItemModel.apiParams!.requestAction,
                          parameters: parameters)
                      .toJson());
              if (responseModel.success) {
                _dataGridController.selectedRows.clear();
                ref.read(provider).getGridData();
              }
            }
          }
        },
      );
    }
  }
}
