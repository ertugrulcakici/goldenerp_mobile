import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goldenerp/core/services/auth/user_model.dart';
import 'package:goldenerp/core/services/cache/cache_service.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/network/response_model.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/product/constants/cache_constants.dart';
import 'package:goldenerp/product/cubits/menu_data_cubit/menu_data_cubit.dart';
import 'package:goldenerp/view/auth/login/login_view.dart';
import 'package:goldenerp/view/main/home/home_view.dart';

class AuthService {
  AuthService._();

  static final AuthService _instance = AuthService._();
  static AuthService get instance => _instance;
  UserModel? user;

  bool get hasLoggedBefore =>
      CacheService.instance.appSettingsBox.get(CacheConstants.last_logged_in) !=
      null;

  bool get isLoggedIn => user != null;

  Future<void> login(
      // burası sadece daha önce giriş yapılmışsa null geliyor.
      {required String username,
      required String password}) async {
    try {
      ResponseModel loginResponse =
          await NetworkService.get("user/login", headers: {
        "Username": username,
        "Password": password,
      });
      if (loginResponse.success) {
        user = UserModel.fromJson(loginResponse.data);

        NetworkService.setUser(username: username, password: password);

        ResponseModelList menuDataResponse =
            await NetworkService.get("user/menu");
        if (menuDataResponse.success) {
          NavigationService.instance.context
              .read<MenuDataCubit>()
              .setMenuData(menuDataResponse.data);

          await user!.save();
          await user!.saveAsLastLogged();
          NavigationService.instance.navigateToPage(const HomeView());
        } else {
          throw Exception(menuDataResponse.errorMessage);
        }
      } else {
        throw Exception(loginResponse.errorMessage);
      }
    } catch (e) {
      await UserModel.clearLastLogged();
      PopupHelper.showErrorPopup(e.toString());
    }
  }

  Future<void> logout() async {
    await UserModel.clearLastLogged();
    await user!.delete();
    user = null;
    NavigationService.instance.navigateToPageAndRemoveUntil(const LoginView());
  }
}
