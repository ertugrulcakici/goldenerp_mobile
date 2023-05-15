import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  BuildContext? _context;
  BuildContext get context {
    if (_context != null) {
      return _context!;
    } else {
      _context = navigatorKey.currentState!.context;
      return _context!;
    }
  }

  static final NavigationService _instance = NavigationService._();
  static NavigationService get instance => _instance;

  NavigationService._();

  Future<T> navigateToPage<T>(Widget page) async {
    return await navigatorKey.currentState!
        .push(MaterialPageRoute(builder: (context) => page));
  }

  Future navigateToPageReplace(Widget page) async {
    await navigatorKey.currentState!
        .pushReplacement(MaterialPageRoute(builder: (context) => page));
  }

  Future navigateToPageAndRemoveUntil(Widget page) async {
    await navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => page),
        (Route<dynamic> route) => false);
  }

  Future back<T extends Object?>({T? data, int times = 1}) async {
    for (int i = 0; i < times; i++) {
      await navigatorKey.currentState!.maybePop<T>(data);
    }
  }
}
