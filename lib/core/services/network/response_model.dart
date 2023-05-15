typedef ResponseModelMap<K, V> = ResponseModel<Map<K, V>>;
typedef ResponseModelList<T> = ResponseModel<List<T>>;
typedef ResponseModelString = ResponseModel<String>;
typedef ResponseModelBoolean = ResponseModel<bool>;
typedef ResponseModelInt = ResponseModel<int>;
typedef ResponseModelDouble = ResponseModel<double>;

class ResponseModel<T extends dynamic> {
  // TODO: Tüm heryerde error mesajlarını iptal edip throw yolla
  static const String _nonErrorMessage =
      "There is no error in connection object!";
  String errorMessage = _nonErrorMessage;
  T data;
  bool get success => errorMessage == _nonErrorMessage;
  ResponseModel({required this.errorMessage, required this.data});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    if (json["errorMessage"] == null && json["data"] is T) {
      ResponseModel<T> model = ResponseModel<T>(
          data: json["data"] as T, errorMessage: _nonErrorMessage);
      return model;
    } else if (json["errorMessage"] != null) {
      return ResponseModel<T>(
          errorMessage: json["errorMessage"], data: Object as T);
    } else {
      return ResponseModel<T>.error();
    }
  }

  factory ResponseModel.error() {
    return ResponseModel<T>(
        errorMessage: "Bilinmeyen bir hata oluştu", data: Object as T);
  }

  factory ResponseModel.networkError() {
    return ResponseModel<T>(
        errorMessage: "Bir bağlantı hatası oluştu", data: Object as T);
  }
}
