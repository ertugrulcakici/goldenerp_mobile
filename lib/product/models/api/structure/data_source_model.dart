// ignore_for_file: non_constant_identifier_names

class DataSourceModel {
  final String key;
  final List<Map<String, dynamic>> DS;

  DataSourceModel.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        DS = (json['DS'] as List).cast<Map<String, dynamic>>();

  @override
  String toString() {
    return 'DataSourceModel{key: $key, DS: $DS}';
  }
}
