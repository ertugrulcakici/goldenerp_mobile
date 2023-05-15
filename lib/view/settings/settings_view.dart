import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/core/services/auth/auth_service.dart';
import 'package:goldenerp/core/services/cache/cache_service.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/core/utils/extensions/ui_extensions.dart';
import 'package:goldenerp/product/constants/app_constants.dart';
import 'package:goldenerp/product/constants/cache_constants.dart';
import 'package:goldenerp/product/widgets/custom_pages/main/main_landing_page.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {'api': AppConstants.APP_API};

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  Widget _body() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.smw, vertical: 20.smh),
      child: Center(
        child: Form(
          key: _formKey,
          child: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Api boş olamaz";
              }
              return null;
            },
            onSaved: (value) {
              formData["api"] = value!;
            },
            initialValue: AppConstants.APP_API,
            decoration: const InputDecoration(
              labelText: "Api",
              hintText: "Api",
            ),
          ),
        ),
      ),
    );
  }

  Widget _fab() {
    return FloatingActionButton.extended(
      onPressed: _save,
      icon: const Icon(Icons.save),
      label: const Text("Kaydet"),
    );
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final String api = formData["api"]!;
      AppConstants.APP_API = api;
      await CacheService.instance.appSettingsBox
          .put(CacheConstants.app_api, api);

      NetworkService.init();
      if (AuthService.instance.isLoggedIn) {
        NetworkService.setUser(
          username: AuthService.instance.user!.logonName,
          password: AuthService.instance.user!.password,
        );
      }

      PopupHelper.showInfoSnackBar("Değişiklikler kaydedildi");
      NavigationService.instance.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: "Ayarlar",
      activeBack: true,
      floatingActionButton: _fab(),
      body: _body(),
    );
  }
}
