// ignore_for_file: non_constant_identifier_names

class FieldDataSourceModel {
  final String key;
  final String? ValueMemberColumn;
  final String? DisplayMemberColumn;

  FieldDataSourceModel.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        ValueMemberColumn = json['ValueMemberColumn'],
        DisplayMemberColumn = json['DisplayMemberColumn'];

  @override
  String toString() {
    return 'FieldDataSourceModel{key: $key, ValueMemberColumn: $ValueMemberColumn, DisplayMemberColumn: $DisplayMemberColumn}';
  }
}
