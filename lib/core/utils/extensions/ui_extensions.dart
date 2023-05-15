import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/product/constants/app_constants.dart';

extension UIExtension on num {
  get smh {
    if (Platform.isAndroid) {
      return h;
    }

    num scale = (MediaQuery.of(
                    NavigationService.instance.navigatorKey.currentContext!)
                .size
                .height -
            MediaQuery.of(
                    NavigationService.instance.navigatorKey.currentContext!)
                .padding
                .top -
            MediaQuery.of(
                    NavigationService.instance.navigatorKey.currentContext!)
                .padding
                .bottom) /
        (MediaQuery.of(NavigationService.instance.navigatorKey.currentContext!)
                    .orientation ==
                Orientation.portrait
            ? AppConstants.designHeight
            : AppConstants.designWidth);
    return this * scale;
  }

  get smw {
    if (Platform.isAndroid) {
      return w;
    }

    num scale = (MediaQuery.of(
                    NavigationService.instance.navigatorKey.currentContext!)
                .size
                .width -
            MediaQuery.of(
                    NavigationService.instance.navigatorKey.currentContext!)
                .padding
                .left -
            MediaQuery.of(
                    NavigationService.instance.navigatorKey.currentContext!)
                .padding
                .right) /
        (MediaQuery.of(NavigationService.instance.navigatorKey.currentContext!)
                    .orientation ==
                Orientation.portrait
            ? AppConstants.designWidth
            : AppConstants.designHeight);
    return this * scale;
  }
}
