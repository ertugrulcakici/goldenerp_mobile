import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goldenerp/core/services/cache/cache_service.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/theme/custom_colors.dart';
import 'package:goldenerp/product/constants/app_constants.dart';
import 'package:goldenerp/product/constants/cache_constants.dart';
import 'package:goldenerp/view/auth/splash/splash_view.dart';

import 'product/cubits/menu_data_cubit/menu_data_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.init();
  AppConstants.APP_API =
      CacheService.instance.appSettingsBox.get(CacheConstants.app_api) ??
          "https://turbim.com/api/goldenerp/";
  NetworkService.init();
  runApp(const App());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
      overlays: []);
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuDataCubit(),
      child: ProviderScope(
        child: ScreenUtilInit(
          builder: (context, child) => child!,
          designSize: Size(AppConstants.designWidth.toDouble(),
              AppConstants.designHeight.toDouble()),
          child: MaterialApp(
            title: 'Golden ERP',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: CustomColors.primaryColor,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: CustomColors.primaryColor,
                  statusBarIconBrightness: Brightness.light,
                ),
              ),
              primarySwatch: CustomColors.primarySwatch,
            ),
            navigatorKey: NavigationService.instance.navigatorKey,
            home: const SplashView(),
            builder: EasyLoading.init(),
          ),
        ),
      ),
    );
  }
}
