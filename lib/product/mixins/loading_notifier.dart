import 'package:flutter/material.dart';

mixin LoadingNotifier on ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
