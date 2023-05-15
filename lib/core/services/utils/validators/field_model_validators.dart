import 'package:goldenerp/product/enums/widget_type.dart';
import 'package:goldenerp/product/models/api/structure/field_model.dart';
import 'package:goldenerp/product/models/api/structure/validation_model.dart';

class FieldModelValidator {
  final FieldModel fieldModel;
  late final ValidationModel? validationModel;
  FieldModelValidator(this.fieldModel) {
    validationModel = fieldModel.validator;
  }

  String? validator(String? value) {
    // validation nesnesi yoksa null döndür
    if (validationModel == null) {
      return null;
    }
    // is required kontrolü
    if (validationModel!.isRequired) {
      if (value == null || value.isEmpty) {
        return 'Bu alan boş geçilemez';
      }
    }

    // max length kontrolü
    if (validationModel!.maxLength != null &&
        (fieldModel.widget_type == WidgetTypeEnums.textedit ||
            fieldModel.widget_type == WidgetTypeEnums.dropdown)) {
      if (value!.length > validationModel!.maxLength!) {
        return 'Bu alanın maksimum uzunluğu ${validationModel!.maxLength} karakterdir';
      }
    }

    // min ve max değer kontorlü
    if (fieldModel.widget_type.toString().contains("spin")) {
      late final num number;
      try {
        if (fieldModel.widget_type == WidgetTypeEnums.spin_0) {
          number = int.parse(value!);
        } else {
          number = double.parse(value!);
        }
      } catch (e) {
        return 'Bu alan sadece sayısal değer alabilir';
      }
      if (validationModel!.minValue != null) {
        if (number < validationModel!.minValue!) {
          return 'Bu alanın minimum değeri ${validationModel!.minValue} olmalıdır';
        }
      }
      if (validationModel!.maxValue != null) {
        if (number > validationModel!.maxValue!) {
          return 'Bu alanın maksimum değeri ${validationModel!.maxValue} olmalıdır';
        }
      }
    }
    return null;
  }
}
