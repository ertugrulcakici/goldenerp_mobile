import 'package:flutter/material.dart';

mixin ErrorNotifier on ChangeNotifier {
  String _errorMessage = "Geçici hata mesajı";
  String get errorMessage => _errorMessage;
  set errorMessage(String value) {
    _errorMessage = value;
    isError = true;
  }

  bool _isError = false;
  bool get isError => _isError;
  set isError(bool value) {
    _isError = value;
    notifyListeners();
  }
}
