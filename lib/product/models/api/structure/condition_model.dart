// ignore_for_file: non_constant_identifier_names

class ConditionModel {
  String table_name;
  List<String> col_names;

  ConditionModel({
    required this.table_name,
    required this.col_names,
  });

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      table_name: json["table_name"],
      col_names: (json["col_names"] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "table_name": table_name,
      "col_names": col_names,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
