// ignore_for_file: constant_identifier_names

class RowActionModel {
  final bool group;
  final List<String> keys;

  final List<ColumnAction> columns;

  RowActionModel(
      {required this.keys, required this.columns, required this.group});

  factory RowActionModel.fromJson(Map<String, dynamic> json) {
    return RowActionModel(
        group: json["group"],
        keys: json["keys"].cast<String>(),
        columns: json["columns"]
            .map((e) => ColumnAction.fromJson(e))
            .toList()
            .cast<ColumnAction>());
    // key, action
  }

  Map<String, dynamic> toJson() {
    return {"keys": keys, "columns": columns, "group": group};
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class ColumnAction {
  String key;
  RowActionType action;

  ColumnAction({required this.key, required this.action});

  factory ColumnAction.fromJson(Map<String, dynamic> json) {
    return ColumnAction(
        key: json["key"],
        action: RowActionType.values
            .firstWhere((element) => element.toString() == json["action"]));
  }

  Map<String, dynamic> toJson() {
    return {"key": key, "action": action.index};
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

enum RowActionType {
  Sum,
  Count,
  Average,
  Max,
  Min,
  Value;

  @override
  String toString() => name;
}
