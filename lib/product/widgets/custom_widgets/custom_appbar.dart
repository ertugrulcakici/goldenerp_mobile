import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/theme/custom_colors.dart';
import 'package:goldenerp/core/utils/extensions/ui_extensions.dart';
import 'package:goldenerp/product/constants/app_constants.dart';

abstract class CustomAppBar {
  static PreferredSize appbar(String title, Function() callBack,
      {required bool backActive}) {
    return PreferredSize(
        preferredSize: Size(AppConstants.designWidth.smw, 50.smh),
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.smw),
            color: CustomColors.primaryColor,
            child: backActive
                ? Stack(
                    children: [
                      Positioned(
                          left: 0,
                          child: IconButton(
                              onPressed: () {
                                NavigationService.instance.back();
                              },
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white))),
                      Positioned.fill(
                          child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600),
                        ),
                      )),
                    ],
                  )
                : Stack(
                    children: [
                      Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: callBack,
                            child: Image.asset("assets/images/logo.png",
                                width: 33.smw, height: 28.smh),
                          )),
                      Positioned.fill(
                          child: Center(
                              child: Text(
                        title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600),
                      )))
                    ],
                  )

            // Center(
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       backActive
            //           ? IconButton(
            //               onPressed: () {
            //                 NavigationService.instance.back();
            //               },
            //               icon: const Icon(Icons.arrow_back_ios,
            //                   color: Colors.white))
            //           : InkWell(
            //               onTap: callBack,
            //               child: Image.asset("assets/images/logo.png",
            //                   width: 33.smw, height: 28.smh),
            //             ),
            //       Text(
            //         title,
            //         style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 18.sp,
            //             fontWeight: FontWeight.w600),
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           const Icon(Icons.notifications, color: Colors.white),
            //           SizedBox(width: 10.smw),
            //           Image.asset("assets/images/logo.png",
            //               width: 22.smh, height: 22.smh)
            //         ],
            //       )
            //     ],
            //   ),
            // ),
            ));
  }
}
