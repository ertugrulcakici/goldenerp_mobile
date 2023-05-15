// ignore_for_file: non_constant_identifier_names

class TableRelationModel {
  String? from_table_name;
  String? to_table_name;
  List<TableRelationModel> sub_relations;
  String? from_col_name;
  String? to_col_name;

  TableRelationModel({
    this.from_table_name,
    this.from_col_name,
    this.to_table_name,
    this.to_col_name,
    required this.sub_relations,
  });

  factory TableRelationModel.fromJson(Map<String, dynamic> json) {
    return TableRelationModel(
      from_table_name: json["from_table_name"],
      from_col_name: json["from_col_name"],
      to_table_name: json["to_table_name"],
      to_col_name: json["to_col_name"],
      sub_relations: json["sub_relations"] != null
          ? (json["sub_relations"] as List)
              .map((i) => TableRelationModel.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "from_table_name": from_table_name,
      "from_col_name": from_col_name,
      "to_table_name": to_table_name,
      "to_col_name": to_col_name,
      "sub_relations": sub_relations,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
