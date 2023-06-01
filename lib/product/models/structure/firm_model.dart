import 'package:goldenerp/product/constants/cache_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'firm_model.g.dart';

@HiveType(typeId: CacheConstants.firmModelTypeId)
class FirmModel extends HiveObject {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String api;

  FirmModel({
    required this.id,
    required this.name,
    required this.api,
  });

  factory FirmModel.fromJson(Map<String, dynamic> json) {
    return FirmModel(
      id: json["id"],
      name: json["name"],
      api: json["api"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "api": api,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
