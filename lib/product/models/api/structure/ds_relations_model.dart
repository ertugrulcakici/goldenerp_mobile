// ignore_for_file: non_constant_identifier_names

class DSRelationsModel {
  final String table_name;
  final String ds_key;
  final String uniq_data_field;
  final String uniq_ds_field;
  final List<SubRelationModel> sub_relations;

  DSRelationsModel({
    required this.table_name,
    required this.ds_key,
    required this.uniq_data_field,
    required this.uniq_ds_field,
    required this.sub_relations,
  });

  DSRelationsModel.fromJson(Map<String, dynamic> json)
      : table_name = json['table_name'],
        ds_key = json['ds_key'],
        uniq_data_field = json['uniq_data_field'],
        uniq_ds_field = json['uniq_ds_field'],
        sub_relations = json['sub_relations'] != null
            ? (json['sub_relations'] as List)
                .map((i) => SubRelationModel.fromJson(i))
                .toList()
            : [];
}

class SubRelationModel {
  final String uniq_data_field;
  final String uniq_ds_field;

  SubRelationModel({
    required this.uniq_data_field,
    required this.uniq_ds_field,
  });

  SubRelationModel.fromJson(Map<String, dynamic> json)
      : uniq_data_field = json['uniq_data_field'],
        uniq_ds_field = json['uniq_ds_field'];
}
