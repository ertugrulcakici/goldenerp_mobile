import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/utils/extensions/grid_view_extensions.dart';
import 'package:goldenerp/product/models/api/structure/field_model.dart';
import 'package:goldenerp/product/models/structure/own_data_grid_source.dart';
import 'package:goldenerp/product/widgets/custom_pages/main/main_landing_page.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SearchPageView extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final List<FieldModel> columns;

  final String? label;
  final String? hint;

  const SearchPageView({
    super.key,
    required this.title,
    required this.data,
    required this.columns,
    this.label,
    this.hint,
  });

  @override
  State<SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<SearchPageView> {
  // late final TextEditingController _searchController;
  final List<Map<String, dynamic>> filteredData = [];
  final List<String> searchInStrings = [];

  @override
  void initState() {
    filteredData.addAll(widget.data);
    searchInStrings.addAll(widget.data.map((e) =>
        e.values.map((e) => e.toString().trim().toLowerCase()).join(' ')));
    // _searchController = TextEditingController();
    // _searchController.addListener(() {
    // setState(() {
    //   filteredData.clear();
    //   if (_searchController.text.isEmpty) {
    //     filteredData.addAll(widget.data);
    //   } else {
    //     Set<String> searchKeys = _searchController.text
    //         .toLowerCase()
    //         .split(' ')
    //         .where((element) => element.isNotEmpty)
    //         .toSet();
    //     for (var searchInString in searchInStrings) {
    //       bool isAdded = false;
    //       for (var element in searchKeys) {
    //         if (element.contains(searchInString) && !isAdded) {
    //           isAdded = true;
    //           filteredData
    //               .add(widget.data[searchInStrings.indexOf(searchInString)]);
    //         }
    //       }
    //     }
    //   }
    // });
    // });
    super.initState();
  }

  @override
  void dispose() {
    // _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      activeBack: true,
      pageTitle: widget.title,
      body: _body(),
    );
  }

  Widget _body() {
    return SfDataGrid(
        selectionMode: SelectionMode.single,
        onSelectionChanged: (addedRows, removedRows) {
          if (addedRows.isNotEmpty) {
            NavigationService.instance.back(data: addedRows.first.toJson());
          }
        },
        allowFiltering: true,
        allowSorting: true,
        // gridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: ColumnWidthMode.auto,
        source: OwnDataGridSource(
            fieldModels: widget.columns, rawData: filteredData),
        columns: widget.columns
            .map(
              (fieldModel) => GridColumn(
                columnName: fieldModel.col_name!,
                label: Center(child: Text(fieldModel.title!)),
              ),
            )
            .toList());
  }

  // Widget _body() {
  //   return Column(
  //     children: [
  //       SizedBox(
  //         height: 50.smh,
  //         child: TextField(
  //           controller: _searchController,
  //           decoration: InputDecoration(
  //             hintText: widget.hint ?? widget.title,
  //             labelText: widget.label ?? widget.title,
  //             prefixIcon: const Icon(Icons.search),
  //             suffixIcon: _searchController.text.isNotEmpty
  //                 ? IconButton(
  //                     icon: const Icon(Icons.clear),
  //                     onPressed: () {
  //                       _searchController.clear();
  //                     },
  //                   )
  //                 : null,
  //           ),
  //         ),
  //       ),
  //       Expanded(
  //         child: SfDataGrid(
  //             allowFiltering: true,
  //             allowSorting: true,
  //             // gridLinesVisibility: GridLinesVisibility.both,
  //             columnWidthMode: ColumnWidthMode.fill,
  //             source: OwnDataGridSource(
  //                 fieldModels: widget.columns, rawData: filteredData),
  //             columns: widget.columns
  //                 .map(
  //                   (fieldModel) => GridColumn(
  //                     columnName: fieldModel.col_name!,
  //                     label: Center(child: Text(fieldModel.title!)),
  //                   ),
  //                 )
  //                 .toList()),
  //       )
  //     ],
  //   );
  // }
}
