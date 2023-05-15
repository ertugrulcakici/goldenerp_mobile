import 'dart:developer';

import 'package:flutter/material.dart';

class MainLandingPageNotifier extends ChangeNotifier {
  @override
  void dispose() {
    log("MainLandingPageNotifier dispose");
    super.dispose();
  }
}
