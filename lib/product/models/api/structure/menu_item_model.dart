import 'package:goldenerp/product/models/api/structure/request_scheme_model.dart';

class MenuItemModel {
  late final String? name;
  late final String title;
  late final List<MenuItemModel>? subMenus;
  late final String? apiUrl;
  late final RequestSchemeModel? apiParams;

  MenuItemModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    title = json['title'];
    subMenus = json['sub_menus'] != null
        ? (json['sub_menus'] as List)
            .map((e) => MenuItemModel.fromJson(e))
            .toList()
        : null;
    apiUrl = json['api_url'] as String?;
    apiParams = json['api_params'] != null
        ? RequestSchemeModel.fromJson(json['api_params'])
        : null;
  }

  toJson() {
    return {
      'name': name,
      'title': title,
      'sub_menus': subMenus,
      'api_url': apiUrl,
      'api_params': apiParams?.toJson()
    };
  }

  @override
  toString() {
    return toJson().toString();
  }
}
