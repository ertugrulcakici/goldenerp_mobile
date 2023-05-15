import 'package:flutter/material.dart';
import 'package:goldenerp/core/services/auth/auth_service.dart';
import 'package:goldenerp/core/services/auth/user_model.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/view/auth/login/login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _init() async {
    try {
      if (AuthService.instance.hasLoggedBefore) {
        AuthService.instance.user = UserModel.fromLastLogin();
        AuthService.instance.login(
            username: AuthService.instance.user!.logonName,
            password: AuthService.instance.user!.password);
      } else {
        Future.delayed(Duration.zero, () {
          NavigationService.instance.navigateToPage(const LoginView());
        });
      }
    } catch (e) {
      PopupHelper.showErrorPopup(e.toString());
    }

    // try {
    //   ResponseModelMap<String, dynamic> responseModel =
    //       await NetworkService.get<Map<String, dynamic>>("user/menu");
    //   if (responseModel.success) {
    //     NavigationService.instance.context
    //         .read<MenuDataCubit>()
    //         .setMenuData(responseModel.data);

    //     AllProviders.ref.read(AllProviders.menuDataProvider.notifier).state =
    //         responseModel.data;
    //   } else {
    //     log("SplashView _init() error: ${responseModel.errorMessage}");
    //   }
    // } catch (e) {
    //   log("SplashView _init() error: $e");
    // }
  }
}
