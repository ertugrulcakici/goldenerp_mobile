class ValidationModel {
  bool isRequired;
  int? maxLength;
  double? maxValue;
  double? minValue;

  ValidationModel.fromJson(Map<String, dynamic> json)
      : isRequired = json['isrequired'],
        maxLength = json['maxlenght'],
        maxValue = json['maxvalue'],
        minValue = json['minvalue'];

  @override
  String toString() {
    return 'ValidationModel{isRequired: $isRequired, maxLength: $maxLength, maxValue: $maxValue, minValue: $minValue}';
  }
}
