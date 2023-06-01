import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/core/services/auth/auth_service.dart';
import 'package:goldenerp/core/services/navigation/navigation_service.dart';
import 'package:goldenerp/core/services/network/network_service.dart';
import 'package:goldenerp/core/services/theme/custom_colors.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/core/services/utils/validators/login_validators.dart';
import 'package:goldenerp/core/utils/extensions/ui_extensions.dart';
import 'package:goldenerp/product/widgets/custom_pages/custom_safearea.dart';
import 'package:goldenerp/view/settings/settings_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // late final ChangeNotifierProvider<LoginNotifier> provider;

  final Map<String, dynamic> loginData = {};

  @override
  void initState() {
    // provider = ChangeNotifierProvider((ref) => LoginNotifier());
    super.initState();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage("assets/images/login.jpg"),
        fit: BoxFit.cover,
      )),
      child: _form(),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 100.smh),
            Image.asset("assets/images/logo.png"),
            SizedBox(height: 30.smh),
            const Text("Golden ERP",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 120.smh),
            // username
            SizedBox(
              width: 300.smw,
              height: 50.smh,
              child: TextFormField(
                textInputAction: TextInputAction.next,
                validator: LoginValidators.usernameValidator,
                style: const TextStyle(color: Colors.white),
                onSaved: (newValue) {
                  loginData['username'] = newValue;
                },
                decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.white)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.white)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Colors.white)),
                    hintText: 'Kullanıcı adı',
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.person, color: Colors.white)),
              ),
            ),
            SizedBox(height: 30.smh),
            // password
            SizedBox(
              width: 300.smw,
              height: 50.smh,
              child: TextFormField(
                onFieldSubmitted: (value) {
                  _login();
                },
                validator: LoginValidators.passwordValidator,
                onSaved: (newValue) {
                  loginData['password'] = newValue;
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Şifre',
                  hintStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.white)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.white)),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: _login,
              child: Container(
                width: 300.smw,
                height: 70.smh,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: CustomColors.secondaryColor,
                ),
                child: const Center(
                  child: Text(
                    'Giriş',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: IconButton(
                  onPressed: () {
                    NavigationService.instance
                        .navigateToPage(const SettingsView());
                  },
                  icon: const Icon(Icons.settings,
                      color: Colors.white, size: 30)),
            )
          ],
        ),
      ),
    );
  }

  void _login() {
    // validate the form
    if (NetworkService.initialized == false) {
      PopupHelper.showErrorPopup("Herhangi bir firma seçilmedi. Ayarlardan "
          "firma seçimi yapınız.");
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      AuthService.instance.login(
          username: loginData['username'], password: loginData['password']);
    }
  }
}
