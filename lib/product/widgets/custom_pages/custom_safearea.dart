import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goldenerp/core/services/theme/custom_colors.dart';

class CustomSafeArea extends StatelessWidget {
  final Widget child;
  final bool allowLandscape;
  const CustomSafeArea(
      {super.key, required this.child, this.allowLandscape = false});

  @override
  Widget build(BuildContext context) {
    if (allowLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
    }
    return WillPopScope(
      onWillPop: () {
        if (allowLandscape) {
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
        }
        return Future.value(true);
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [CustomColors.primaryColor, CustomColors.secondaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
