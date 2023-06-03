import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/product/widgets/custom_pages/main/main_landing_page.dart';
import 'package:goldenerp/view/settings/settings_notifier.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  ChangeNotifierProvider<SettingsNotifier> provider =
      ChangeNotifierProvider((ref) => SettingsNotifier());

  final TextEditingController _apiController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(provider).getApi().then((value) {
        if (value && mounted) {
          setState(() {
            _apiController.text = ref.watch(provider).app_api ?? "";
          });
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _apiController.dispose();
    super.dispose();
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [_apiField()]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: "Ayarlar",
      activeBack: true,
      body: _body(),
    );
  }

  Widget _apiField() {
    return TextField(
      controller: _apiController,
      decoration: InputDecoration(
        labelText: "API Adresi",
        hintText: "API Adresi",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: _setApi,
          icon: const Icon(Icons.check),
        ),
      ),
      onEditingComplete: _setApi,
    );
  }

  _setApi() async {
    ref.read(provider).setApi(_apiController.text).then((value) {
      if (value) {
        PopupHelper.showInfoSnackBar("API Adresi kaydedildi.");
      } else {
        PopupHelper.showErrorPopup("API Adresi kaydedilemedi.");
      }
    });
  }
}
