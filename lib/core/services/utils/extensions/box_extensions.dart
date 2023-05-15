import 'package:hive_flutter/hive_flutter.dart';

extension BoxExtensions on Box {
  fromJson(Map<dynamic, dynamic> json) {
    json.forEach((key, value) {
      put(key, value);
    });
    flush();
  }
}
