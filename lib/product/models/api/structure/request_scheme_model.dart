import 'package:goldenerp/product/enums/request_action_enum.dart';

class RequestSchemeModel {
  late final RequestActionEnum requestAction;
  dynamic parameters;

  RequestSchemeModel({
    required this.requestAction,
    this.parameters,
  });

  RequestSchemeModel.fromJson(Map<String, dynamic> json) {
    /// Mevcut değerler: List,
    /// Geri kalan değerler için FichePage sayfasını açıcam
    requestAction = RequestActionEnum.values
        .firstWhere((element) => json['request_Action'] == element.toString());
    parameters = json['parameters'];
  }

  Map<String, dynamic> toJson() {
    return {
      'request_Action': requestAction.toString(),
      'parameters': parameters,
    };
  }
}
