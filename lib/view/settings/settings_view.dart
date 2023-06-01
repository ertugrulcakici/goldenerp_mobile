import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goldenerp/core/services/utils/helpers/popup_helper.dart';
import 'package:goldenerp/product/models/structure/firm_model.dart';
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

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(provider).getFirms();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _body() {
    return Column(children: [_firms()]);
  }

  Widget _firms() {
    return Column(
      children: [
        const Text("Firmalar"),
        const Divider(),
        Card(
          child: ListTile(
            onTap: _addFirmPopup,
            title: const Center(child: Icon(Icons.add)),
          ),
        ),
        ListView.builder(
          itemCount: ref.watch(provider).firms.length,
          shrinkWrap: true,
          itemBuilder: (context, index) =>
              _firmItem(ref.watch(provider).firms[index]),
        )
      ],
    );
  }

  Future<void> _addFirmPopup() async {
    GlobalKey<FormState> firmFormKey = GlobalKey<FormState>();
    Map<String, dynamic> firmData = {};
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: firmFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Firma Ekle"),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Firma Adı boş olamaz";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        firmData["name"] = newValue!;
                      },
                      decoration: const InputDecoration(
                        labelText: "Firma Adı",
                        hintText: "Firma Adı",
                      ),
                    ),
                    TextFormField(
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Firma Api boş olamaz";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        firmData["api"] = newValue!;
                      },
                      decoration: const InputDecoration(
                        labelText: "Firma Api",
                        hintText: "Firma Api",
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (firmFormKey.currentState!.validate()) {
                            firmFormKey.currentState!.save();
                            if (await ref.read(provider).addFirm(firmData)) {
                              PopupHelper.showInfoSnackBar("Firma Eklendi");
                              Navigator.pop(context);
                            } else {
                              PopupHelper.showInfoSnackBar("Firma Eklenemedi");
                            }
                          } else {}
                        },
                        child: const Text("Kaydet"))
                  ],
                ),
              ),
            ),
          );
        }).then((value) {
      firmFormKey.currentState?.dispose();
      ref.read(provider).getFirms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      pageTitle: "Ayarlar",
      activeBack: true,
      body: _body(),
    );
  }

  Widget _firmItem(FirmModel firm) {
    return Card(
      child: ListTile(
        onTap: () async {
          if (await ref.read(provider).selectFirmById(firm.id)) {
            PopupHelper.showInfoSnackBar("Firma Seçildi");
          } else {
            PopupHelper.showInfoSnackBar("Firma Seçilemedi");
          }
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            if (await ref.read(provider).deleteFirmById(firm.id)) {
              PopupHelper.showInfoSnackBar("Firma Silindi");
            } else {
              PopupHelper.showInfoSnackBar("Firma Silinemedi");
            }
          },
        ),
        title: Text(firm.name),
        subtitle: Text(firm.api),
        tileColor:
            firm.id == ref.watch(provider).selectedFirmId ? Colors.green : null,
      ),
    );
  }
}
