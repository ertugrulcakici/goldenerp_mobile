// ignore_for_file: non_constant_identifier_names

class DefaultValueModel {
  late final String? api_url;
  late final dynamic value;
  dynamic api_params;

  DefaultValueModel({
    required this.api_url,
    required this.value,
    this.api_params,
  });

  factory DefaultValueModel.fromJson(Map<String, dynamic> json) {
    return DefaultValueModel(
      api_url: json["api_url"],
      value: json["value"],
      api_params: json["api_params"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "api_url": api_url,
      "value": value,
      "api_params": api_params,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
